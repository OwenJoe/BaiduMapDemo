//
//  ViewController.m
//  百度地图+搜索
//
//  Created by owen on 2018/8/29.
//  Copyright © 2018年 owen. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "HoriMapViewController.h"
@interface ViewController ()<CLLocationManagerDelegate>
/**
 位置管理器
 */
@property (nonatomic,strong) CLLocationManager *locationManager;


/**
 经度
 */
@property (nonatomic,strong) NSString *latitude;


/**
 纬度
 */
@property (nonatomic,strong) NSString *longitude;

/*经纬度*/
@property (weak, nonatomic) IBOutlet UILabel *latitudeAndLongitudeLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a  nib.
    self.navigationController.navigationBar.barTintColor = [UIColor orangeColor];
    //最先开始就要初始化管理器
    [self initLocationManager];
}


/*自动获取经纬度*/
- (IBAction)autoGet:(id)sender {
    
    [self detailsAlertMapTitle];
}


#pragma mark 初始化地址管理器
-(void)initLocationManager{
    
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        
        UIAlertController *settingAlert = [UIAlertController alertControllerWithTitle:@"" message:@"您无法获取手机位置权限，请前往系统设置中开启" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction= [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *setttingAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            //跳转到定位权限页面
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if( [[UIApplication sharedApplication]canOpenURL:url] ) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
        
        [settingAlert addAction:cancelAction];
        [settingAlert addAction:setttingAction];
        UIViewController *topRootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (topRootViewController.presentedViewController)
        {
            topRootViewController = topRootViewController.presentedViewController;
        }
        [topRootViewController  presentViewController:settingAlert animated:YES completion:nil];
        
    }
    else{
        
        if (nil == _locationManager) {
            _locationManager = [[CLLocationManager alloc]init];
            _locationManager.delegate = self;
            //设置定位精度
            _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            //设置位置更新的最小距离
            _locationManager.distanceFilter = 100.f;
            
            //[_lm requestAlwaysAuthorization];
            [_locationManager requestWhenInUseAuthorization];
        }

        
    }
    
}


#pragma mark - CLLocationManagerDelegate
/**
 获取经纬度范围
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    // 设备的当前位置
    CLLocation *currLocation = [locations firstObject];
    //获取经纬度
    _latitude = [NSString stringWithFormat:@"%3.5f",currLocation.coordinate.latitude];
    _longitude = [NSString stringWithFormat:@"%3.5f",currLocation.coordinate.longitude];
    //中国的经纬度 是东经E 和北纬N
    NSLog(@"经度：%@,纬度：%@",_latitude,_longitude);
    
    self.latitudeAndLongitudeLabel.text = [NSString stringWithFormat:@"%@,%@",_latitude,_longitude];
}


/**
 设备详情弹窗 (经纬度选择)
 
 */
-(void)detailsAlertMapTitle{
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"经纬度" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    // 创建action，这里action1只是方便编写，以后再编程的过程中还是以命名规范为主
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction *autoGetAction = [UIAlertAction actionWithTitle:@"自动获取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //开始定位
        [self backAlertOptionWord:@"自动获取"];
        
    }];
    
    
    UIAlertAction *manualGetAction = [UIAlertAction actionWithTitle:@"手动获取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        // NSLog(@"%@",optionArray[i]);
        [self backAlertOptionWord:@"手动获取"];
    }];
    
    //把action添加到actionSheet里
    [alertController addAction:autoGetAction];
    [alertController addAction:cancleAction];
    [alertController addAction:manualGetAction];

    
    //解决Whose view is not in the window hierarchy报错
    UIViewController *topRootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topRootViewController.presentedViewController)
    {
        topRootViewController = topRootViewController.presentedViewController;
    }
    
    [topRootViewController  presentViewController:alertController animated:YES completion:nil];
    
    //相当于之前的[actionSheet show];
}

#pragma mark 自动获取经纬度
-(void)backAlertOptionWord:(NSString *)optionWord{
    
    //开始定位
    [_locationManager startUpdatingLocation];
}


#pragma mark 跳转到百度地图
- (IBAction)jumpBaiduMap:(id)sender {
    
    HoriMapViewController *mapController = [[HoriMapViewController alloc]init];
    [self.navigationController pushViewController:mapController animated:YES];
}






@end
