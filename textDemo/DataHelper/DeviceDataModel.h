//
//  DeviceDataModel.h
//  textDemo
//
//  Created by ethan li on 2019/11/9.
//  Copyright © 2019 dahua. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceDataModel : NSObject

// 超强 1：开启  0：关闭
@property (nonatomic, assign) NSInteger superStrong;
// 内风机风挡位 0:自动风 1:风挡1(低) 2:风挡2(中低) 3:风挡3(中) 4:风挡4(中高) 5:风挡5(高) 6:无极调速
@property (nonatomic, assign) NSInteger windLevel;
// 开关机 1:开机 0:关机
@property (nonatomic, assign) NSInteger power;
// 运行模式 0:自动 1:制冷 2:抽湿 3:送风 4:制热
@property (nonatomic, assign) NSInteger runMode;
// 设定温度
@property (nonatomic, assign) NSInteger temperature;
// 温度模式 1:华氏度 0:摄氏度
@property (nonatomic, assign) NSInteger temperatureMode;
// 静音开关 1:静音开 0:静音关
@property (nonatomic, assign) NSInteger mute;
// 上下扫风功能 0:关 1:15扫风 2:1位置 3:2位置 4:3位置 5:4位置 6:5位置
@property (nonatomic, assign) NSInteger verticalWind;
// 左右扫风功能 0:关 1:同向扫风 2:1位置 3:2位置 4:3位置 5:4位置 6:5位置 7:15位置 8:相向扫风
@property (nonatomic, assign) NSInteger horizontalWind;
// 灯光 1:灯光开 0:灯光关
@property (nonatomic, assign) NSInteger lighting;
// 健康功能 1:打开 0:关闭
@property (nonatomic, assign) NSInteger health;
// 定时模式 1:循环执行 0:单次执行
@property (nonatomic, assign) NSInteger timerMode;
/*
 制冷或除湿模式下:干燥功能 1:打开 0:关闭
 制热模式下:辅热功能 1:打开 0:关闭
*/
@property (nonatomic, assign) NSInteger otherOne;
// 温度显示模式 0:按客户要求显示 1:设定温度显示 2:室内环境温度显示 3:室外环境温度显示
@property (nonatomic, assign) NSInteger showMode;
/*
 制冷模式下:节能及类似功能(ECO) 1:打开 0:关闭
 制热模式下:制热节能功能 1:打开 0:关闭
 其他模式默认发0
 */
@property (nonatomic, assign) NSInteger otherTwo;
// 睡眠功能 1:打开 0:关闭
@property (nonatomic, assign) NSInteger sleepMode;
// 定时关机 1:打开 0:关闭
@property (nonatomic, assign) NSInteger timerOffPower;
// 定时开机 1:打开 0:关闭
@property (nonatomic, assign) NSInteger timerOnPower;
// 无极调速值 1%~100%, 默认60%
@property (nonatomic, assign) NSInteger nonPolar;
// 定时开机时间 高3位
@property (nonatomic, assign) NSInteger timerOnTimeH3;
// 定时开机时间 低8位
@property (nonatomic, assign) NSInteger timerOnTimeL8;
// 定时关机时间 高3位
@property (nonatomic, assign) NSInteger timerOffTimeH3;
// 定时关机时间 低8位
@property (nonatomic, assign) NSInteger timerOffTimeL8;
// 室内环境温度   0.0  整数.小数
@property (nonatomic, assign) NSInteger indoorTemperature;

+ (instancetype)sharedModel;

- (instancetype)initWithQueryResult:(Byte *)bytes;

- (Byte)getBytes;


@end

NS_ASSUME_NONNULL_END
