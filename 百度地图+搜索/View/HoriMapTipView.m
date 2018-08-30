//
//  HoriMapTipView.m
//  施工端地图(百度)
//
//  Created by owen on 2018/7/30.
//  Copyright © 2018年 owen. All rights reserved.
//

#import "HoriMapTipView.h"
#import "Masonry.h"

//屏幕大小,文字大小 换算
#define Height(x)    (x * SCREEN_HEIGHT / IPHONE6Puls_HEIGHT / 3.0)
#define Width(x)     (x * SCREEN_WIDTH  / IPHONE6Puls_WIDTH / 3.0)
#define Font(x)   ((x) * SCREEN_WIDTH / IPHONE6Puls_WIDTH / 3.0)
//根据效果图(6p)组件尺寸,计算各设备上组件尺寸 (返回值是CGFoat)
#define SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define IPHONE6Puls_WIDTH 414
#define IPHONE6Puls_HEIGHT 736

// 设置字体大小
#define SystemFont(size)    [UIFont systemFontOfSize:size]

@implementation HoriMapTipView

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
         self.backgroundColor = [UIColor whiteColor];
        [self setUpTipView];
    }
    return self;
}

#pragma mark 初始化
-(void)setUpTipView{
    
    UIImageView *iconImgView = [[UIImageView alloc]init];
    [self addSubview:iconImgView];
    
    UIButton *sureButton = [[UIButton alloc]init];
    [self addSubview:sureButton];
    
    self.nameLabel = [[UILabel alloc]init];
    [self addSubview:self.nameLabel];
    
    self.addressLabel = [[UILabel alloc]init];
    [self addSubview:self.addressLabel];
    

    [iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.mas_left).offset(Width(42));
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    [sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(self.mas_right).offset(-Width(42));
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(Width(200), Height(300)));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(iconImgView.mas_right);
        make.right.mas_equalTo(sureButton.mas_left);
        make.top.offset(Height(42));
    }];
    
    [self.addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(iconImgView.mas_right);
        make.right.mas_equalTo(sureButton.mas_left);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(0);
        make.bottom.offset(-Height(42));
    }];
    

    iconImgView.image = [UIImage imageNamed:@"poi"];
   
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [sureButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sureButton addTarget:self action:@selector(sureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.nameLabel.textColor = [UIColor blackColor];
    self.nameLabel.font = [UIFont systemFontOfSize:Font(66)];
    self.nameLabel.text = @"大学城餐厅";
    
    self.addressLabel.textColor = [UIColor blackColor];
    self.addressLabel.font = [UIFont systemFontOfSize:Font(56)];
    self.addressLabel.numberOfLines = 0;
    self.addressLabel.text = @"正在定位地址";
}

#pragma mark 确定事件
-(void)sureButtonClick:(UIButton *)click{
    
    if ([self.delegate respondsToSelector:@selector(backDeviceDetailsAndSettingLocationInfo)]) {
        
        [self.delegate backDeviceDetailsAndSettingLocationInfo];
    }
}




@end
