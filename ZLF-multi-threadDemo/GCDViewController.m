//
//  GCDViewController.m
//  ZLF-multi-threadDemo
//
//  Created by 张林峰 on 15/11/18.
//  Copyright © 2015年 张林峰. All rights reserved.
//

#import "GCDViewController.h"

@interface GCDViewController ()

@property (nonatomic, strong) NSArray *array;

@end

@implementation GCDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 *  串行异步
 *  执行结果：串行队列中的任务异步执行时，上一个任务完成，下一个任务才开始
 *
 */
- (IBAction)serialAsync:(id)sender {
    // 创建一个串行队列
    //其中第一个参数是标识符。第二个参数传DISPATCH_QUEUE_SERIAL 或 NULL 表示创建串行队列，传入 DISPATCH_QUEUE_CONCURRENT 表示创建并行队列。
    dispatch_queue_t myQueue = dispatch_queue_create("myQueue", NULL);
    //通过一个for循环将10个很耗时的异步任务加到串行队列
    for (NSInteger n = 0; n < 3; n++) {
        dispatch_async(myQueue, ^{
            //模拟一个很耗时的操作
            for (NSInteger i = 0; i < 500000000; i++) {
                if (i == 0) {
                    NSLog(@"串行异步任务%ld -> 开始%@",n,[NSThread currentThread]);
                }
                if (i == 499999999) {
                    NSLog(@"串行异步任务%ld -> 完成",(long)n);
                }
            }
        });
    }
    NSLog(@"阻塞我没有？当前线程%@",[NSThread currentThread]);
}

/**
 *  串行同步
 *  执行结果：串行队列中的任务同步执行时，上一个任务完成，下一个任务才开始.同步会阻塞当前线程。
 *
 */
- (IBAction)serialSync:(id)sender {
    // 创建一个串行队列
    //其中第一个参数是标识符。第二个参数传DISPATCH_QUEUE_SERIAL 或 NULL 表示创建串行队列，传入 DISPATCH_QUEUE_CONCURRENT 表示创建并行队列。
    dispatch_queue_t myQueue = dispatch_queue_create("myQueue", NULL);
    //通过一个for循环将10个很耗时的同步任务加到串行队列
    for (NSInteger n = 0; n < 3; n++) {
        dispatch_sync(myQueue, ^{
            //模拟一个很耗时的操作
            for (NSInteger i = 0; i < 500000000; i++) {
                if (i == 0) {
                    NSLog(@"串行同步任务%ld -> 开始%@",n,[NSThread currentThread]);
                }
                if (i == 499999999) {
                    NSLog(@"串行同步任务%ld -> 完成",(long)n);
                }
            }
        });
    }
    NSLog(@"阻塞我没有？当前线程%@",[NSThread currentThread]);
}

/**
 *  并行异步
 *  执行结果：并行队列中的任务异步执行时，多个任务同时开始
 *
 */
- (IBAction)concurrentAsync:(id)sender {
    // 创建一个并行队列
    //其中第一个参数是标识符。第二个参数传DISPATCH_QUEUE_SERIAL 或 NULL 表示创建串行队列，传入 DISPATCH_QUEUE_CONCURRENT 表示创建并行队列。
    dispatch_queue_t myQueue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_CONCURRENT);
    //通过一个for循环将10个很耗时的异步任务加到并行队列
    for (NSInteger n = 0; n < 3; n++) {
        dispatch_async(myQueue, ^{
            //模拟一个很耗时的操作
            for (NSInteger i = 0; i < 500000000; i++) {
                if (i == 0) {
                    NSLog(@"并行异步任务%ld -> 开始%@",n,[NSThread currentThread]);
                }
                if (i == 499999999) {
                    NSLog(@"并行异步任务%ld -> 完成",(long)n);
                }
            }
        });
    }
    NSLog(@"阻塞我没有？当前线程%@",[NSThread currentThread]);
}

/**
 *  并行同步
 *  执行结果：并行队列中的任务同步执行时，当第一个同步任务开始时会阻塞当前线程，直到该任务完成，下一个任务才加入到队列中。同步会阻塞当前线程。
 *
 */
- (IBAction)concurrentSync:(id)sender {
    // 创建一个并行队列
    //其中第一个参数是标识符。第二个参数传DISPATCH_QUEUE_SERIAL 或 NULL 表示创建串行队列，传入 DISPATCH_QUEUE_CONCURRENT 表示创建并行队列。
    dispatch_queue_t myQueue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_CONCURRENT);
    //通过一个for循环将10个很耗时的同步任务加到并行队列
    for (NSInteger n = 0; n < 3; n++) {
        dispatch_sync(myQueue, ^{
            //模拟一个很耗时的操作
            for (NSInteger i = 0; i < 500000000; i++) {
                if (i == 0) {
                    NSLog(@"并行同步任务%ld -> 开始%@",(long)n,[NSThread currentThread]);
                }
                if (i == 499999999) {
                    NSLog(@"并行同步任务%ld -> 完成",(long)n);
                }
            }
        });
    }
    
    NSLog(@"阻塞我没有？当前线程%@",[NSThread currentThread]);
}

