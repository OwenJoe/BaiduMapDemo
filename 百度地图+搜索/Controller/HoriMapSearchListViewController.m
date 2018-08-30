//
//  HoriMapSearchListViewController.m
//  施工端地图(百度)
//
//  Created by owen on 2018/7/30.
//  Copyright © 2018年 owen. All rights reserved.
//

#import "HoriMapSearchListViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import "HoriSearchViewBarView.h"

@interface HoriMapSearchListViewController ()<UITableViewDelegate,UITableViewDataSource, BMKPoiSearchDelegate,UISearchBarDelegate,HoriSearchViewBarViewDelegate>


/**
 搜索
 */
@property (nonatomic,strong)BMKPoiSearch *poisearch;


/**
 页码 搜索数量
 */
@property (nonatomic,assign) int curPage;


/**
 搜索出来的数组(名称)
 */
@property (nonatomic,strong) NSMutableArray *listArray;

/**
 搜索出来的数组(地点)
 */
@property (nonatomic,strong) NSMutableArray *addressAarray;


/**
 结果列表
 */
@property (nonatomic,strong) UITableView *mapSearchListTableView;


/**
 导航栏搜索
 */
@property (nonatomic,strong) UISearchBar *searchbar;




/**
 当前经度数组
 */
@property (nonatomic,strong) NSMutableArray *longitudeArray;

/**
 当前纬度数组
 */
@property (nonatomic,strong) NSMutableArray *latitudeArray;

/**
 导航栏搜索
 */
@property (nonatomic,strong) HoriSearchViewBarView *searchBarView;

@end

static NSString *const ID = @"cell";

@implementation HoriMapSearchListViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]init];
    //添加导航搜索栏
    [self.navigationController.view addSubview:self.searchBarView];
    
    
    _poisearch = [[BMKPoiSearch alloc]init];
    _listArray = [NSMutableArray array];
    _addressAarray = [NSMutableArray array];
    _longitudeArray = [NSMutableArray array];
    _latitudeArray = [NSMutableArray array];
    [self.view addSubview:self.mapSearchListTableView];
}


#pragma mark 懒加载导航搜索栏
-(HoriSearchViewBarView *)searchBarView{
    
    if (!_searchBarView) {
        _searchBarView = [[HoriSearchViewBarView alloc]initWithFrame:CGRectMake(0, 0,  self.navigationController.view.bounds.size.width, 64)];
        _searchBarView.delegate = self;
    }
    return _searchBarView;
}






#pragma mark 添加关键词到数组 (代理方法)
-(void)backKeyWord:(NSString *)key{
    
    NSLog(@"%@",key);
    [_listArray removeAllObjects];
    [_addressAarray removeAllObjects];
    [self onClickOk:key PageSize:30];
}



-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
    _poisearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    self.searchBarView.hidden = NO;
}

-(void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
    _poisearch.delegate = nil; // 不用时，置nil
    self.searchBarView.hidden = YES;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _listArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    cell.textLabel.text = _listArray[indexPath.row];
    cell.detailTextLabel.text = _addressAarray[indexPath.row];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 68;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"%@--%@",_listArray[indexPath.row],_addressAarray[indexPath.row]);

    if (_mapSearchBlock != nil) {
        
        _mapSearchBlock (_listArray[indexPath.row],_addressAarray[indexPath.row],_longitudeArray[indexPath.row],_latitudeArray[indexPath.row]);
    }

    [self.navigationController popViewControllerAnimated:YES];

}




#pragma mark 列表懒加载
-(UITableView *)mapSearchListTableView{
    
    if (!_mapSearchListTableView) {
        _mapSearchListTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height -64) style:UITableViewStylePlain];
        _mapSearchListTableView.delegate = self;
        _mapSearchListTableView.dataSource = self;
    }
    return _mapSearchListTableView;
}



/******************************添加地图搜索*****************************************/
- (void)dealloc {
    if (_poisearch != nil) {
        _poisearch = nil;
    }

}

/**
 搜索成功

 @param keyWord 关键词
 @param pageSize 搜索数量
 */
-(void)onClickOk:(NSString *)keyWord PageSize:(NSInteger)pageSize
{
    _curPage = 0;
    /*
     curPage++; 这个表示搜索更多,用这个
     */
    BMKPOICitySearchOption *citySearchOption = [[BMKPOICitySearchOption alloc]init];
    citySearchOption.pageIndex = _curPage;
    citySearchOption.pageSize = pageSize;
//    citySearchOption.city= @"广州";
    citySearchOption.city = self.searchListCity;
    citySearchOption.keyword = keyWord;
    BOOL flag = [_poisearch poiSearchInCity:citySearchOption];
    if(flag)
    {

        NSLog(@"城市内检索发送成功");
    }
    else
    {

        NSLog(@"城市内检索发送失败");
    }
    
    
}


#pragma mark -
#pragma mark implement BMKSearchDelegate
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPOISearchResult*)result errorCode:(BMKSearchErrorCode)error
{

    
    if (error == BMK_SEARCH_NO_ERROR) {
        NSMutableArray *annotations = [NSMutableArray array];
        for (int i = 0; i < result.poiInfoList.count; i++) {
            BMKPoiInfo* poi = [result.poiInfoList objectAtIndex:i];
            BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
            item.coordinate = poi.pt;
            item.title = poi.name;
            [annotations addObject:item];
             NSLog(@"搜索列表出来:%@--%@",poi.name,poi.address);
            NSLog(@"经纬度:%f--%f",poi.pt.latitude,poi.pt.longitude);
            [_listArray addObject:poi.name];
            NSString *address = poi.address.length<=0?@"":poi.address;
            [_addressAarray addObject:address];
            [_longitudeArray addObject:[NSString stringWithFormat:@"%f",poi.pt.longitude]];
            [_latitudeArray addObject:[NSString stringWithFormat:@"%f",poi.pt.latitude]];
        }
        
        [self.mapSearchListTableView reloadData];
    } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
        NSLog(@"起始点有歧义");
    } else {
        // 各种情况的判断。。。
    }

}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.searchbar resignFirstResponder];
}


-(void)backController{
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
