//
//  HomeViewController_ipa.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "HomeViewController_ipa.h"

#import "TopOfHomeScrollView_ipa.h"
#import "LimitPromotionView_ipa.h"
#import "HotGoodsView_ipa.h"
#import "RecommendView_ipa.h"
#import "NewArrivalView_ipa.h"
#import "CategoryView_ipa.h"

#import "GoodsListViewController_ipa.h"
#import "MyWebViewController_ipa.h"
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"
#import "RDVTabBarController.h"

#import "QRCodeReaderDelegate.h"
#import "QRCodeReaderViewController.h"

@interface HomeViewController_ipa ()<EGORefreshTableDelegate,UISearchBarDelegate,QRCodeReaderDelegate,UIAlertViewDelegate,UIScrollViewDelegate,TopOfHomeScrollViewProtocol_ipa, LimitPromotionViewProtocol_ipa, HotGoodsViewProtocol_ipa,RecommendViewProtocol_ipa, NewArrivalViewProtocal_ipa, CategoryViewProtocal_ipa>
{
    UIScrollView * _scrollView;
    
    UIView * _headerView;
    UISearchBar * _searchBar;
    UIButton * _searchMaskBtn;
    
    TopOfHomeScrollView_ipa * _topScrollView;//头条 横向滚动
    LimitPromotionView_ipa * _limitPromotionView;
    HotGoodsView_ipa * _hotGoodView;
    RecommendView_ipa * _recommendView;
    NewArrivalView_ipa * _newArriavalView;
    CategoryView_ipa * _categoryView;
    
    
    bool _hasLimitPromotion;        // 是否有限时打折
    bool _hasHotGoods;              // 是否有热门商品
    bool _hasRecommend;             // 是否有推荐
    bool _hasNewArrival;            // 是否有新品上架
    bool _hasCotecary;              // 是否有最下边的分类
    
    //EGO
    EGORefreshTableHeaderView*  _refreshHeaderView;
    EGORefreshTableFooterView*  _refreshFooterView;
    BOOL                        _reloading;                //  Reloading var should really be your tableviews datasource
    
    // update
    NSString*                   _updateURL;
}

typedef enum
{
    ENUM_START_BTN_TAG      = 11000,
    
    ENUM_QRCODE_URL_BTN_TAG,
    ENUM_QRCODE_TXT_BTN_TAG,
    ENUM_UPDATE_NORMAL_BTN_TAG,
    ENUM_UPDATE_NESSARY_BTN_TAG,
    
    ENUM_END_BTN_TAG
}
ENUM_ALERT_BTN_TAG;

@end

@implementation HomeViewController_ipa

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self initData];
        [self initUI];
        
        [self requestCheckUpdate];
        [self requestData];
    }
    return self;
}

-(void)initData
{
    _hasHotGoods = YES;
    _hasLimitPromotion = YES;
    _hasRecommend = YES;
    _hasNewArrival = YES;
    _hasCotecary = YES;
    _updateURL = nil;
}

