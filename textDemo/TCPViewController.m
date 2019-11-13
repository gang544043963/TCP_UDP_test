//
//  TCPViewController.m
//  textDemo
//
//  Created by ethan li on 2019/10/31.
//  Copyright © 2019 dahua. All rights reserved.
//

#import "TCPViewController.h"
#import "GCDAsyncSocket.h"

#define TCP_SERVER_PORT 12416

@interface TCPViewController () <GCDAsyncSocketDelegate>

@property (strong, nonatomic) IBOutlet UITextField *inputField;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;

@property (nonatomic, strong) GCDAsyncSocket *TCPsocket;

// UDP广播之后，模组传回来的
@property (nonatomic, copy) NSString *host;
@property (nonatomic, assign) NSInteger port;

@end

@implementation TCPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createTCPSocket];
}

- (void)createTCPSocket {
    // 创建socket
    if (self.TCPsocket == nil) {
        // 并发队列，这个队列将影响delegate回调,但里面是同步函数！保证数据不混乱，一条一条来
        // 这里最好是写自己并发队列
        dispatch_queue_t qQueue = dispatch_queue_create("TCP_queue", NULL);
        self.TCPsocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:qQueue];
    }
    // 连接socket
    if (!self.TCPsocket.isConnected){
        NSError *error;
        [self.TCPsocket connectToHost:@"192.168.0.104" onPort:2419 withTimeout:-1 error:&error];
        if (error) NSLog(@"connect error:%@",error);
    }
}
- (IBAction)sendMessage:(id)sender {
    
}


//MARK: -

//已经连接到服务器
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(nonnull NSString *)host port:(uint16_t)port{
    NSLog(@"连接成功 : %@---%d",host,port);
    //连接成功或者收到消息，必须开始read，否则将无法收到消息,
    //不read的话，缓存区将会被关闭
    // -1 表示无限时长 ,永久不失效
    [self.TCPsocket readDataWithTimeout:-1 tag:10086];
}

// 连接断开
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"断开 socket连接 原因:%@",err);
}

//已经接收服务器返回来的数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"接收到tag = %ld : %ld 长度的数据",tag,data.length);
    //连接成功或者收到消息，必须开始read，否则将无法收到消息
    //不read的话，缓存区将会被关闭
    // -1 表示无限时长 ， tag
    [self.TCPsocket readDataWithTimeout:-1 tag:10086];
}

//消息发送成功 代理函数 向服务器 发送消息
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"%ld 发送数据成功",tag);
}

@end
