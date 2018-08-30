//
//  HoriMapViewController.m
//  施工端地图(百度)
//
//  Created by owen on 2018/7/30.
//  Copyright © 2018年 owen. All rights reserved.
//

#import "HoriMapViewController.h"
#import "HoriMapTipView.h"
#import "HoriMapSearchListViewController.h"
#import "HoriMapSearchBarView.h"

/**
 引入百度地图所需头文件
 */
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>//引入云检索功能所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件

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



@interface HoriMapViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,BMKPoiSearchDelegate,UISearchBarDelegate,HoriMapSearchBarViewDelegate,HoriMapTipViewDelegate>


/**
 定位
 */
@property (nonatomic,strong) BMKLocationService *locService;

/**
 geo搜索服务
 */
@property (nonatomic,strong) BMKGeoCodeSearch *geocodesearch;


/**
 定位的图标
 */
@property (nonatomic,strong) UIImageView *poiView;

/**
 基础地图
 */
@property (nonatomic,strong) BMKMapView *mapView;


/**
 提示信息Viwe
 */
@property (nonatomic,strong) HoriMapTipView *mapTipView;


/**
 搜索列表
 */
@property (nonatomic,strong) HoriMapSearchListViewController *mapSearchController;

/**
 导航搜索栏
 */
@property (nonatomic,strong) HoriMapSearchBarView *searchView;


/**
 存档当前经纬度信息坐标数组
 */
@property (nonatomic,strong) NSMutableArray *locationArray;

@end

@implementation HoriMapViewController



- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]init];
    
 
    
    //添加导航搜索栏
    [self.navigationController.view addSubview:self.searchView];
    
    [self initMapParams];
    [self initPoiViewAndGetLocationBtn];
    //定位功能可用，开始定位
    [self setLocation];
    [self startLocation];
    [self initLocation];
    [self initMapTipView];
    
    //初始化放在这里,push之后还要刷新,所以不执行viewWillDisappear = nil
    [_mapView viewWillAppear];
    _mapView.delegate = self;
    _geocodesearch.delegate = self;
    _locationArray = [NSMutableArray array];
}



#pragma mark 初始化提示View,显示当前定位信息
-(void)initMapTipView{
    
    self.mapTipView = [[HoriMapTipView alloc]initWithFrame:CGRectMake(Width(42), SCREEN_HEIGHT-Height(300)-Height(42)-64, SCREEN_WIDTH-Width(48)-Width(42), Height(300))];
    self.mapTipView.delegate = self;
    [self.mapView addSubview:self.mapTipView];
}

#pragma mark 初始化固定图标/回到当前定位按钮
-(void)initPoiViewAndGetLocationBtn{

    //固定图标
    UIImageView *poiView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"poi"]];
    poiView.frame = CGRectMake(0, 0, 40, 40);
    poiView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    [self.mapView addSubview:poiView];
    _poiView = poiView;
    
    //回到原来定位按钮
    UIButton *getLocationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    getLocationBtn.frame = CGRectMake(Width(42), SCREEN_HEIGHT/1.5, 40, 40);
    [getLocationBtn setBackgroundImage:[UIImage imageNamed:@"dingwei"] forState:UIControlStateNormal];
    [getLocationBtn addTarget:self action:@selector(currentAddressMsg:) forControlEvents:UIControlEventTouchUpInside];
    [_mapView addSubview:getLocationBtn];
    
    
}

#pragma mark 跳转到搜索页面 (代理)
-(void)jumpToSearchListViewController{
    
    self.mapSearchController = [[HoriMapSearchListViewController alloc]init];
    self.mapSearchController.searchListCity = self.mapTipView.nameLabel.text;
    [self.navigationController pushViewController:self.mapSearchController animated:YES];
    
    //对信息重新赋值
    __weak typeof(self)WeakSelf = self;
    self.mapSearchController.mapSearchBlock = ^(NSString *name, NSString *address, NSString *longitude, NSString *latitude) {
        __strong typeof(WeakSelf)StrongSelf = WeakSelf;
        CLLocationCoordinate2D  pt = (CLLocationCoordinate2D){[latitude doubleValue],[longitude doubleValue]};
        [StrongSelf.mapView setCenterCoordinate:pt animated:YES];
        [StrongSelf changeMapTipViewValue:name Address:address];
    };

}

#pragma mark 返回设备详情页面 (代理)
-(void)popViewToDeviceDetailsController{
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 点击确定 (代理)
-(void)backDeviceDetailsAndSettingLocationInfo{
    
}


#pragma mark 懒加载导航搜索栏
-(HoriMapSearchBarView *)searchView{
    
    if (!_searchView) {
        _searchView = [[HoriMapSearchBarView alloc]initWithFrame:CGRectMake(0, 0,  self.navigationController.view.bounds.size.width, 64)];
        _searchView.delegate = self;
    }
    return _searchView;
}


#pragma mark 随时变化的地址和位置信息
-(void)changeMapTipViewValue:(NSString *)name Address:(NSString *)address{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
        
        self.mapTipView.nameLabel.text = name;
        self.mapTipView.addressLabel.text = address;
    });
   
}


