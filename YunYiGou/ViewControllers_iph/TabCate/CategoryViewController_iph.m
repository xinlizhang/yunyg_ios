//
//  CategoryViewController_iph.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "CategoryViewController_iph.h"
#import "UIImageView+OnlineImage.h"
#import "GoodsListViewController_iph.h"
#import "RDVTabBarController.h"

#import "QRCodeReaderDelegate.h"
#import "QRCodeReaderViewController.h"

@interface CateViewController_iph () <UISearchBarDelegate,QRCodeReaderDelegate,UIAlertViewDelegate>
{
    int     _iTopBarH;
    int     _iTVCellH;
    bool    _bIsRequested;
    
    MyNetLoading* _netLoading;
    
    UISearchBar * _searchBar;
    UIButton * _searchMaskBtn;
}
@end

@implementation CateViewController_iph

@synthesize categoryDataArray = _categoryDataArray;
@synthesize cate1stTableView = _cate1stTableView;
@synthesize cate2ndScrollView = _cate2ndScrollView;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initData];
        [self initUI];
    }
    return self;
}

-(void)initData
{
    _iTopBarH = 60;
    _iTVCellH = 40;
    _bIsRequested = false;
    
    _categoryDataArray = [[NSMutableArray alloc] init];
}

-(void)initUI
{
    CGRect frameR = self.view.frame;
    
    
    // 一级分类列表
    _cate1stTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, _iTopBarH, frameR.size.width/5, frameR.size.height-_iTopBarH-50) style:UITableViewStylePlain] autorelease];
    [_cate1stTableView setBackgroundColor:[UIColor whiteColor]];
    _cate1stTableView.dataSource = self;
    _cate1stTableView.delegate = self;
    _cate1stTableView.separatorStyle = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:_cate1stTableView];
    //[_cate1stTableView release];
    
    
    // 二级分类列表
    _cate2ndScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(frameR.size.width/5, _iTopBarH, frameR.size.width*4/5, frameR.size.height-_iTopBarH-50)];
    [_cate2ndScrollView setBackgroundColor:[UIColor whiteColor]];
    [_cate2ndScrollView setDelegate:self];
    [self.view addSubview:_cate2ndScrollView];
    [_cate2ndScrollView release];
    
    // 搜索时的背景遮罩
    _searchMaskBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width, frameR.size.height)];
    [_searchMaskBtn setBackgroundColor:[UIColor whiteColor]];
    [_searchMaskBtn setAlpha:0.0f];
    [_searchMaskBtn addTarget:self action:@selector(onSearchMaskBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_searchMaskBtn];
    [_searchMaskBtn release];
    
    // 顶部搜索框
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width, _iTopBarH)];
    [headerView setBackgroundColor:[UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1]];
    [self.view addSubview:headerView];
    [headerView release];

    UIButton * scanningBtn = [[UIButton alloc] initWithFrame:CGRectMake(frameR.size.width - 8 - 25, 23, 25, 25)];
    [scanningBtn setImage:[UIImage imageNamed:@"home_btn_scanning_gray"] forState:UIControlStateNormal];
    [scanningBtn setImage:[UIImage imageNamed:@"home_btn_scanning"] forState:UIControlStateHighlighted];
    [scanningBtn addTarget:self action:@selector(onScanningBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:scanningBtn];
    [scanningBtn release];
    
    // 搜索按钮
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(5, 20, frameR.size.width - 5 - 35, 33)];
    [_searchBar setPlaceholder:NSLocalizedString(@"搜索你想要的商品/店铺", nil)];
    [_searchBar setBackgroundColor:[UIColor clearColor]];
    [_searchBar setAlpha:0.8];
    _searchBar.delegate = self;
    _searchBar.keyboardType = UIKeyboardTypeDefault;
    
    [headerView addSubview:_searchBar];
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
    
    //UIButton * voiceBtn = [[UIButton alloc] initWithFrame:CGRectMake(frameR.size.width - 68, 26, 20, 20)];
    //[voiceBtn setImage:[UIImage imageNamed:@"home_btn_voice"] forState:UIControlStateNormal];
    //[voiceBtn setImage:[UIImage imageNamed:@"home_btn_voice"] forState:UIControlStateHighlighted];
    //[headerView addSubview:voiceBtn];
    //[voiceBtn release];
    
    // 横向分割线
    UIView* seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0,_iTopBarH-0.5, frameR.size.width, 0.5)];
    [seperatorlINE setBackgroundColor:[UIColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1]];
    [headerView addSubview:seperatorlINE];
    [seperatorlINE release];

    
    // loading
    _netLoading = [[MyNetLoading alloc] init];
    [_netLoading setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    [self.view addSubview:_netLoading];
    [_netLoading release];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_searchBar setText:@""];
    
    if ( _bIsRequested == false )
        [self requestData];
}

