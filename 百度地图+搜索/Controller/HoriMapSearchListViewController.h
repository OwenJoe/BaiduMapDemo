//
//  HoriMapSearchListViewController.h
//  施工端地图(百度)
//
//  Created by owen on 2018/7/30.
//  Copyright © 2018年 owen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MapSearchBlock)(NSString *name,NSString *address,NSString *longitude,NSString *latitude);
@interface HoriMapSearchListViewController : UIViewController

/**
 名称/地址/经纬度 block
 */
@property (nonatomic,copy) MapSearchBlock mapSearchBlock;

/**
 当前城市
 */
@property (nonatomic,strong) NSString *searchListCity;

@end
