//
//  HoriSearchViewBarView.h
//  iOS-CommunityFactory
//
//  Created by owen on 2018/7/24.
//  Copyright © 2018年 chenjiangchuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HoriSearchViewBarView;

@protocol HoriSearchViewBarViewDelegate <NSObject>


/**
 返回关键词(代理方法)

 @param key 关键词
 */
-(void)backKeyWord:(NSString *)key;


/**
 返回上一页
 */
-(void)backController;

@end

@interface HoriSearchViewBarView : UIView


@property (nonatomic,strong) id<HoriSearchViewBarViewDelegate>delegate;

@end
