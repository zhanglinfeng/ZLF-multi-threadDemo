//
//  NSThreadViewController.m
//  ZLF-multi-threadDemo
//
//  Created by 张林峰 on 15/11/19.
//  Copyright © 2015年 张林峰. All rights reserved.
//

#import "NSThreadViewController.h"

@interface NSThreadViewController ()
{
    NSInteger tickets;//剩余票数
    NSInteger sellNum;//卖出票数
    NSThread* thread1;//买票线程1
    NSThread* thread2;//买票线程2
    NSLock *theLock;//锁
}
@property (nonatomic, strong) NSThread* myThread;
@end

@implementation NSThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//开始
- (IBAction)start:(id)sender {
    //实例方法开始
    _myThread = [[NSThread alloc]initWithTarget:self selector:@selector(startCount) object:nil];
    [_myThread start];
    
    //静态方法开始
//    [NSThread detachNewThreadSelector:@selector(startCount) toTarget:self withObject:nil];
    
    //隐式开始
//    [self performSelectorInBackground:@selector(startCount) withObject:nil];
}

//计时
-(void)startCount {
    for (NSInteger i = 0; i< 1000; i++) {
        //根据线程是否取消的标志位退出该任务
        if (_myThread.cancelled) {
            return;
        }
        [NSThread sleepForTimeInterval:1.0f];
        NSLog(@"%ld",i);
    }
    
}

//取消线程
- (IBAction)cancel:(id)sender {
    //并没有真正取消该线程，只是给该线程设置了一个标志位
    [_myThread cancel];
}

//当前线程做某事
- (IBAction)doSomething:(id)sender {
    NSLog(@"当前线程%@",[NSThread currentThread]);
    [self performSelector:@selector(myTask) withObject:nil];
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

//线程通信
- (IBAction)communication:(id)sender {
    //开一个子线程执行某任务，完成后回到主线程更新UI，实现线程通信
    [NSThread detachNewThreadSelector:@selector(communicationTask) toTarget:self withObject:nil];
}

//线程通信任务
- (void)communicationTask {
    NSLog(@"当前线程%@",[NSThread currentThread]);
    //模拟一个3秒的任务，完成后到主线程更新UI
    [NSThread sleepForTimeInterval:3];
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:[UIColor redColor] waitUntilDone:YES];
    
}

//更新UI
- (void)updateUI:(UIColor *)color {
    self.view.backgroundColor = color;
    NSLog(@"我变红了");
}


//延时3s
- (IBAction)delay:(id)sender {
    NSLog(@"开始延时");
    // 暂停3s
    [NSThread sleepForTimeInterval:3];//延时当前线程
    NSLog(@"延时结束");
    
    // 或者
    //    NSDate *date = [NSDate dateWithTimeInterval:2 sinceDate:[NSDate date]];
    //    [NSThread sleepUntilDate:date];
    
    
}


//（线程同步）2人抢票
- (IBAction)twoPeopleBuy:(id)sender {
    
    tickets = 9;
    sellNum = 0;
    theLock = [[NSLock alloc] init];
 
    thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(buy) object:nil];
    [thread1 setName:@"Thread-1"];
    [thread1 start];
    
    
    thread2 = [[NSThread alloc] initWithTarget:self selector:@selector(buy) object:nil];
    [thread2 setName:@"Thread-2"];
    [thread2 start];
}

//买票
-(void)buy{
    while (TRUE) {
        //上锁
        [theLock lock];
        if(tickets >= 0){
            [NSThread sleepForTimeInterval:0.09];
            sellNum = 9 - tickets;
            NSLog(@"当前票数是:%ld,售出:%ld,线程名:%@",tickets,sellNum,[[NSThread currentThread] name]);
            tickets--;
        }else{
            break;
        }
        [theLock unlock];
    }
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
