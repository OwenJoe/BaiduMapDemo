//
//  HoriSearchViewBarView.m
//  iOS-CommunityFactory
//
//  Created by owen on 2018/7/24.
//  Copyright © 2018年 chenjiangchuan. All rights reserved.
//

#import "HoriSearchViewBarView.h"
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

@interface HoriSearchViewBarView ()<UITextFieldDelegate>

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
 搜索的内容
 */
@property (nonatomic,strong) UITextField *searchField;


/**
 清除图标
 */
@property (nonatomic,strong) UIImageView *cleanImgView;


/**
 退出按钮
 */
@property (nonatomic,strong) UIButton *cancleButton;

@end

@implementation HoriSearchViewBarView

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
    
    self.searchField = [[UITextField alloc]init];
    self.searchField.delegate = self;
    [self addSubview:self.searchField];
    
    self.cleanImgView = [[UIImageView alloc]init];
    [self addSubview:self.cleanImgView];
    
    self.cancleButton = [[UIButton alloc]init];
    [self addSubview:self.cancleButton];
}

#pragma mark 布局
-(void)setUpSearchView{
    
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(Width(42));
        make.right.mas_equalTo(-Width(180));
        make.height.mas_equalTo(Height(90));
        make.bottom.mas_equalTo(-Height(22));
    }];
    
    [self.icoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(Width(42), Height(42)));
        make.centerY.mas_equalTo(self.searchView.mas_centerY);
        make.left.mas_equalTo(self.searchView.mas_left).offset(Width(42));
    }];
    
    [self.searchField mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.mas_equalTo(self.searchView.mas_centerY);
        make.left.mas_equalTo(self.icoImgView.mas_right).offset(Width(42));
        make.right.mas_equalTo(self.searchView.mas_right).offset(-Width(90));
    }];
    
    [self.searchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.mas_equalTo(self.searchView.mas_centerY);
        make.left.mas_equalTo(self.icoImgView.mas_right).offset(Width(42));
    }];
    
    [self.cleanImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.mas_equalTo(self.searchView.mas_centerY);
        make.right.mas_equalTo(self.searchView.mas_right).offset(-Width(42));
        make.size.mas_equalTo(CGSizeMake(Width(48), Height(48)));
    }];
    
    
    [self.cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.mas_equalTo(self.searchView.mas_centerY);
        make.right.mas_equalTo(self.mas_right).offset(0);
        make.left.mas_equalTo(self.searchView.mas_right).offset(Width(0));
//        make.size.mas_equalTo(CGSizeMake(Width(48), Height(42)));
    }];
    
}

#pragma mark 赋值
-(void)setUpSearchViewContent{
    
    self.searchView.backgroundColor = [UIColor whiteColor];
    self.searchView.layer.masksToBounds = YES;
    self.searchView.layer.cornerRadius = Height(20);
   
    
    self.icoImgView.image = [UIImage imageNamed:@"btn_ic_search"];
    
    self.cleanImgView.image = [UIImage imageNamed:@"btn_ic_close"];
    self.cleanImgView.hidden = YES;
    self.cleanImgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cleanImgViewTap:)];
    [self.cleanImgView addGestureRecognizer:tap];
    
    
    self.searchLabel.text = @"搜索";
    self.searchLabel.textColor = [UIColor blackColor];
    self.searchLabel.font = [UIFont systemFontOfSize:Font(42)];
    

    [self.searchField addTarget:self action:@selector(searchFieldClick:) forControlEvents:UIControlEventEditingChanged];
    self.searchField.returnKeyType = UIReturnKeySearch;
    
    [self.cancleButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancleButton addTarget:self action:@selector(cancleButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.cancleButton.titleLabel.font = [UIFont systemFontOfSize:Font(48)];
}


#pragma mark 清除内容
-(void)cleanImgViewTap:(UITapGestureRecognizer *)tap{
    [self.searchField resignFirstResponder];
    UITextField *field =  [[UITextField alloc]init];
    field.text = @"";
    [self searchFieldClick:field];
    self.searchField.text = @"";
}


#pragma mark 获取输入的内容
-(void)searchFieldClick:(UITextField *)field{
    
    if ([field text].length>0) {
        self.searchLabel.hidden = YES;
        self.cleanImgView.hidden = NO;
    }
    else{
        
        self.searchLabel.hidden = NO;
        self.cleanImgView.hidden = YES;
    }
}


//搜索虚拟键盘响应
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    NSLog(@"点击了搜索:%@",[textField text]);
    
    [self.searchField resignFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(backKeyWord:)]) {
        
        [self.delegate backKeyWord:[textField text]];
    }
    
    return YES;
    
}




#pragma mark 返回上一页
-(void)cancleButtonClick:(UIButton *)sender{
  
    if ([self.delegate respondsToSelector:@selector(backController)]) {
        [self.delegate backController];
    }
}


@end