-(void)initUI
{
    //self.title = NSLocalizedString(@"Home", nil);
    [self.view setBackgroundColor:[UIColor colorWithRed:238.0/255 green:243.0/255 blue:246.0/255 alpha:1]];
    
    //init ui
    CGRect r = self.view.frame;
    float top = 64;
    float height = 90;
    
    // 整个页面的滚动视图
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, r.size.width, r.size.height-50)];        // 50:底边栏高度
    [_scrollView setBackgroundColor:[UIColor colorWithRed:238.0/255 green:243.0/255 blue:246.0/255 alpha:1]];
    [self.view addSubview:_scrollView];
    [_scrollView setDelegate:self];
    [_scrollView release];
    
    // create the headerView
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(_scrollView.frame.origin.x, _scrollView.frame.origin.y, _scrollView.frame.size.width, _scrollView.contentSize.height)];
    _refreshHeaderView.delegate = self;
    [_scrollView addSubview:_refreshHeaderView];
    [_refreshHeaderView release];
    
    // create the footerView
    _refreshFooterView = [[EGORefreshTableFooterView alloc] initWithFrame:CGRectMake(_scrollView.frame.origin.x, _scrollView.contentSize.height, _scrollView.frame.size.width, _scrollView.contentSize.height)];
    _refreshFooterView.delegate = self;
    [_scrollView addSubview:_refreshFooterView];
    [_refreshFooterView release];
    

    // 搜索时的背景遮罩
    _searchMaskBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, r.size.width, r.size.height)];
    [_searchMaskBtn setBackgroundColor:[UIColor whiteColor]];
    [_searchMaskBtn setAlpha:0.0f];
    [_searchMaskBtn addTarget:self action:@selector(onSearchMaskBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_searchMaskBtn];
    [_searchMaskBtn release];
    
    // header
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, r.size.width, height)];
    [_headerView setBackgroundColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:0.1]];
    [self.view addSubview:_headerView];
    [_headerView release];
    
    UIButton * scanningBtn = [[UIButton alloc] initWithFrame:CGRectMake(8, 28, 50, 50)];
    [scanningBtn setImage:[UIImage imageNamed:@"home_btn_scanning"] forState:UIControlStateNormal];
    [scanningBtn setImage:[UIImage imageNamed:@"home_btn_scanning_gray"] forState:UIControlStateHighlighted];
    [scanningBtn addTarget:self action:@selector(onScanningBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:scanningBtn];
    [scanningBtn release];
    
    UIButton * voiceBtn = [[UIButton alloc] initWithFrame:CGRectMake(r.size.width - 8 - 50, 28, 50, 50)];
    [voiceBtn setImage:[UIImage imageNamed:@"home_btn_voice"] forState:UIControlStateNormal];
    [voiceBtn setImage:[UIImage imageNamed:@"home_btn_voice_gray"] forState:UIControlStateHighlighted];
    [voiceBtn addTarget:self action:@selector(onVoiceBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:voiceBtn];
    [voiceBtn release];
    
    // 搜索按钮
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(60, 25, r.size.width - 60*2, 56)];
    [_searchBar setPlaceholder:NSLocalizedString(@"搜索商品/店铺", nil)];
    [_searchBar setBackgroundColor:[UIColor clearColor]];
    [_searchBar setAlpha:0.8];
    _searchBar.delegate = self;
    _searchBar.keyboardType = UIKeyboardTypeDefault;
    
    [_headerView addSubview:_searchBar];
    [_searchBar release];
    for (UIView *view in _searchBar.subviews) {
        // for before iOS7.0
        if ([view isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [view removeFromSuperview];
            break;
        }
        // for later iOS7.0(include)
        if ([view isKindOfClass:NSClassFromString(@"UIView")] && view.subviews.count > 0) {
            [[view.subviews objectAtIndex:0] removeFromSuperview];
            break;
        }
    }
    

    //首页横向滚动头条
    top = 0;
    height = 400;
    _topScrollView = [[TopOfHomeScrollView_ipa alloc] initWithFrame:CGRectMake(0, top, r.size.width, height)];
    [_scrollView addSubview:_topScrollView];
    [_topScrollView release];
    [_topScrollView setCustomDelegate:self];
    
    //初始化一堆快捷按钮
    {
        top += height;
        height = 90;
        
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, top, r.size.width, height)];
        [view setBackgroundColor:[UIColor whiteColor]];
        [_scrollView addSubview:view];
        [view release];
        
        NSArray * iArr = @[@"home_btn_recharge", @"home_btn_logistics", @"home_btn_wheather", @"home_btn_scanner"];
        NSArray * sArr = @[@"充值", @"物流查询", @"天气查询", @"扫码"];
        
        for (int i = 0; i < [iArr count]; i ++) {
            CGPoint p = CGPointMake(r.size.width / 8 + i * r.size.width / 4, height / 2 - 7);
            
            UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
            [btn setImage:[UIImage imageNamed:iArr[i]] forState:UIControlStateNormal];
            [view addSubview:btn];
            btn.tag = 1000 + i;
            [btn setCenter:p];
            [btn addTarget:self action:@selector(onFunctionalButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [btn release];
            
            p.y += 35;
            UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, r.size.width / 4, 10)];
            [lbl setText:sArr[i]];
            [lbl setTextColor:[UIColor lightGrayColor]];
            [lbl setFont:[UIFont systemFontOfSize:14]];
            [lbl setTextAlignment:NSTextAlignmentCenter];
            [lbl setCenter:p];
            [view addSubview:lbl];
            [lbl release];
        }
    }
    
    //限时抢购
    if (_hasLimitPromotion) {
        top += height + 10;
        height = 240;
        
        _limitPromotionView = [[LimitPromotionView_ipa alloc] initWithFrame:CGRectMake(0, top, r.size.width, height)];
        [_scrollView addSubview:_limitPromotionView];
        [_limitPromotionView release];
        [_limitPromotionView setPromoteDelegate:self];
    }
    
    //热门商品
    if (_hasHotGoods) {
        top += height + 10;
        height = 270;
        
        _hotGoodView = [[HotGoodsView_ipa alloc] initWithFrame:CGRectMake(0, top, r.size.width, height)];
        [_scrollView addSubview:_hotGoodView];
        [_hotGoodView release];
        [_hotGoodView setHotDelegate:self];
    }
    
    //精品推荐
    if (_hasRecommend) {
        top += height + 10;
        height = 240;
        
        _recommendView = [[RecommendView_ipa alloc] initWithFrame:CGRectMake(0, top, r.size.width, height)];
        [_scrollView addSubview:_recommendView];
        [_recommendView release];
        [_recommendView setRecommendDelegate:self];
    }
    
    //新品上架
    if (_hasNewArrival) {
        top += height + 10;
        height = 270;
        
        _newArriavalView = [[NewArrivalView_ipa alloc] initWithFrame:CGRectMake(0, top, r.size.width, height)];
        [_scrollView addSubview:_newArriavalView];
        [_newArriavalView release];
        [_newArriavalView setArrivalDelegate:self];
    }
    
    //最下边的一堆分类入口
    
    if (_hasCotecary) {   
        top += height + 10;
        height = 450;
        _categoryView = [[CategoryView_ipa alloc] initWithFrame:CGRectMake(0, top, r.size.width, height)];
        [_scrollView addSubview:_categoryView];
        [_categoryView release];
        [_categoryView setCateDelegate:self];
    }
    
    int iTotalH = top + height;
    [_scrollView setContentSize:CGSizeMake(r.size.width, iTotalH)];
    
    // 重设上拉下拉刷新高度
    CGFloat footerH = MAX(_scrollView.contentSize.height, _scrollView.frame.size.height);
    _refreshFooterView.frame = CGRectMake(_scrollView.frame.origin.x,footerH,_scrollView.frame.size.width,_scrollView.frame.size.height);
}