- (void)viewWillDisappear:(BOOL)animated {

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect frameR = self.view.frame;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"GoodsListCell"];
    if ( cell == nil )
    {
        [cell setFrame:CGRectMake(0, 0, frameR.size.width/5, _iTVCellH)];
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GoodsListCell"]autorelease];
        cell.backgroundColor = [UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1];
    }
    else
    {
        for ( UIView* subView in cell.subviews )
        {
            [subView removeFromSuperview];
        }
    }
    
    NSDictionary * dic = [_categoryDataArray objectAtIndex:indexPath.row];
    
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width/5, _iTVCellH)];
    [nameLabel setText:dic[@"name"]];
    [nameLabel setNumberOfLines:1];
    [nameLabel setTextColor:[UIColor colorWithRed:60.0/255 green:60.0/255 blue:60.0/255 alpha:1]];
    [nameLabel setTextAlignment:NSTextAlignmentCenter];
    [nameLabel setFont:[UIFont systemFontOfSize:12]];
    [cell addSubview:nameLabel];
    [nameLabel release];
    
    // 横向分割线
    UIView* seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(5,_iTVCellH-0.5, frameR.size.width/5-10, 0.5)];
    [seperatorlINE setBackgroundColor:[UIColor colorWithRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:1]];
    [cell addSubview:seperatorlINE];
    [seperatorlINE release];
    
    cell.selectedBackgroundView = [[[UIView alloc] initWithFrame:cell.frame] autorelease];
    cell.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_categoryDataArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _iTVCellH+1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self reloadScrollView:indexPath.row];
  
    //BasicViewController_iph *viewControllerList = [[GoodsDetailViewController_iph alloc] init];
    //viewControllerList.iGoodsIDClicked = [dic[@"id"] intValue];
    //[self.navigationController pushViewController:viewControllerList animated:YES];
}


- (void) reloadScrollView : (NSInteger) indexSel
{
    
    for ( UIView* subView in _cate2ndScrollView.subviews )
    {
        [subView removeFromSuperview];
    }
    
    NSDictionary* dic = [_categoryDataArray objectAtIndex:indexSel];
    NSArray* childrenCate = [dic objectForKey:@"children"];
    
    CGPoint startP = CGPointMake(50, 40);       // 起始坐标
    int distanceX = 80;                         // 横向距离间隔
    int distanceY = 95;
    
    for ( int idx = 0; idx < [childrenCate count]; idx++ )
    {
        NSDictionary* cateDic = childrenCate[idx];
        
        CGPoint centerP = CGPointMake(0, 0);
        centerP.x = startP.x + idx%3*distanceX;
        centerP.y = startP.y + idx/3*distanceY;
        
        // 分类图片
        UIImageView * cateIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [cateIV setOnlineImage:cateDic[@"category_thumb"] placeholderImage:[UIImage imageNamed:@"common_img_loding"]];
        [cateIV setCenter:centerP];
        [_cate2ndScrollView addSubview:cateIV];
        cateIV.tag = [cateDic[@"id"] intValue];
        cateIV.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCategoryClicked:)];
        [cateIV addGestureRecognizer:singleTap1];
        [singleTap1 release];
        [cateIV release];
        
        // 分类名称
        UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 11)];
        [nameLabel setText:cateDic[@"name"]];
        [nameLabel setCenter:CGPointMake(centerP.x, centerP.y+40)];
        [nameLabel setNumberOfLines:1];
        [nameLabel setTextColor:[UIColor colorWithRed:43.0/255 green:43.0/255 blue:43.0/255 alpha:1]];
        [nameLabel setTextAlignment:NSTextAlignmentCenter];
        [nameLabel setFont:[UIFont systemFontOfSize:10]];
        [_cate2ndScrollView addSubview:nameLabel];
        [nameLabel release];
    }
    
    [_cate2ndScrollView setContentSize:CGSizeMake(self.view.frame.size.width*4/5, startP.y+[childrenCate count]/3*distanceY+distanceY/2)];
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

#pragma marl - clicked event
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


-(void)onCategoryClicked:(UITapGestureRecognizer*)sender;
{
    BasicViewController_iph *viewControllerList = [[GoodsListViewController_iph alloc] init];
    viewControllerList.strClickedName = @"category";
    viewControllerList.iIDClicked = sender.view.tag;
    [self.navigationController pushViewController:viewControllerList animated:YES];
}

// 搜索背景按钮
-(void)onSearchMaskBtnClicked:(UIButton*)sender
{
    [self controlSearchStatus:0.0f];
    
    //temp
    //[self searchBarSearchButtonClicked:_searchBar];
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
    
    BasicViewController_iph *viewControllerList = [[GoodsListViewController_iph alloc] init];
    viewControllerList.strClickedName = @"search";
    viewControllerList.strSearchKey = searchBar.text;
    [self.navigationController pushViewController:viewControllerList animated:YES];
}


#pragma mark - scroll view delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{

}


#pragma mark - QRCodeReader Delegate Methods

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    if( ([result rangeOfString:@"http"].location != NSNotFound) || ([result rangeOfString:@"www"].location != NSNotFound) )
    {
        [self dismissViewControllerAnimated:YES completion:^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"可能存在风险，是否打开？" message:result delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"打开", nil];
            alert.delegate = self;
            [alert setTag:1];
            [alert show];
            [alert release];
        }];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"扫描结果" message:result delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"复制", nil];
            alert.delegate = self;
            [alert setTag:2];
            [alert show];
            [alert release];
        }];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( alertView.tag == 1)
    {
        if ( buttonIndex == 1 )
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:alertView.message]];
        }
    }
    else if ( alertView.tag == 2 )
    {
        if ( buttonIndex == 1 )
        {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = alertView.message;
        }
    }
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - network

-(void)updateUI
{
    _bIsRequested = true;
    [_cate1stTableView reloadData];
    NSIndexPath* defaultIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    [_cate1stTableView selectRowAtIndexPath:defaultIndex animated:YES scrollPosition:UITableViewScrollPositionBottom];
    [self reloadScrollView:0];
}

-(void)requestData
{
    [_netLoading startAnimating];
    
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [net request_Catecory_Datasuc:^(id success) {
        
        [_netLoading stopAnimating];
        
        if (success[@"status"])
        {
            if ( [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
            {
                [_categoryDataArray addObjectsFromArray:success[@"data"]];
                [self updateUI];
            }
        }
    } fail:^(NSError *error) {
        
        [_netLoading stopAnimating];
        
    } cateType:@"0"];
}



@end
