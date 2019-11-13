//
//  ViewController.m
//  textDemo
//
//  Created by ethan on 19/11/08.
//  Copyright © 2019年 ethan. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncUdpSocket.h"
#import "GCDAsyncSocket.h"
#import "DeviceDataModel.h"

#define CLIENTPORT 2415
#define SERVERPORT 12414

#define TCP_SERVER_PORT 12416

/**
 *  服务器端
 */
@interface ViewController ()<GCDAsyncUdpSocketDelegate, GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncUdpSocket *UDPClientSocket;
@property (nonatomic, copy) NSString *deviceHost;
@property (nonatomic, assign) NSUInteger devicePort;
@property (nonatomic, copy) NSString *serverMacStr;
@property (strong, nonatomic) IBOutlet UILabel *UDPReceivedLabel;

@property (nonatomic, strong) GCDAsyncSocket *TCPsocket;
@property (strong, nonatomic) IBOutlet UILabel *TCPReceivedLabel;

@end

@implementation ViewController

- (void)dealloc {
    [self.UDPClientSocket close];
    self.UDPClientSocket = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"UDP&TCP";
    self.UDPClientSocket = [self loadUDPClientSocket];
}

- (IBAction)UDPTouched:(id)sender {
    [self UDPBroadcast];
}

- (IBAction)TCPTouched:(id)sender {
    [self createTCPSocketWithHost:@"192.168.0.103" port:TCP_SERVER_PORT];
}

- (IBAction)TCPSendData:(id)sender {
    NSString *str = @"我是一条命令";
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [self.TCPsocket writeData:data withTimeout:-1 tag:100000];
}

- (IBAction)queryBtnTouched:(id)sender {
    [self query];
}

//MARK: - Private

// UDP -------------------------------------------

- (GCDAsyncUdpSocket *)loadUDPClientSocket {
    dispatch_queue_t qQueue = dispatch_queue_create("Client queue", NULL);
    GCDAsyncUdpSocket *theSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                               delegateQueue:qQueue];
    NSError *error;
    [theSocket bindToPort:CLIENTPORT error:&error];
    if (error) {
        NSLog(@"客户端绑定失败");
    }
    
    BOOL result = [theSocket enableBroadcast:YES error:&error];
    if (error || !result) {
        NSLog(@"广播使能失败");
    }
    [theSocket beginReceiving:nil];
    
    return theSocket;
}

- (void)UDPBroadcast {
    Byte byte[9] = {0xAA, 0xAA, 0x06, 0x02, 0xFF, 0xFF, 0xFF, 0x00, 0x59 };
    NSData *sendData = [NSData dataWithBytes:byte length:9];
    
    [self.UDPClientSocket sendData:sendData
                  toHost:@"255.255.255.255"
                    port:SERVERPORT
             withTimeout:60
                     tag:200];
}

// TCP -------------------------------------------

- (void)createTCPSocketWithHost:(NSString*)host port:(NSUInteger)port {
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
        [self.TCPsocket connectToHost:host onPort:port withTimeout:-1 error:&error];
        if (error) NSLog(@"connect error:%@",error);
    }
}

// DATA -------------------------------------------

- (NSString *)getMacFromData:(NSData *)data {
    if (data.length < 15) {
        return nil;
    }
    
    NSString *macStr = @"";
    Byte *theBytes = (Byte *)[data bytes];
    for(int i = 0; i < [data length]; i++) {
        NSLog(@"--%02x\n", theBytes[i]);
        if (i >= 7 && i <= 12) {
            macStr = [macStr stringByAppendingString:[NSString stringWithFormat:@"%02x", theBytes[i]]];
        }
    }
    
    return macStr;
}

- (void)query {
    
    Byte byte[21] = {
        0XAA, 0XAA, 0x12, 0XA0,
        0x0A, 0x0A, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x1A};
    NSData *sendData = [NSData dataWithBytes:byte length:21];
    [self.TCPsocket writeData:sendData withTimeout:-1 tag:10086];
}

#pragma mark - UDP delegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    NSLog(@"client发送失败-->%@",error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    
    _serverMacStr = [self getMacFromData:data];
    _deviceHost = [GCDAsyncUdpSocket hostFromAddress:address];
    _devicePort = [GCDAsyncUdpSocket portFromAddress:address];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.UDPReceivedLabel.text = [NSString stringWithFormat:@"服务器ip地址--->%@\n host---%lu\n mac地址:%@",
                                      _deviceHost,
                                      (unsigned long)_devicePort, _serverMacStr];
        [self createTCPSocketWithHost:_deviceHost port:TCP_SERVER_PORT];
    });
    
    
}

//MARK: - TCP delegate

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
    
    Byte *theBytes = (Byte *)[data bytes];
    for(int i = 0; i < [data length]; i++) {
        NSLog(@"%02x\n  ", theBytes[i]);
    }
    
    DeviceDataModel *deviceModel = [[DeviceDataModel alloc] initWithQueryResult:theBytes];
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