- (void)dealloc
{
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // 更新下拉刷新日期 及 tableview在有navigationBar时的默认滑动距离
    [_refreshHeaderView refreshLastUpdatedDate];
    [_refreshFooterView refreshLastUpdatedDate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_searchBar setText:@""];
}

#pragma mark - delegate of 顶部滚动
-(void)onTopOfHomeScrollViewClickAtIndex:(NSInteger)index
{
    
}
-(void)onTopOfHomeScrollViewClickAtURL:(NSString*)URL
{
    BasicViewController_ipa *viewController = [[MyWebViewController_ipa alloc] init];
    viewController.strURL = URL;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - 
#pragma mark - 搜索按钮相关控制
-(void)controlSearchStatus:(float)alpha
{
    if ( alpha <= 0)
    {
        [_searchBar resignFirstResponder];
        [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    }
    
    [UIView animateWithDuration:0.2f animations:^{
        [_searchMaskBtn setAlpha:alpha];
    }completion:^(BOOL finished){
       
    }];
}

#pragma mark - 
#pragma mark - 各种按钮的点击
-(void)onFunctionalButtonClicked:(id)sender
{
    UIButton * clickBtn = (UIButton*)sender;
    switch (clickBtn.tag) {
        case 1000:
        {
            BasicViewController_ipa *viewController = [[MyWebViewController_ipa alloc] init];
            viewController.strURL = @"http://life.baifubao.com/sj";
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        case 1001:
        {
            BasicViewController_ipa *viewController = [[MyWebViewController_ipa alloc] init];
            viewController.strURL = @"http://m.kuaidi100.com";
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        case 1002:
        {
            BasicViewController_ipa *viewController = [[MyWebViewController_ipa alloc] init];
            viewController.strURL = @"http://i.tianqi.com/index.php?c=code&id=19&py=huludao";
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        case 1003:
        {
            [self onScanningBtnClicked:sender];
        }
            break;
        default:
            break;
    }
}

// 语音按钮
-(void)onVoiceBtnClicked:(UIButton*)sender
{
    [self controlSearchStatus:0.9];
    [_searchBar becomeFirstResponder];
}

// 扫码按钮
-(void)onScanningBtnClicked:(UIButton*)sender
{
    static QRCodeReaderViewController *reader = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        reader                        = [QRCodeReaderViewController new];
        reader.modalPresentationStyle = UIModalPresentationFormSheet;
    });
    reader.delegate = self;
    
    [reader setCompletionWithBlock:^(NSString *resultAsString) {
        NSLog(@"Completion with result: %@", resultAsString);
    }];
    
    [self presentViewController:reader animated:YES completion:NULL];
}

// 搜索背景按钮
-(void)onSearchMaskBtnClicked:(UIButton*)sender
{
    [self controlSearchStatus:0.0f];
    
    //temp
    //[self searchBarSearchButtonClicked:_searchBar];
}

#pragma mark - delegate of 热门商品
-(void)onHotGoodsViewClickedAtIndex:(NSInteger)index
{
    BasicViewController_ipa *viewControllerList = [[GoodsListViewController_ipa alloc] init];
    viewControllerList.strClickedName = @"hot";
    viewControllerList.iIDClicked = index;
    [self.navigationController pushViewController:viewControllerList animated:YES];
}

#pragma mark - delegate of 限时促销
-(void)onLimitPromotionViewClickedAtIndex:(NSInteger)index
{
    BasicViewController_ipa *viewControllerList = [[GoodsListViewController_ipa alloc] init];
    viewControllerList.strClickedName = @"promote";
    viewControllerList.iIDClicked = index;
    [self.navigationController pushViewController:viewControllerList animated:YES];
}

#pragma mark - delegate of 新品
-(void)onNewArrivalViewClickedAtIndex:(NSInteger)index
{
    BasicViewController_ipa *viewControllerList = [[GoodsListViewController_ipa alloc] init];
    viewControllerList.strClickedName = @"new";
    viewControllerList.iIDClicked = index;
    [self.navigationController pushViewController:viewControllerList animated:YES];
}

#pragma mark - delegate of 推荐
-(void)onRecommendViewClickedAtIndex:(NSInteger)index
{
    BasicViewController_ipa *viewControllerList = [[GoodsListViewController_ipa alloc] init];
    viewControllerList.strClickedName = @"best";
    viewControllerList.iIDClicked = index;
    [self.navigationController pushViewController:viewControllerList animated:YES];
}

#pragma mark - delegate of 分类
-(void)onCategoryViewViewClickedAtIndex:(NSInteger)index
{
    BasicViewController_ipa *viewControllerList = [[GoodsListViewController_ipa alloc] init];
    viewControllerList.strClickedName = @"category";
    viewControllerList.iIDClicked = index;
    [self.navigationController pushViewController:viewControllerList animated:YES];
}

#pragma mark - scroll view delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _scrollView) {
        float offset = _scrollView.contentOffset.y;
        float heigh = _scrollView.contentSize.height;
        float alpha = offset/heigh + 0.1;
        
        if ( 0.5 < alpha )
            alpha = 0.5;
        
        [_headerView setBackgroundColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:alpha]];
        
        if (_refreshHeaderView)
        {
            [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
        }
        
        if (_refreshFooterView)
        {
            [_refreshFooterView egoRefreshScrollViewDidScroll:scrollView];
        }
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_refreshHeaderView)
    {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    
    if (_refreshFooterView)
    {
        [_refreshFooterView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    
}

#pragma mark -
#pragma mark - UISearchBarDelegate
// UISearchBar得到焦点并开始编辑时，执行该方法
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self controlSearchStatus:0.9];
    
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    return YES;
    
}

// 取消按钮被按下时，执行的方法
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self controlSearchStatus:0];
    
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
}

