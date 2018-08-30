//
//  HoriDeviceSearchView.h
//  iOS-CommunityFactory
//
//  Created by owen on 2018/7/24.
//  Copyright © 2018年 chenjiangchuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HoriMapSearchBarView;
@protocol HoriMapSearchBarViewDelegate <NSObject>


/**
 跳到历史搜索页面(代理)
 */
-(void)jumpToSearchListViewController;


/**
 返回到设备详情
 */
-(void)popViewToDeviceDetailsController;

@end

@interface HoriMapSearchBarView : UIView

@property (nonatomic,weak) id <HoriMapSearchBarViewDelegate>delegate;
@end
