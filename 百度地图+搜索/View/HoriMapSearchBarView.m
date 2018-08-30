//
//  HoriDeviceSearchView.m
//  iOS-CommunityFactory
//
//  Created by owen on 2018/7/24.
//  Copyright © 2018年 chenjiangchuan. All rights reserved.
//

#import "HoriMapSearchBarView.h"
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

@interface HoriMapSearchBarView ()


/**
 搜索的View
 */
@property (nonatomic,strong) UIView *searchView;


/**
 放大镜
 */
@property (nonatomic,strong) UIImageView *icoImgView;



/**
 文字
 */
@property (nonatomic,strong) UILabel *searchLabel;


/**
 下划线
 */
@property (nonatomic,strong) UIView *linView;


/**
 退出按钮
 */
@property (nonatomic,strong) UIButton *cancelButton;

@end

@implementation HoriMapSearchBarView

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
       
        [self initSearchView];
        [self setUpSearchView];
        [self setUpSearchViewContent];
    }
    return self;
}


#pragma mark 初始化
-(void)initSearchView{
    
    self.searchView = [[UIButton alloc]init];
    [self addSubview:self.searchView];
    
    self.icoImgView = [[UIImageView alloc]init];
    [self addSubview:self.icoImgView];
    
    self.searchLabel = [[UILabel alloc]init];
    [self addSubview:self.searchLabel];
    
    self.linView = [[UIView alloc]init];
    [self addSubview:self.linView];
    
    self.cancelButton = [[UIButton alloc]init];
    [self addSubview:self.cancelButton];
}

#pragma mark 布局
-(void)setUpSearchView{
    
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(Width(42));
        make.right.mas_equalTo (-Width(200));
        make.height.mas_equalTo(Height(90));
        make.bottom.mas_equalTo(-Height(22));
    }];
    
    [self.icoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(Width(42), Height(42)));
        make.centerY.mas_equalTo(self.searchView.mas_centerY);
        make.left.offset(SCREEN_WIDTH/2.2-Width(120));
    }];
    
    [self.searchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.mas_equalTo(self.searchView.mas_centerY);
        //        make.right.mas_equalTo(self.searchView.mas_width).multipliedBy(0.5);
        make.left.offset(SCREEN_WIDTH/2-Width(120));
    }];
    
    [self.linView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.mas_equalTo(self.mas_width);
        make.left.offset(0);
        make.bottom.offset(0);
        make.height.offset(Height(1));
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.size.mas_equalTo(CGSizeMake(Width(150), Height(150)));
        make.centerY.mas_equalTo(self.searchView.mas_centerY);
        make.right.mas_equalTo(self.mas_right).offset(-Width(42));
    }];
}

#pragma mark 赋值
-(void)setUpSearchViewContent{
    
    self.searchView.backgroundColor = [UIColor whiteColor];
    self.searchView.layer.masksToBounds = YES;
    self.searchView.layer.cornerRadius = Height(20);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(searchViewTap:)];
    [self.searchView addGestureRecognizer:tap];
    
    self.icoImgView.image = [UIImage imageNamed:@"btn_ic_search"];
    
    self.searchLabel.text = @"搜索";
    self.searchLabel.textColor = [UIColor blackColor];
    self.searchLabel.font = [UIFont systemFontOfSize:Font(42)];
    
    self.linView.backgroundColor = [UIColor blackColor];
    
//    self.cancelButton.backgroundColor = [UIColor redColor];
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark 返回到设备详情页
-(void)cancelButtonClick:(UIButton *)sender{
    
    if ([self.delegate respondsToSelector:@selector(popViewToDeviceDetailsController)]) {
        
        [self.delegate popViewToDeviceDetailsController];
    }
}

#pragma mark 搜索事件
-(void)searchViewTap:(UITapGestureRecognizer *)tap{
    
    if ([self.delegate respondsToSelector:@selector(jumpToSearchListViewController)]) {
        
        [self.delegate jumpToSearchListViewController];
    }
}







@end