// 键盘中，搜索按钮被按下，执行的方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"---%@",searchBar.text);
    [searchBar resignFirstResponder];
    [self controlSearchStatus:0];
    
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    
    BasicViewController_ipa *viewControllerList = [[GoodsListViewController_ipa alloc] init];
    viewControllerList.strClickedName = @"search";
    viewControllerList.strSearchKey = searchBar.text;
    [self.navigationController pushViewController:viewControllerList animated:YES];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)finishReloadingData
{
    
    //  model should call this when its done loading
    _reloading = NO;
    
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_scrollView];
    }
    
    if (_refreshFooterView) {
        [_refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:_scrollView];
    }
    
}

// 刷新调用的方法
-(void)refreshView
{
    NSLog(@"刷新完成");
    [self requestData];
    [self finishReloadingData];
    
}
// 加载调用的方法
-(void)getNextPageView
{
    [self requestData];
    [self finishReloadingData];
}

-(void)beginToReloadData:(EGORefreshPos)aRefreshPos{
    
    //  should be calling your tableviews data source model to reload
    _reloading = YES;
    
    if (aRefreshPos == EGORefreshHeader)
    {
        // pull down to refresh data
        [self performSelector:@selector(refreshView) withObject:nil afterDelay:0.2];
    }else if(aRefreshPos == EGORefreshFooter)
    {
        // pull up to load more data
        [self performSelector:@selector(getNextPageView) withObject:nil afterDelay:0.2];
    }
    
    // overide, the actual loading data operation is done in the subclass
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos{
    
    [self beginToReloadData:aRefreshPos];
    
}

- (BOOL)egoRefreshTableDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

#pragma mark - QRCodeReader Delegate Methods

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    if( ([result rangeOfString:@"http"].location != NSNotFound) || ([result rangeOfString:@"www"].location != NSNotFound) )
    {
        [self dismissViewControllerAnimated:YES completion:^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"可能存在风险，是否打开？" message:result delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"打开", nil];
            alert.delegate = self;
            [alert setTag:ENUM_QRCODE_URL_BTN_TAG];
            [alert show];
            [alert release];
        }];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"扫描结果" message:result delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"复制", nil];
            alert.delegate = self;
            [alert setTag:ENUM_QRCODE_TXT_BTN_TAG];
            [alert show];
            [alert release];
        }];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( alertView.tag == ENUM_QRCODE_URL_BTN_TAG )
    {
        if ( buttonIndex == 1 )
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:alertView.message]];
        }
    }
    else if ( alertView.tag == ENUM_QRCODE_TXT_BTN_TAG )
    {
        if ( buttonIndex == 1 )
        {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = alertView.message;
        }
    }
    else if ( alertView.tag == ENUM_UPDATE_NORMAL_BTN_TAG )
    {
        if ( buttonIndex == 1 )
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_updateURL]];
        }
    }
    else if ( alertView.tag == ENUM_UPDATE_NESSARY_BTN_TAG )
    {
        if ( buttonIndex == 0 )
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_updateURL]];
        }
    }
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - 
#pragma mark - network

