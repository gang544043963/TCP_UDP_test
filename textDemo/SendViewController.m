//
//  SendViewController.m
//  textDemo
//
//  Created by dadahua on 16/9/25.
//  Copyright © 2016年 dahua. All rights reserved.
//

#import "SendViewController.h"
#import "GCDAsyncUdpSocket.h"
#define CLIENTPORT 2415
#define SERVERPORT 12414

/**
 *  客户端
 */
@interface SendViewController ()<GCDAsyncUdpSocketDelegate>
{
    GCDAsyncUdpSocket *clientSocket;
    __weak IBOutlet UITextField *msgTF;
    __weak IBOutlet UITextField *ipTF;
    IBOutlet UITextField *receivedMsg;
}

@property (nonatomic, copy) NSString *UDPHost;
@property (nonatomic, assign) NSUInteger UDPPort;
@property (nonatomic, copy) NSString *serverMacStr;

@end

@implementation SendViewController


- (void)dealloc {
    [clientSocket close];
    clientSocket = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"客户端";
    
    clientSocket = [self loadClientSocket];
}

#pragma mark 发送消息
- (IBAction)sendMsgClick:(UIButton *)sender {
    [self UDPBroadcast];
}



#pragma mark - delegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    NSLog(@"client发送失败-->%@",error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    
    _serverMacStr = [self getMacFromData:data];
    
    NSString *receiveStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"服务器ip地址--->%@,host---%u,内容--->%@",
          [GCDAsyncUdpSocket hostFromAddress:address],
          [GCDAsyncUdpSocket portFromAddress:address],
          receiveStr);
    _UDPHost = [GCDAsyncUdpSocket hostFromAddress:address];
    _UDPPort = [GCDAsyncUdpSocket portFromAddress:address];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        receivedMsg.text = receiveStr;
    });
}

//MARK: - Private

- (GCDAsyncUdpSocket *)loadClientSocket {
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
    
    [clientSocket sendData:sendData
                  toHost:@"255.255.255.255"
                    port:SERVERPORT
             withTimeout:60
                     tag:200];
}

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

@end