#pragma mark 初始化地图/图层/搜索相关参数
-(void)initMapParams{
    
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    
    //初始化mapView
    self.mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
    _mapView.zoomLevel = 19.5;
    _mapView.delegate = self;
    
    
    
    BMKLocationViewDisplayParam *displayParam = [[BMKLocationViewDisplayParam alloc]init];
    displayParam.isRotateAngleValid = false;//跟随态旋转角度是否生效
    displayParam.isAccuracyCircleShow = false;//精度圈是否显示
    [_mapView updateLocationViewWithParam:displayParam];
}


#pragma mark 设置定位参数
- (void)setLocation
{
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    //设置定位精度
    _locService.desiredAccuracy = kCLLocationAccuracyBest;
    CLLocationDistance distance = 10.0;
    _locService.distanceFilter = distance;
    
}


#pragma mark 开始定位
- (void)startLocation{
    
    [_locService startUserLocationService];
}


#pragma mark 回到当前定位
- (void)currentAddressMsg:(UIButton *)sender{
    
    NSLog(@"回到当前定位");
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    _locService.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    //启动LocationService
    [_locService startUserLocationService];
    
}



- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation{
    
    static NSString *pinID = @"pinID";
    // 从缓存池取出大头针数据视图
    BMKAnnotationView *customView = [mapView dequeueReusableAnnotationViewWithIdentifier:pinID];
    // 如果取出的为nil , 那么就手动创建大头针视图
    if (customView == nil) {
        customView = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinID];
    }
    // 1. 设置大头针图片
    customView.image = [UIImage imageNamed:@"point"];
    // 2. 设置弹框
    customView.canShowCallout = YES;
    
    return customView;
}
/**
 *地图区域改变完成后会调用此接口
 *@param mapView 地图View
 *@param animated 是否动画
 */
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"%lf -------  %lf",mapView.centerCoordinate.latitude,mapView.centerCoordinate.longitude);
    
    __weak typeof(self)WeakSelf = self;
    [UIView animateWithDuration:0.3 delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        __strong typeof(WeakSelf)StrongSelf = WeakSelf;
        StrongSelf.poiView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, 150 - 35);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            __strong typeof(WeakSelf)StrongSelf = WeakSelf;
            StrongSelf.poiView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, 150 - 20);
        } completion:nil];
        
    }];
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){0, 0};
    pt = (CLLocationCoordinate2D){mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude};
    BMKReverseGeoCodeSearchOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeSearchOption alloc]init];
    reverseGeocodeSearchOption.location = pt;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
        NSLog(@"regionDidChangeAnimated:反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送成功");
    }
}

/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
-(void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error{
    
        if (error == BMK_SEARCH_NO_ERROR) {
            for (int i = 0; i < result.poiList.count; i++) {//result.poiList.count 这里只需要拿一个信息就可以
                 BMKPoiInfo* poi = [result.poiList objectAtIndex:i];
//                 NSLog(@"%@--%@",poi.name,poi.address);
                
                //保存当前经纬度
                NSMutableArray *arry = [NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%f",poi.pt.longitude],[NSString stringWithFormat:@"%f",poi.pt.latitude], nil];
                _locationArray = arry;
                [self changeMapTipViewValue:poi.name Address:poi.address];
            }
    
        } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
            NSLog(@"起始点有歧义");
        } else {
            // 各种情况的判断。。。
        }
}



/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [self.view addSubview:self.mapView];
   
    
    __weak typeof(self)WeakSelf = self;
    [UIView animateWithDuration:0.3 delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        __strong typeof(WeakSelf)StrongSelf = WeakSelf;
        StrongSelf.poiView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, 150 - 35);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            __strong typeof(WeakSelf)StrongSelf = WeakSelf;
            StrongSelf.poiView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, 150 - 20);
        } completion:nil];
        
    }];
    

    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){0, 0};
    pt = (CLLocationCoordinate2D){userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude};
    BMKReverseGeoCodeSearchOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeSearchOption alloc]init];
    reverseGeocodeSearchOption.location = pt;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
        NSLog(@"didUpdateBMKUserLocation:反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送成功");
    }
    [_mapView updateLocationData:userLocation];
    [_mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    [_locService stopUserLocationService];
}

/**
 定位失败
 
 @param error 定位失败后的错误信息   根据错误信息判断失败的原因
 */
- (void)didFailToLocateUserWithError:(NSError *)error{
//    //无法获取位置信息
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
    [_locService stopUserLocationService];
    
}

/**
 判断定位是否可用并且初始化定位信息
 */
- (void)initLocation{
    if ([CLLocationManager locationServicesEnabled] &&
        ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways
         || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)) {
            //定位功能可用，开始定位
            [self setLocation];
            [self startLocation];
            
        }else if (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) || ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusRestricted)){
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
}
/**
 管理百度地图的生命周期
 */
- (void)viewWillAppear:(BOOL)animated{

    self.searchView.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated{

    self.searchView.hidden = YES;

}



@end