#pragma mark - load data of each section
-(void)requestData
{
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [net request_HomeData_Datasuc:^(id success) {
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            [_topScrollView updateWithDataArray:success[@"data"][@"player"]];
        }
    } fail:^(NSError *error) {
        
    }];
    
    [net request_List_LimitPromotionDatasuc:^(id success) {
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            [_limitPromotionView updateWithDataArray:success[@"data"]];
        }
    } fail:^(NSError *error) {

    } page:1 count:10 sort:@"default"];
    
    
    [net request_List_HotGoodsDatasuc:^(id success) {
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            [_hotGoodView updateWithDataArray:success[@"data"]];
        }
    } fail:^(NSError *error) {
        
    } page:1 count:4 sort:@"default"];
    
    
    [net request_List_RecommendDatasuc:^(id success) {
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            [_recommendView updateWithDataArray:success[@"data"]];
        }
    } fail:^(NSError *error) {
        
    } page:1 count:10 sort:@"default"];
    
    
    [net request_List_NewArrivalDatasuc:^(id success) {
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            [_newArriavalView updateWithDataArray:success[@"data"]];
        }
    } fail:^(NSError *error) {
        
    } page:1 count:4 sort:@"default"];
    
    
    [net request_Catecory_Datasuc:^(id success) {
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            [_categoryView updateWithDataArray:success[@"data"]];
        }
    } fail:^(NSError *error) {
        
    } cateType:@"1"];
}

-(void)requestCheckUpdate
{
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [net request_CheckUpdate_Datasuc:^(id success) {
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            NSDictionary* dic = success[@"data"];
            if ( [[dic valueForKey:@"is_hasUpdate"] intValue] == 1 )
            {
                _updateURL = [[NSString alloc] initWithString:[dic valueForKey:@"URL_ipaone"]];
                
                if ( [[dic valueForKey:@"is_necessary"] intValue] == 1 )
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新提示" message:@"由于一些不得已的原因，旧版本停止使用，烦请您下载最新版本！" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"更新", nil];
                    alert.delegate = self;
                    [alert setTag:ENUM_UPDATE_NESSARY_BTN_TAG];
                    [alert show];
                    [alert release];
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新提示" message:@"服务器有新版本，是否更新？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"更新", nil];
                    alert.delegate = self;
                    [alert setTag:ENUM_UPDATE_NORMAL_BTN_TAG];
                    [alert show];
                    [alert release];
                }
            }
        }
        else
        {
            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:[success[@"status"] valueForKey:@"error_desc"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alter show];
            [alter release];
        }
    } fail:^(NSError *error) {
        
    }];
}



@end
