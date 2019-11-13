//
//  DeviceDataModel.m
//  textDemo
//
//  Created by ethan li on 2019/11/9.
//  Copyright © 2019 dahua. All rights reserved.
//

#import "DeviceDataModel.h"

@implementation DeviceDataModel

+ (instancetype)sharedModel {
    static DeviceDataModel *model = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[DeviceDataModel alloc] init];
    });
    return model;
}

- (instancetype)initWithQueryResult:(Byte *)bytes {
    self = [super init];
    if (self) {
        for (int i = 0; i < 10; i++) {
            NSLog(@"---%02x\n  ", bytes[i]);
        }
        if (bytes) {
            UInt8 data3 = (UInt8)(bytes[3] & 0xFF);
            self.superStrong = data3 >> 7;
            self.windLevel = (data3 >> 4) & 0x07;
            self.power = (data3 >> 3) & 0x01;
            self.runMode = data3 & 0x07;
            
            UInt8 data4 = (UInt8)(bytes[4] & 0xFF);
            self.mute = (data4 >> 6) & 0x01;
            self.temperatureMode = (data4 >> 5) & 0x01;
            self.temperature = data4 & 0x1F;
            
            UInt8 data5 = (UInt8)(bytes[5] & 0xFF);
            self.horizontalWind = (data5 >> 4) & 0x0F;
            self.verticalWind = data5 & 0x0F;
            
            UInt8 data6 = (UInt8)(bytes[6] & 0xFF);
            self.lighting = (data6 >> 7) & 0x01;
            self.health = (data6 >> 6) & 0x01;
            self.timerMode = (data6 >> 5) & 0x01;
            self.otherOne = (data6 >> 4) & 0x01;
            self.showMode = (data6 >> 2) & 0x03;
            self.sleepMode = (data6 > 1) & 0x01;
            self.otherTwo = data6 & 0x01;
            
            UInt8 data7 = (UInt8)(bytes[7] & 0xFF);
            self.timerOffPower = (data7 >> 7) & 0x01;
            self.timerOffTimeH3 = (data7 >> 4) & 0x07;
            self.timerOnPower = (data7 >> 3) & 0x01;
            self.timerOnTimeH3 = data7 & 0x07;
            
            UInt8 data8 = (UInt8)(bytes[8] & 0xFF);
            self.timerOnTimeL8 = data8;
            
            UInt8 data9 = (UInt8)(bytes[9] & 0xFF);
            self.timerOffTimeL8 = data9;
            
            UInt8 data10 = (UInt8)(bytes[10] & 0xFF);
            self.nonPolar = data10;
            
        }
    }
    return self;
}

- (NSData *)getBytesData {
    
    UInt8 data3 =
    (self.superStrong & 0x01) << 7
    | (self.windLevel & 0x07) << 4
    | (self.power & 0x01) << 3
    | (self.runMode & 0x07);
    
    UInt8 data4 =
    (self.mute & 0x01) << 6
    | (self.temperatureMode & 0x01) << 5
    | (self.temperature & 0x1f);
    
    UInt8 data5 = (self.horizontalWind & 0x0f) << 4 | (self.verticalWind & 0x0f);
    
    UInt8 data6 =
    (self.lighting & 0x01) << 7
    | (self.health & 0x01) << 6
    | (self.timerMode & 0x01) << 5
    | (self.otherOne & 0x01) << 4
    | (self.showMode & 0x03) << 2
    | (self.sleepMode & 0x01) << 1
    | (self.otherTwo & 0x01);
    
    UInt8 data7 =
    (self.timerOffPower & 0x01) << 7
    | (self.timerOffTimeH3 & 0x07) << 4
    | (self.timerOnPower & 0x01) << 3
    | (self.timerOnTimeH3 & 0x07);
    
    UInt8 data8 = self.timerOnTimeL8 & 0xff;
    UInt8 data9 = self.timerOffTimeL8 & 0xff;
    UInt8 data10 = self.nonPolar & 0xff;
    
    UInt8 protocalVersion = 0x01;//通讯协议版本号
    UInt8 appVersion = 0x01; //手机客户端程序版本号
    UInt8 msg = 0x00; //功能信息
    
    Byte payload[16] = {protocalVersion, appVersion, msg, data3, data4, data5, data6, data7, data8, data9, data10, 0x00, 0x00, 0x00, 0x00, 0x00};
    
    for (int i = 0; i < 16; i++) {
        NSLog(@"---------%02x", payload[i]);
    }
    NSData *data = [NSData dataWithBytes:payload length:16];
    return data;
}


@end
