//
//  NSOperationViewController.m
//  ZLF-multi-threadDemo
//
//  Created by 张林峰 on 15/11/19.
//  Copyright © 2015年 张林峰. All rights reserved.
//

#import "NSOperationViewController.h"

@interface NSOperationViewController ()

@end

@implementation NSOperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//从打印结果看，会阻塞当前线程（NSInvocationOperation 这种不是类型安全的,苹果在swift里不用它了）
- (IBAction)NSInvocationOperationClick:(id)sender {
    //1.创建NSInvocationOperation对象
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(myTask) object:nil];
    operation.completionBlock = ^() {
        NSLog(@"执行完毕");
    };
    //2.在当前线程执行
    [operation start];
    NSLog(@"阻塞我没有？当前线程%@",[NSThread currentThread]);
}

//从打印结果看，会阻塞当前线程
- (IBAction)NSBlockOperationClick:(id)sender {
    //1.创建NSBlockOperation对象
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [self myTask];
    }];
    
    //2.也可以添加多个Block,通过这个方法可以给 Operation 添加多个执行 Block。这样 Operation 中的任务 会并发执行，它会 在主线程和其它的多个线程 执行这些任务
    for (NSInteger n = 0; n < 3; n++) {
        [operation addExecutionBlock:^{
            for (NSInteger i = 0; i < 500000000; i++) {
                if (i == 0) {
                    NSLog(@"任务%ld -> 开始",n);
                }
                if (i == 499999999) {
                    NSLog(@"任务%ld -> 完成",n);
                }
            }
        }];
    }
    operation.completionBlock = ^() {
        NSLog(@"执行完毕");
    };
    //3.开始任务
    [operation start];
    NSLog(@"阻塞我没有？当前线程%@",[NSThread currentThread]);
}

//主队列
- (IBAction)mainQueue:(id)sender {
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    //创建NSBlockOperation对象
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [self myTask];
    }];
    for (NSInteger n = 0; n < 3; n++) {
        [operation addExecutionBlock:^{
            for (NSInteger i = 0; i < 500000000; i++) {
                if (i == 0) {
                    NSLog(@"主队列中任务%ld -> 开始%@",n,[NSThread currentThread]);
                }
                if (i == 499999999) {
                    NSLog(@"主队列中任务%ld -> 完成",n);
                }
            }
        }];
    }
    operation.completionBlock = ^() {
        NSLog(@"执行完毕");
    };
    //加入到队列中任务自动执行
    [queue addOperation:operation];
    NSLog(@"阻塞我没有？当前线程%@",[NSThread currentThread]);
}

//自定义的Queue
- (IBAction)otherQueue:(id)sender {
    //1.创建一个其他队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    //最大并发数，用来设置最多可以让多少个operation同时执行。当你把它设置为 1 的时候，就是串行了(指多个operation的串行，如果一个operation中有多个block任务，这几个block会并发执行)
    queue.maxConcurrentOperationCount = 1;
    
    //2.创建NSBlockOperation对象
    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        for (NSInteger i = 0; i < 500000000; i++) {
            if (i == 0) {
                NSLog(@"operation1中任务1 -> 开始");
            }
            if (i == 499999999) {
                NSLog(@"operation1中任务1 -> 完成");
            }
        }
    }];
    
    //3.给operation1再加一个任务
    [operation1 addExecutionBlock:^{
        for (NSInteger i = 0; i < 500000000; i++) {
            if (i == 0) {
                NSLog(@"operation1中任务2 -> 开始");
            }
            if (i == 499999999) {
                NSLog(@"operation1中任务2 -> 完成");
            }
        }
    }];
    operation1.completionBlock = ^() {
        NSLog(@"执行完毕");
    };
    
    //4.再加一个operation2
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        for (NSInteger i = 0; i < 500000000; i++) {
            if (i == 0) {
                NSLog(@"operation2中任务 -> 开始");
            }
            if (i == 499999999) {
                NSLog(@"operation2中任务 -> 完成");
            }
        }
    }];
    
    //5.加入到队列中任务自动执行,waitUntilFinished为yes会阻塞当前线程，为no不阻塞
    [queue addOperations:@[operation1,operation2] waitUntilFinished:NO];
    NSLog(@"阻塞我没有？当前线程%@",[NSThread currentThread]);
}

//queue添加任务
- (IBAction)addTaskToQueue:(id)sender {
    //1.创建一个其他队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    //2.创建NSBlockOperation对象
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [self myTask];
    }];
    
    //3.加入到队列中任务自动执行
    [queue addOperation:operation];
    
    //4.给queue添加任务，注意不是给NSBlockOperation添加任务
    [queue addOperationWithBlock:^{
        for (NSInteger i = 0; i < 500000000; i++) {
            if (i == 0) {
                NSLog(@"queue添加的任务 -> 开始");
            }
            if (i == 499999999) {
                NSLog(@"queue添加的任务 -> 完成");
            }
        }
    }];
    operation.completionBlock = ^() {
        NSLog(@"执行完毕");
    };
    NSLog(@"阻塞我没有？当前线程%@",[NSThread currentThread]);
}

//任务依赖，任务一完成的情况下才能执行任务二，任务二完成的情况下才能执行任务三
- (IBAction)addDependency:(id)sender {
    //1.任务一
    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"任务1开始");
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"任务1完成");
    }];
    //2.任务二
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"任务2开始");
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"任务2完成");
    }];
    //3.任务三
    NSBlockOperation *operation3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"任务3开始");
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"任务3完成");
    }];
    //4.设置依赖
    [operation2 addDependency:operation1];      //任务二依赖任务一
    [operation3 addDependency:operation2];      //任务三依赖任务二
    //5.创建队列并加入任务
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperations:@[operation3, operation2, operation1] waitUntilFinished:NO];
}

//模拟很耗时的任务
-(void)myTask {
    for (NSInteger i = 0; i < 500000000; i++) {
        if (i == 0) {
            NSLog(@"任务 -> 开始");
        }
        if (i == 499999999) {
            NSLog(@"任务 -> 完成");
        }
    }
}

/*
// 暂停queue
[queue setSuspended:YES];

// 继续queue
[queue setSuspended:NO];
 会阻塞当前线程，等到某个operation执行完毕
[operation waitUntilFinished];
// 阻塞当前线程，等待queue的所有操作执行完毕
[queue waitUntilAllOperationsAreFinished];
// 取消单个操作
[operation cancel];
// 取消queue中所有的操作
[queue cancelAllOperations];
 */

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
