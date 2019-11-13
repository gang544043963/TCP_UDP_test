//
//  SocketService.h
//  textDemo
//
//  Created by ethan li on 2019/11/13.
//  Copyright © 2019 dahua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SocketServiceDelegate <NSObject>

- (void)UDPDidReceiveData:(NSString *)serverMac deviceHost:(NSString *)deviceHost devicePort:(uint16_t)devicePort;

- (void)TCPDidReceiveData:(DeviceDataModel *)deviceDataModel;

@end

@interface SocketService : NSObject

@property (nonatomic, weak) id<SocketServiceDelegate> delegate;

+ (instancetype)sharedService;

- (void)scan;

- (BOOL)tcpConnect:(NSString *)mac host:(NSString *)host;

- (void)disconnect:(NSString *)socketId;

- (void)query:(NSString *)socketId;

- (void)control:(NSString *)socketId data:(DeviceDataModel *)deviceData;

@end

NS_ASSUME_NONNULL_END
