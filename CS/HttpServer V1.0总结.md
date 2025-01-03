# HttpServer V1.0总结

## 目前的技术要点
* 参照muduo，使用双缓冲技术实现了Log系统
* 使用小根堆+unordered_map实现定时器队列，在此基础上进一步实现了长连接的处理
* 使用RAII机制封装锁，让线程更安全
* 采用Reactor模式+EPOLL(ET)非阻塞IO
* 使用基于状态机的HTTP请求解析，较为优雅
* 使用了智能指针、bind、function、右值引用等一些c++11的新特性

## 待优化的地方
* 加入缓存机制(LRU/LFU)
* 优雅的关闭连接
* 目前仅支持处理`GET`和`HEAD`方法，其他方法待加入
* 错误请求的处理暂时只按照`400 Bad Request`返回（能区分错误但未能返回正确的错误码）
* 扩展为FileServer

## HTTPServer的Reactor模型
<div align=center><img src="https://s1.328888.xyz/2022/04/18/rhcx1.png"></div>
HttpServer使用主从Reactor多线程模型
* 主要工作流程
    1. Reactor主线程MainReactor对象通过Select/Epoll监控建立连接事件，收到事件后通过Acceptor接收，处理建立连接事件（目前只有一个事件：请求连接）
    2. Acceptor处理建立连接事件后，MainReactor将连接分配Reactor子线程给 SubReactor进行处理
    3. SubReactor将连接加入连接队列进行监听，并创建一个Epoll用于监听各种连接事件
    4. 当有新的事件发生时，SubReactor会调用连接对应ActiveChannel的Handler进行响应
* 优点
    1. 父线程与子线程的数据交互简单职责明确，父线程只需要接收新连接，子线程完成后续的业务处理
    2. 父线程与子线程的数据交互简单，Reactor 主线程只需要把新连接传给子线程，子线程无需返回数据

## Reactor核心实现
### TimerManager
---
首先从定时器说起，每个定时器（`TimerNode`）管理一个Channel,然后由一个TimerManager来管理多个TimerNode。TimerManager通过一个小根堆（`timerHeap_`）和一个哈希表（`timerMap_`）来管理，`timerMap_`是fd对TimerNode的映射，映射Channel中最接近超时的TimerNode（每个Channel对应多个TimerNode），仅当Channel对应的所有TimerNode都被删除，才调用Channel的close回调函数，并将其从`timerMap_`中移除，符合长连接的处理逻辑
* 使用小根堆的原因：
    1. 优先队列不支持随机访问
    2. 即使支持，随机删除某节点后破坏了堆的结构，需要重新更新堆结构
* 具体处理逻辑：
    1. 对于被置为deleted的时间节点，会延迟到它①超时或②它前面的节点都被删除时，它才会被删除
    2. 因此一个点被置为deleted,它最迟会在TIMER_TIME_OUT时间后被删除
* 这样做的好处：
    1. 不需要遍历优先队列，省时
    2. 给超时的节点一个容忍时间，就是设定的超时时间是删除的下限(并不是一到超时时间就立即删除)，如果监听的请求在超时后的下一次请求中又一次出现了，就不用再重新new一个Channel节点了，这样可以复用前面的Channel，减少了一次delete和一次new的时间
* 待优化
    * 在同一长连接反复请求时会产生大量的TimerNode，可能会出现内存泄漏的情况

### Epoll
---
<div align=center><img src="https://s1.328888.xyz/2022/04/18/rhlO3.png"></div>
Epoll类是对系统调用epoll的封装,用一个就绪事件列表`std::vector<epoll_event> events_`接收`epoll_wait()`返回的活动事件列表,进一步通过`channelMap_`找到对应的channel(`epoll_event`的封装)并设为活动Channel
* 待优化
    * fd对channel的映射所造成的额外空间,**可以考虑优化为直接使用`epoll_event`的内置`data`**


### Channel
---
Channel是对epoll_event的封装,并将可能产生事件的文件描述符封装在其中的，这里的文件描述符可以是file descriptor，可以是socket，还可以是timefd，signalfd
* 每个Channel对象自始至终只属于一个EventLoop，因此每个Channel对象都只属于某一个IO线程
* 每个Channel对象自始至终只负责一个文件描述符（fd）的IO事件分发，在其析构的时候关闭这个fd，事件分发的基本思想是根据Epoll返回的事件活动flags，来进行回调函数的调用
* Channel的生命期由其owner calss负责管理

### EventLoop
---
EventLoop是事件驱动模式的核心,核心是为线程提供运行循环，不断监听事件、处理事件，符合muduo中one loop per thread的思想，执行提供在loop循环中运行的接口,它管理一个`Epoll`、一个用于loop线程间通信的`pwakeupChannel_`以及一个定时器队列`timerManager_`
* pwakeupChannel_使用eventfd来进行线程(eventloop)间的通信
* EventLoop在Loop()中主要做以下几件事：
    1. 清空`activechannels`
    2. 获取`activechannels`
    3. 根据事件处理`activechannels`中的活动`Channel`
    4. 处理`timerManager_`中超时的`TimerNode`
* 待优化
    * 将`doPendingFunctors()`作为`pwakeupChannel_`的ReadHandler，会造成惊群现状，目前没想到好的解决办法

## 线程池模型
<div align=center><img src="https://s1.328888.xyz/2022/04/18/rhKNO.png"></div>

借鉴muduo中one loop per thread的思想，每个线程与一个EventLoop对应，设计了`EventLoopThread`类封装了thread和EventLoop，然后在`EventLoopThreadPool`类中根据需要的线程数来创建`EventLoopThread`，最后根据Round Robin来选择下一个EventLoop，实现负载均衡

## 日志系统的实现
LOG的实现参照了muduo，但是比muduo要简化一点
* 首先是Logger类，Logger类里面有Impl类，其实具体实现是Impl类，我也不懂muduo为何要再封装一层，那么我们来说说Impl干了什么，在初始化的时候Impl会把时间信息存到LogStream的缓冲区里，在我们实际用Log的时候，实际写入的缓冲区也是LogStream，在析构的时候Impl会把当前文件和行数等信息写入到LogStream，再把LogStream里的内容写到AsyncLogging的缓冲区中，当然这时候我们要先开启一个后端线程用于把缓冲区的信息写到文件里
* LogStream类，里面其实就一个Buffer缓冲区，是用来暂时存放我们写入的信息的.还有就是重载运算符，因为我们采用的是C++的流式风格
* AsyncLogging类，最核心的部分，在多线程程序中写Log无非就是前端往后端写，后端往硬盘写，首先将LogStream的内容写到了AsyncLogging缓冲区里，也就是前端往后端写，这个过程通过append函数实现，后端实现通过threadfunc函数，两个线程的同步和等待通过互斥锁和条件变量来实现，具体实现使用了双缓冲技术
    * 双缓冲技术的基本思路：准备两块buffer，A和B,前端往A写数据，后端从B里面往硬盘写数据，当A写满后，交换A和B，如此反复。不过实际的实现的话和这个还是有点区别，具体看代码吧
* 待优化
    * 加入日志分级分文件存放
    * 加入滚动日志功能（按照行数和事件滚动）