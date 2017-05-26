//
//  MineViewController_ipa.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "UserInfoViewController_ipa.h"
#import "RDVTabBarController.h"
#import "InfoEditViewController_ipa.h"
#import "MyAlert.h"

@interface UserInfoViewController_ipa ()
{
    int                     _iTopBarH;
    int                     _iTVCellH;
    NSMutableDictionary*    _userInfoDic;
}
@end

@implementation UserInfoViewController_ipa

@synthesize userInfoTableView = _userInfoTableView;

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
    
    _userInfoDic = [[NSMutableDictionary alloc] init];
    [_userInfoDic setValue:[[DataCenter sharedDataCenter].loginInfoDic objectForKey:@"name"] forKey:@"name"];
    [_userInfoDic setValue:[[DataCenter sharedDataCenter].loginInfoDic objectForKey:@"sex"] forKey:@"sex"];
    [_userInfoDic setValue:[[DataCenter sharedDataCenter].loginInfoDic objectForKey:@"birthday"] forKey:@"birthday"];
    [_userInfoDic setValue:[[DataCenter sharedDataCenter].loginInfoDic objectForKey:@"rank_name"] forKey:@"rank_name"];
    [_userInfoDic setValue:[[DataCenter sharedDataCenter].loginInfoDic objectForKey:@"rank_level"] forKey:@"rank_level"];
    [_userInfoDic setValue:[[DataCenter sharedDataCenter].loginInfoDic objectForKey:@"email"] forKey:@"email"];
}

-(void)initUI
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
 
    self.title = @"我的账户";
    
    CGRect frameR = self.view.frame;
    
    if ( [_userInfoDic count] <= 0 )
    {
        UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frameR.size.height/2-80, frameR.size.width, 21)];
        [nameLabel setText:@"暂无信息"];
        [nameLabel setNumberOfLines:1];
        [nameLabel setTextColor:[UIColor colorWithRed:30.0/255 green:30.0/255 blue:30.0/255 alpha:1]];
        [nameLabel setTextAlignment:NSTextAlignmentCenter];
        [nameLabel setFont:[UIFont systemFontOfSize:20]];
        [self.view addSubview:nameLabel];
        [nameLabel release];
        
        return;
    }
    
    _userInfoTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width, frameR.size.height) style:UITableViewStylePlain] autorelease];
    [_userInfoTableView setBackgroundColor:[UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1]];
    _userInfoTableView.dataSource = self;
    _userInfoTableView.delegate = self;
    _userInfoTableView.separatorStyle = NO;
    [self.view addSubview:_userInfoTableView];
    //[_userInfoTableView release];
    

    UILabel* logoutWdsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frameR.size.height-_iTVCellH, frameR.size.width/2, _iTVCellH)];
    logoutWdsLabel.backgroundColor = [UIColor colorWithRed:240.0/255 green:50.0/255 blue:50.0/255 alpha:0.8];
    [logoutWdsLabel setText:@"退出登录"];
    [logoutWdsLabel setNumberOfLines:1];
    [logoutWdsLabel setTextColor:[UIColor whiteColor]];
    [logoutWdsLabel setTextAlignment:NSTextAlignmentCenter];
    [logoutWdsLabel setFont:[UIFont systemFontOfSize:14]];
    [self.view addSubview:logoutWdsLabel];
    [logoutWdsLabel release];

    logoutWdsLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureLogout = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onLogoutClicked:)];
    [logoutWdsLabel addGestureRecognizer:tapGestureLogout];
    [tapGestureLogout release];
    
    UILabel* editPswdLabel = [[UILabel alloc] initWithFrame:CGRectMake(frameR.size.width/2, frameR.size.height-_iTVCellH, frameR.size.width/2, _iTVCellH)];
    editPswdLabel.backgroundColor = [UIColor colorWithRed:50.0/255 green:205.0/255 blue:50.0/255 alpha:0.8];
    [editPswdLabel setText:@"修改密码"];
    [editPswdLabel setNumberOfLines:1];
    [editPswdLabel setTextColor:[UIColor whiteColor]];
    [editPswdLabel setTextAlignment:NSTextAlignmentCenter];
    [editPswdLabel setFont:[UIFont systemFontOfSize:14]];
    [self.view addSubview:editPswdLabel];
    [editPswdLabel release];
    
    editPswdLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureEditPswd = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onEditPswdClicked:)];
    [editPswdLabel addGestureRecognizer:tapGestureEditPswd];
    [tapGestureEditPswd release];

}

