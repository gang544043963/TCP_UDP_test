//
//  ViewController.m
//  textDemo
//
//  Created by ethan on 19/11/08.
//  Copyright © 2019年 ethan. All rights reserved.
//

#import "ViewController.h"
#import "SocketService.h"

@interface ViewController ()<SocketServiceDelegate>

@property (strong, nonatomic) IBOutlet UILabel *UDPReceivedLabel;

@property (nonatomic, strong) SocketService *socketService;

@end

@implementation ViewController

- (void)dealloc {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"UDP&TCP";
    self.socketService = [SocketService sharedService];
    self.socketService.delegate = self;
}

- (IBAction)UDPTouched:(id)sender {
    [self.socketService scan];
}

- (IBAction)TCPTouched:(id)sender {
    [self.socketService tcpConnect:@"" host:@"192.168.0.103"];
}

- (IBAction)TCPSendData:(id)sender {
    NSLog(@"TCP send button touched");
}

- (IBAction)queryBtnTouched:(id)sender {
    [self.socketService query:@""];
}

//MARK: - SocketServiceDelegate

- (void)UDPDidReceiveData:(NSString *)serverMac deviceHost:(NSString *)deviceHost devicePort:(uint16_t)devicePort {
    self.UDPReceivedLabel.text = [NSString stringWithFormat:@"服务器ip地址--->%@\n host---%lu\n mac地址:%@",
    deviceHost,
    (unsigned long)devicePort, serverMac];
}

- (void)TCPDidReceiveData:(DeviceDataModel *)deviceDataModel {
    
}


@end
