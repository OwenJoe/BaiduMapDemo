//
//  HoriMapTipView.h
//  施工端地图(百度)
//
//  Created by owen on 2018/7/30.
//  Copyright © 2018年 owen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HoriMapTipView;

@protocol HoriMapTipViewDelegate <NSObject>;


/**
 返回设备详情页面,带上经纬度信息(代理)
 */
-(void)backDeviceDetailsAndSettingLocationInfo;

@end


@interface HoriMapTipView : UIView

@property (nonatomic,weak) id <HoriMapTipViewDelegate>delegate;

/**
 最新名称
 */
@property (nonatomic,strong) UILabel *nameLabel;


/**
 最新地点
 */
@property (nonatomic,strong) UILabel *addressLabel;

@end