//当这个组里所有的任务都执行完了，队列组会通过一个方法通知我们，这些任务都是异步并行执行的
- (IBAction)queueGroup:(id)sender {
    //创建队列组
    dispatch_group_t group = dispatch_group_create();
    //创建全局并行队列
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t myQueue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    //队列组执行全局队列
    dispatch_group_async(group, globalQueue, ^{
        for (NSInteger i = 0; i < 3; i++) {
            NSLog(@"全局并行队列%ld",(long)i);
        }
    });
    //队列组执行自定义并行队列
    dispatch_group_async(group, myQueue, ^{
        for (NSInteger i = 0; i < 4; i++) {
            NSLog(@"自定义并行队列%ld",(long)i);
        }
    });
    //队列组执行主队列
    dispatch_group_async(group, mainQueue, ^{
        for (NSInteger i = 0; i < 5; i++) {
            NSLog(@"主队列%ld",(long)i);
        }
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"完成 - %@", [NSThread currentThread]);
    });
    NSLog(@"阻塞我没有？当前线程%@",[NSThread currentThread]);
}

//GCD延时
- (IBAction)dispatchDelay:(id)sender {
    //非阻塞的执行方式
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"延时了2秒");
    });
    
    //既然谈到了延时延时，那就和其他几种延时比较下
    
    //1.此方式要求必须在主线程中执行，否则无效。是一种非阻塞的执行方式，暂时未找到取消执行的方法。
//    [self performSelector:@selector(delayMethod) withObject:nil afterDelay:1.0f];
    
    //2.此方式要求必须在主线程中执行，否则无效。是一种非阻塞的执行方式，可以通过NSTimer类的- (void)invalidate;取消执行。
//    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(delayMethod) userInfo:nil repeats:NO];
    
    //3. 此方式在主线程和子线程中均可执行。是一种阻塞的执行方式，建方放到子线程中，以免卡住界面，没有找到取消执行的方法。
//    [NSThread sleepForTimeInterval:4.0f];
//    [self delayMethod];
    
    
   NSLog(@"阻塞我没有？当前线程%@",[NSThread currentThread]);
}

- (void)delayMethod {
    NSLog(@"延时了");
}


/**前面任务完成再执行后面任务
 * 这个方法重点是你传入的 queue，当你传入的 queue 是通过 DISPATCH_QUEUE_CONCURRENT 参数自己创建的 queue 时，这个方法会阻塞这个 queue（注意是阻塞 queue ，而不是阻塞当前线程），一直等到这个 queue 中排在它前面的任务都并行执行完成后才会开始执行自己，自己执行完毕后，再会取消阻塞，使这个 queue 中排在它后面的任务继续并行执行。
    如果你传入的是其他的 queue, 那么它就和 dispatch_async 一样了。

 */

- (IBAction)wait:(id)sender {
    dispatch_queue_t myQueue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_CONCURRENT);
    //前面加2个任务
    for (NSInteger n = 0; n < 2; n++) {
        dispatch_async(myQueue, ^{
            //模拟一个很耗时的操作
            for (NSInteger i = 0; i < 500000000; i++) {
                if (i == 0) {
                    NSLog(@"前面任务%ld -> 开始",(long)n);
                }
                if (i == 499999999) {
                    NSLog(@"前面任务%ld -> 完成",(long)n);
                }
            }
        });
    }
    
    dispatch_barrier_async(myQueue, ^(){
        NSLog(@"dispatch-barrier");
    });
    
    //后面加2个任务
    for (NSInteger n = 0; n < 2; n++) {
        dispatch_async(myQueue, ^{
            //模拟一个很耗时的操作
            for (NSInteger i = 0; i < 500000000; i++) {
                if (i == 0) {
                    NSLog(@"后面任务%ld -> 开始",(long)n);
                }
                if (i == 499999999) {
                    NSLog(@"后面面任务%ld -> 完成",(long)n);
                }
            }
        });
    }
}



//注意：同步不会另开线程，异步会另开线程，所以同步时注意不要发生死锁

//死锁主线程
- (IBAction)deadlock1:(id)sender {
    NSLog(@"之前线程 － %@", [NSThread currentThread]);
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"同步操作的线程 - %@", [NSThread currentThread]);
    });
    NSLog(@"之后线程 - %@", [NSThread currentThread]);
}

//死锁子线程
- (IBAction)deadlock2:(id)sender {
    dispatch_queue_t myQueue = dispatch_queue_create("myQueue", NULL);
    NSLog(@"之前线程 - %@", [NSThread currentThread]);
    dispatch_async(myQueue, ^{
        NSLog(@"同步操作之前线程 - %@", [NSThread currentThread]);
        dispatch_sync(myQueue, ^{
            NSLog(@"同步操作时线程 - %@", [NSThread currentThread]);
        });
        NSLog(@"同步操作之后线程 - %@", [NSThread currentThread]);
    });
    NSLog(@"之后线程 - %@", [NSThread currentThread]);
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