#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect frameR = self.view.frame;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"GoodsListCell"];
    if ( cell == nil )
    {
        [cell setFrame:CGRectMake(0, 0, frameR.size.width, _iTVCellH)];
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GoodsListCell"]autorelease];
        cell.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        for ( UIView* subView in cell.subviews )
        {
            [subView removeFromSuperview];
        }
    }
    
    //NSDictionary * dic = [_categoryDataArray objectAtIndex:indexPath.row];
    
    // 存用户信息
    NSString* showTitle = @"";
    NSString* showDetail = @"";
    
    // 取用户信息
    if ( indexPath.row == 0 )
    {
        showTitle = [NSString stringWithFormat:@"用户名"];
        showDetail = [_userInfoDic objectForKey:@"name"];
    }
    else if ( indexPath.row == 1 )
    {
        showTitle = [NSString stringWithFormat:@"性别"];
        if ( [[_userInfoDic objectForKey:@"sex"] compare:@"0"] == NSOrderedSame )
            showDetail = @"女";
        else
            showDetail = @"男";
    }
    else if ( indexPath.row == 2 )
    {
        showTitle = [NSString stringWithFormat:@"生日"];
        showDetail = [_userInfoDic objectForKey:@"birthday"];
    }
    else if ( indexPath.row == 3 )
    {
        showTitle = [NSString stringWithFormat:@"用户类别"];
        showDetail = [_userInfoDic objectForKey:@"rank_name"];
    }
    else if ( indexPath.row == 4 )
    {
        showTitle = [NSString stringWithFormat:@"用户等级"];
        showDetail = [NSString stringWithFormat:@"%d",(int)[_userInfoDic objectForKey:@"rank_level"]];
    }
    else if ( indexPath.row == 5 )
    {
        showTitle = [NSString stringWithFormat:@"邮箱地址"];
        showDetail = [_userInfoDic objectForKey:@"email"];
    }
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, frameR.size.width-40, _iTVCellH)];
    [titleLabel setText:showTitle];
    [titleLabel setNumberOfLines:1];
    [titleLabel setTextColor:[UIColor colorWithRed:60.0/255 green:60.0/255 blue:60.0/255 alpha:1]];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [titleLabel setFont:[UIFont systemFontOfSize:12]];
    [cell addSubview:titleLabel];
    [titleLabel release];
    
    UILabel* detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, frameR.size.width-40, _iTVCellH)];
    [detailLabel setText:showDetail];
    [detailLabel setNumberOfLines:1];
    [detailLabel setTextColor:[UIColor colorWithRed:60.0/255 green:60.0/255 blue:60.0/255 alpha:1]];
    [detailLabel setTextAlignment:NSTextAlignmentRight];
    [detailLabel setFont:[UIFont systemFontOfSize:12]];
    [cell addSubview:detailLabel];
    [detailLabel release];
    
    // 横向分割线
    UIView* seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(5,_iTVCellH-0.5, frameR.size.width-10, 0.5)];
    [seperatorlINE setBackgroundColor:[UIColor colorWithRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:1]];
    [cell addSubview:seperatorlINE];
    [seperatorlINE release];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;//[_userInfoDic count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _iTVCellH+1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //[self reloadScrollView:indexPath.row];
    
    //BasicViewController_ipa *viewControllerList = [[GoodsDetailViewController_ipa alloc] init];
    //viewControllerList.iGoodsIDClicked = [dic[@"id"] intValue];
    //[self.navigationController pushViewController:viewControllerList animated:YES];
    
    if ( indexPath.row == 0 )
    {
        [MyAlert showMessage:@"用户名不可修改" timer:2.0f];
    }
    else if ( indexPath.row == 1 )
    {
        InfoEditViewController_ipa *viewControllerEdit = [[InfoEditViewController_ipa alloc] init];
        [viewControllerEdit setEditMode:ENUM_EDIT_MODE_SEX];
        [self.navigationController pushViewController:viewControllerEdit animated:YES];
    }
    else if ( indexPath.row == 2 )
    {
        InfoEditViewController_ipa *viewControllerEdit = [[InfoEditViewController_ipa alloc] init];
        [viewControllerEdit setEditMode:ENUM_EDIT_MODE_BIRTHDAY];
        [self.navigationController pushViewController:viewControllerEdit animated:YES];
    }
    else if ( indexPath.row == 3 )
    {
        [MyAlert showMessage:@"用户类别不可修改" timer:2.0f];
    }
    else if ( indexPath.row == 4 )
    {
        [MyAlert showMessage:@"用户等级不可修改" timer:2.0f];
    }
    else if ( indexPath.row == 5 )
    {
        InfoEditViewController_ipa *viewControllerEdit = [[InfoEditViewController_ipa alloc] init];
        [viewControllerEdit setEditMode:ENUM_EDIT_MODE_EMAIL];
        [self.navigationController pushViewController:viewControllerEdit animated:YES];
    }

}


- (void)dealloc
{

    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
    UINavigationController* navigationController = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
    [navigationController setNavigationBarHidden:NO animated:YES];
    
    // 重新装载数据 用于刷新修改后的值
    [_userInfoDic removeAllObjects];
    [self initData];
    [_userInfoTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    
    UINavigationController* pNv = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
    [pNv setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - clicked event

- (void)onLogoutClicked:(id)sender
{
    [self requestLogout];
}

- (void)onEditPswdClicked:(id)sender
{
    InfoEditViewController_ipa *viewControllerEdit = [[InfoEditViewController_ipa alloc] init];
    [viewControllerEdit setEditMode:ENUM_EDIT_MODE_PASSWORD];
    [self.navigationController pushViewController:viewControllerEdit animated:YES];
}

#pragma mark - network

-(void)userInfoEditResult:(NSDictionary*)resultDic
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)requestLogout
{
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [net request_Logout_Datasuc:^(id success) {
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            [[DataCenter sharedDataCenter] removeLoginData];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } fail:^(NSError *error) {
        
    }];
}



@end
