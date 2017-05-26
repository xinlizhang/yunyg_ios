//
//  MineViewController_ipa.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "MineViewController_ipa.h"
#import "LoginViewController_ipa.h"
#import "UserInfoViewController_ipa.h"
#import "DataCenter.h"
#import "OrderListViewController_ipa.h"
#import "AddrListMngViewController_ipa.h"
#import "HelpListViewController_ipa.h"
#import "CollectViewController_ipa.h"
#import "AboutViewController_ipa.h"

@interface MineViewController_ipa ()
{
    int             _iTopBarH;
    UIScrollView*   _scrollView;
    UIButton*       _loginBtn;
    
    UILabel*        _nameLabel;
    UILabel*        _rankLabel;
}
@end

@implementation MineViewController_ipa


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
}

-(void)initUI
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
 
    CGRect frameR = self.view.frame;
    
    // 顶边栏文字
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, frameR.size.width, _iTopBarH-20)];
    [nameLabel setText:@"我的"];
    [nameLabel setNumberOfLines:1];
    [nameLabel setTextColor:[UIColor colorWithRed:30.0/255 green:30.0/255 blue:30.0/255 alpha:1]];
    [nameLabel setTextAlignment:NSTextAlignmentCenter];
    [nameLabel setFont:[UIFont systemFontOfSize:15]];
    [self.view addSubview:nameLabel];
    [nameLabel release];
    
    // 顶边栏右侧设置按钮
    //UIButton* settingBtn = [[UIButton alloc] initWithFrame:CGRectMake(frameR.size.width-50, 20, 40, 40)];
    //[settingBtn setImage:[UIImage imageNamed:@"mine_setting_btn_nor"] forState:UIControlStateNormal];
    //[settingBtn setImage:[UIImage imageNamed:@"mine_setting_btn_sel"] forState:UIControlStateSelected];
    //[self.view addSubview:settingBtn];
    //[settingBtn release];
    
    // content
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _iTopBarH, frameR.size.width, frameR.size.height-_iTopBarH)];
    [_scrollView setBackgroundColor:[UIColor colorWithRed:238.0/255 green:243.0/255 blue:246.0/255 alpha:1]];
    [self.view addSubview:_scrollView];
    [_scrollView setDelegate:self];
    [_scrollView release];
    
    // 登陆用户名背景
    CGPoint relationP = CGPointMake(0, 0);
    int height = 200;
    UIImageView* userInfoBG = [[UIImageView alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, frameR.size.width, height)];
    [userInfoBG setImage:[UIImage imageNamed:@"mine_user_info_bg"]];
    [_scrollView addSubview:userInfoBG];
    userInfoBG.userInteractionEnabled = YES;
    UITapGestureRecognizer *countMngTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onLoginClicked:)];
    [userInfoBG addGestureRecognizer:countMngTap];
    [countMngTap release];
    [userInfoBG release];
    
    // 登陆 / 头像
    _loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [_loginBtn setCenter:CGPointMake(frameR.size.width/2, relationP.y+90)];
    [_loginBtn setImage:[UIImage imageNamed:@"mine_login_btn_nor"] forState:UIControlStateNormal];
    [_loginBtn addTarget:self action:@selector(onLoginClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_loginBtn];
    [_loginBtn release];
    
    // 用户名 密码
    NSDictionary* userInfoDic = [DataCenter sharedDataCenter].loginInfoDic;
    
    int nameLableX = _loginBtn.frame.origin.x + _loginBtn.frame.size.width + 20;
    int nameLabelY = _loginBtn.frame.origin.y + 10;

    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLableX, nameLabelY, 120, 16)];
    [_nameLabel setText:[userInfoDic objectForKey:@"name"]];
    [_nameLabel setTag:123];
    [_nameLabel setNumberOfLines:1];
    [_nameLabel setTextColor:[UIColor whiteColor]];
    [_nameLabel setTextAlignment:NSTextAlignmentLeft];
    [_nameLabel setFont:[UIFont systemFontOfSize:14]];
    [_scrollView addSubview:_nameLabel];
    [_nameLabel release];
    
    _rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLableX, nameLabelY+16+10, 120, 16)];
    [_rankLabel setText:[userInfoDic objectForKey:@"rank_name"]];
    [_rankLabel setTag:223];
    [_rankLabel setNumberOfLines:1];
    [_rankLabel setTextColor:[UIColor whiteColor]];
    [_rankLabel setTextAlignment:NSTextAlignmentLeft];
    [_rankLabel setFont:[UIFont systemFontOfSize:14]];
    [_scrollView addSubview:_rankLabel];
    [_rankLabel release];
    
    // 账户管理
    UIView* countMngView = [[UIView alloc] initWithFrame:CGRectMake(0, userInfoBG.frame.size.height-50, frameR.size.width, 50)];
    [countMngView setBackgroundColor:[UIColor colorWithRed:0/255 green:0/255 blue:0/255 alpha:0.3]];
    [userInfoBG addSubview:countMngView];
    [countMngView release];
    UILabel* countMngLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, userInfoBG.frame.size.height-50, frameR.size.width-160, 40)];
    [countMngLabel setText:@"账户管理 >"];
    [countMngLabel setNumberOfLines:1];
    [countMngLabel setTextColor:[UIColor whiteColor]];
    [countMngLabel setTextAlignment:NSTextAlignmentRight];
    [countMngLabel setFont:[UIFont systemFontOfSize:15]];
    [userInfoBG addSubview:countMngLabel];
    [countMngLabel release];
    
    
    // 我的订单
    relationP.x = 80;
    relationP.y = relationP.y + height + 20;
    height = 40;
    UIView* myOrderListView = [[UIView alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [myOrderListView setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:myOrderListView];
    myOrderListView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMyOrderListClicked:)];
    [myOrderListView addGestureRecognizer:tapGesture];
    [tapGesture release];
    [myOrderListView release];
    
    UIImageView* listIcon = [[UIImageView alloc] initWithFrame:CGRectMake(relationP.x, 10, 20, 20)];
    [listIcon setImage:[UIImage imageNamed:@"mine_btn_icon_order"]];
    [myOrderListView addSubview:listIcon];
    [listIcon release];
    
    CGRect frameLable = myOrderListView.frame;
    UILabel* myOrderLable = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x+40, 0, frameLable.size.width-120, frameLable.size.height)];
    [myOrderLable setText:@"我的订单"];
    [myOrderLable setNumberOfLines:1];
    [myOrderLable setTextColor:[UIColor blackColor]];
    [myOrderLable setTextAlignment:NSTextAlignmentLeft];
    [myOrderLable setFont:[UIFont systemFontOfSize:14]];
    [myOrderListView addSubview:myOrderLable];
    [myOrderLable release];
    
    UILabel* myAllOrderLable = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, frameLable.size.width-160, frameLable.size.height)];
    [myAllOrderLable setText:@"查看全部订单"];
    [myAllOrderLable setNumberOfLines:1];
    [myAllOrderLable setTextColor:[UIColor lightGrayColor]];
    [myAllOrderLable setTextAlignment:NSTextAlignmentRight];
    [myAllOrderLable setFont:[UIFont systemFontOfSize:12]];
    [myOrderListView addSubview:myAllOrderLable];
    [myAllOrderLable release];
    
    UIImageView* rightIdentify = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [rightIdentify setCenter:CGPointMake(frameR.size.width-75, height/2)];
    [rightIdentify setImage:[UIImage imageNamed:@"home_btn_godetail"]];
    [myOrderListView addSubview:rightIdentify];
    [rightIdentify release];

    UIView* seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [myOrderListView addSubview:seperatorlINE];
    [seperatorlINE release];
    
    
    // 订单分类
    relationP.y = relationP.y + height;
    height = 60;
    
    UIView* orderDetailListView = [[UIView alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [orderDetailListView setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:orderDetailListView];
    [orderDetailListView release];
    
    int distanceX = 80;
    int distanceY = 22;
    CGPoint orderCenterP = CGPointMake(relationP.x+20, 22);
    UIImageView* awaitPayView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [awaitPayView setImage:[UIImage imageNamed:@"mine_order_await_pay"]];
    [awaitPayView setCenter:orderCenterP];
    [orderDetailListView addSubview:awaitPayView];
    awaitPayView.userInteractionEnabled = YES;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAwaitPayOrderClicked:)];
    [awaitPayView addGestureRecognizer:tapGesture];
    [tapGesture release];
    [awaitPayView release];
    
    UILabel* awaitPayWdsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 13)];
    [awaitPayWdsLabel setText:@"待付款"];
    [awaitPayWdsLabel setNumberOfLines:1];
    [awaitPayWdsLabel setCenter:CGPointMake(orderCenterP.x, orderCenterP.y+distanceY)];
    [awaitPayWdsLabel setTextColor:[UIColor grayColor]];
    [awaitPayWdsLabel setBackgroundColor:[UIColor clearColor]];
    [awaitPayWdsLabel setTextAlignment:NSTextAlignmentCenter];
    [awaitPayWdsLabel setFont:[UIFont systemFontOfSize:12]];
    [orderDetailListView addSubview:awaitPayWdsLabel];
    [awaitPayWdsLabel release];
    
    
    orderCenterP.x = orderCenterP.x + distanceX;
    UIImageView* awaitShipView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [awaitShipView setImage:[UIImage imageNamed:@"mine_order_await_ship"]];
    [awaitShipView setCenter:orderCenterP];
    [orderDetailListView addSubview:awaitShipView];
    awaitShipView.userInteractionEnabled = YES;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAwaitShipOrderClicked:)];
    [awaitShipView addGestureRecognizer:tapGesture];
    [tapGesture release];
    [awaitShipView release];
    
    UILabel* awaitShipWdsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 13)];
    [awaitShipWdsLabel setText:@"待发货"];
    [awaitShipWdsLabel setNumberOfLines:1];
    [awaitShipWdsLabel setCenter:CGPointMake(orderCenterP.x, orderCenterP.y+distanceY)];
    [awaitShipWdsLabel setTextColor:[UIColor grayColor]];
    [awaitShipWdsLabel setBackgroundColor:[UIColor clearColor]];
    [awaitShipWdsLabel setTextAlignment:NSTextAlignmentCenter];
    [awaitShipWdsLabel setFont:[UIFont systemFontOfSize:12]];
    [orderDetailListView addSubview:awaitShipWdsLabel];
    [awaitShipWdsLabel release];
    
    
    orderCenterP.x = orderCenterP.x + distanceX;
    UIImageView* shipedView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [shipedView setImage:[UIImage imageNamed:@"mine_order_shipped"]];
    [shipedView setCenter:orderCenterP];
    [orderDetailListView addSubview:shipedView];
    shipedView.userInteractionEnabled = YES;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onShipedOrderClicked:)];
    [shipedView addGestureRecognizer:tapGesture];
    [tapGesture release];
    [shipedView release];
    
    UILabel* shippedWdsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 13)];
    [shippedWdsLabel setText:@"待收货"];
    [shippedWdsLabel setNumberOfLines:1];
    [shippedWdsLabel setCenter:CGPointMake(orderCenterP.x, orderCenterP.y+distanceY)];
    [shippedWdsLabel setTextColor:[UIColor grayColor]];
    [shippedWdsLabel setBackgroundColor:[UIColor clearColor]];
    [shippedWdsLabel setTextAlignment:NSTextAlignmentCenter];
    [shippedWdsLabel setFont:[UIFont systemFontOfSize:12]];
    [orderDetailListView addSubview:shippedWdsLabel];
    [shippedWdsLabel release];
    
    
    orderCenterP.x = orderCenterP.x + distanceX;
    UIImageView* finishedView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [finishedView setImage:[UIImage imageNamed:@"mine_order_finished"]];
    [finishedView setCenter:orderCenterP];
    [orderDetailListView addSubview:finishedView];
    finishedView.userInteractionEnabled = YES;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onFinishedOrderClicked:)];
    [finishedView addGestureRecognizer:tapGesture];
    [tapGesture release];
    [finishedView release];
    
    UILabel* finishedWdsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 13)];
    [finishedWdsLabel setText:@"历史订单"];
    [finishedWdsLabel setNumberOfLines:1];
    [finishedWdsLabel setCenter:CGPointMake(orderCenterP.x, orderCenterP.y+distanceY)];
    [finishedWdsLabel setTextColor:[UIColor grayColor]];
    [finishedWdsLabel setBackgroundColor:[UIColor clearColor]];
    [finishedWdsLabel setTextAlignment:NSTextAlignmentCenter];
    [finishedWdsLabel setFont:[UIFont systemFontOfSize:12]];
    [orderDetailListView addSubview:finishedWdsLabel];
    [finishedWdsLabel release];
    
    
    
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0f]];
    [orderDetailListView addSubview:seperatorlINE];
    [seperatorlINE release];
    
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, height-0.5f, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [orderDetailListView addSubview:seperatorlINE];
    [seperatorlINE release];
    
    // 收货地址管理
    relationP.y = relationP.y + height + 12;
    height = 40;
    UIView* addrManageView = [[UIView alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [addrManageView setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:addrManageView];
    addrManageView.userInteractionEnabled = YES;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAddrManageClicked:)];
    [addrManageView addGestureRecognizer:tapGesture];
    [tapGesture release];
    [addrManageView release];
    
    UIImageView* addrIcon = [[UIImageView alloc] initWithFrame:CGRectMake(relationP.x, 10, 20, 20)];
    [addrIcon setImage:[UIImage imageNamed:@"mine_btn_icon_cart"]];
    [addrManageView addSubview:addrIcon];
    [addrIcon release];
    
    CGRect addrLable = addrManageView.frame;
    UILabel* addrWordsLable = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x+40, 0, addrLable.size.width-120, addrLable.size.height)];
    [addrWordsLable setText:@"收货地址管理"];
    [addrWordsLable setNumberOfLines:1];
    [addrWordsLable setTextColor:[UIColor blackColor]];
    [addrWordsLable setTextAlignment:NSTextAlignmentLeft];
    [addrWordsLable setFont:[UIFont systemFontOfSize:14]];
    [addrManageView addSubview:addrWordsLable];
    [addrWordsLable release];
    
    rightIdentify = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [rightIdentify setCenter:CGPointMake(frameR.size.width-75, height/2)];
    [rightIdentify setImage:[UIImage imageNamed:@"home_btn_godetail"]];
    [addrManageView addSubview:rightIdentify];
    [rightIdentify release];
    
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [addrManageView addSubview:seperatorlINE];
    [seperatorlINE release];
    
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, height-0.5f, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [addrManageView addSubview:seperatorlINE];
    [seperatorlINE release];
    
    // 我的收藏
    relationP.y = relationP.y + height + 12;
    height = 40;
    UIView* collectView = [[UIView alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [collectView setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:collectView];
    collectView.userInteractionEnabled = YES;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMyCollectClicked:)];
    [collectView addGestureRecognizer:tapGesture];
    [tapGesture release];
    [collectView release];
    
    UIImageView* collectIcon = [[UIImageView alloc] initWithFrame:CGRectMake(relationP.x, 10, 20, 20)];
    [collectIcon setImage:[UIImage imageNamed:@"mine_btn_icon_collect"]];
    [collectView addSubview:collectIcon];
    [collectIcon release];
    
    UILabel* collectLable = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x+40, 0, collectView.frame.size.width-120, collectView.frame.size.height)];
    [collectLable setText:@"我的收藏"];
    [collectLable setNumberOfLines:1];
    [collectLable setTextColor:[UIColor blackColor]];
    [collectLable setTextAlignment:NSTextAlignmentLeft];
    [collectLable setFont:[UIFont systemFontOfSize:14]];
    [collectView addSubview:collectLable];
    [collectLable release];
    
    rightIdentify = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [rightIdentify setCenter:CGPointMake(frameR.size.width-75, height/2)];
    [rightIdentify setImage:[UIImage imageNamed:@"home_btn_godetail"]];
    [collectView addSubview:rightIdentify];
    [rightIdentify release];
    
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [collectView addSubview:seperatorlINE];
    [seperatorlINE release];
    
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, height-0.5f, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [collectView addSubview:seperatorlINE];
    [seperatorlINE release];
    
    // 帮助
    relationP.y = relationP.y + height + 12;
    height = 40;
    UIView* helpView = [[UIView alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [helpView setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:helpView];
    helpView.userInteractionEnabled = YES;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onHelpClicked:)];
    [helpView addGestureRecognizer:tapGesture];
    [tapGesture release];
    [helpView release];
    
    UIImageView* helpIcon = [[UIImageView alloc] initWithFrame:CGRectMake(relationP.x, 10, 20, 20)];
    [helpIcon setImage:[UIImage imageNamed:@"mine_btn_icon_help"]];
    [helpView addSubview:helpIcon];
    [helpIcon release];
    
    CGRect helpFrame = helpView.frame;
    UILabel* helpLable = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x+40, 0, helpFrame.size.width-120, helpFrame.size.height)];
    [helpLable setText:@"帮助"];
    [helpLable setNumberOfLines:1];
    [helpLable setTextColor:[UIColor blackColor]];
    [helpLable setTextAlignment:NSTextAlignmentLeft];
    [helpLable setFont:[UIFont systemFontOfSize:14]];
    [helpView addSubview:helpLable];
    [helpLable release];
    
    rightIdentify = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [rightIdentify setCenter:CGPointMake(frameR.size.width-75, height/2)];
    [rightIdentify setImage:[UIImage imageNamed:@"home_btn_godetail"]];
    [helpView addSubview:rightIdentify];
    [rightIdentify release];
    
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [helpView addSubview:seperatorlINE];
    [seperatorlINE release];
    
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, height-0.5f, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [helpView addSubview:seperatorlINE];
    [seperatorlINE release];
    
    // 关于
    relationP.y = relationP.y + height + 12;
    height = 40;
    UIView* aboutView = [[UIView alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [aboutView setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:aboutView];
    aboutView.userInteractionEnabled = YES;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAboutClicked:)];
    [aboutView addGestureRecognizer:tapGesture];
    [tapGesture release];
    [aboutView release];
    
    UIImageView* adviceIcon = [[UIImageView alloc] initWithFrame:CGRectMake(relationP.x, 10, 20, 20)];
    [adviceIcon setImage:[UIImage imageNamed:@"mine_btn_icon_about"]];
    [aboutView addSubview:adviceIcon];
    [adviceIcon release];
    
    CGRect adviceBtnF = aboutView.frame;
    UILabel* adviceLable = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x+40, 0, adviceBtnF.size.width-120, adviceBtnF.size.height)];
    [adviceLable setText:@"关于雲易购"];
    [adviceLable setNumberOfLines:1];
    [adviceLable setTextColor:[UIColor blackColor]];
    [adviceLable setTextAlignment:NSTextAlignmentLeft];
    [adviceLable setFont:[UIFont systemFontOfSize:14]];
    [aboutView addSubview:adviceLable];
    [adviceLable release];
    
    rightIdentify = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [rightIdentify setCenter:CGPointMake(frameR.size.width-75, height/2)];
    [rightIdentify setImage:[UIImage imageNamed:@"home_btn_godetail"]];
    [aboutView addSubview:rightIdentify];
    [rightIdentify release];
    
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [aboutView addSubview:seperatorlINE];
    [seperatorlINE release];
    
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, height-0.5f, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [aboutView addSubview:seperatorlINE];
    [seperatorlINE release];
    
    int iTotalH = relationP.y + height;
    iTotalH += 60;
    [_scrollView setContentSize:CGSizeMake(frameR.size.width, iTotalH)];
}

- (void)dealloc
{

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ( [DataCenter sharedDataCenter].isLogin )
    {
        CGRect loginBtnRect = _loginBtn.frame;
        loginBtnRect.origin.x = 100;
        [_loginBtn setFrame:loginBtnRect];
        
        NSDictionary* userInfoDic = [DataCenter sharedDataCenter].loginInfoDic;
     
        int nameLableX = _loginBtn.frame.origin.x + _loginBtn.frame.size.width + 20;
        int nameLabelY = _loginBtn.frame.origin.y + 10;
        
        [_nameLabel setFrame:CGRectMake(nameLableX, nameLabelY, 120, 16)];
        [_rankLabel setFrame:CGRectMake(nameLableX, nameLabelY+16+10, 120, 16)];
        
        [_nameLabel setHidden:NO];
        [_rankLabel setHidden:NO];
        
        [_nameLabel setText:[userInfoDic objectForKey:@"name"]];
        [_rankLabel setText:[userInfoDic objectForKey:@"rank_name"]];

    }
    else
    {
        CGPoint loginBtnCenter = _loginBtn.center;
        loginBtnCenter.x = self.view.frame.size.width/2;
        [_loginBtn setCenter:loginBtnCenter];
        
        [_nameLabel setHidden:YES];
        [_rankLabel setHidden:YES];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    
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

// 登录
-(void)onLoginClicked:(id)sender
{
    if ( [DataCenter sharedDataCenter].isLogin )
    {
        UserInfoViewController_ipa *viewControllerList = [[UserInfoViewController_ipa alloc] init];
        [self.navigationController pushViewController:viewControllerList animated:YES];
    }
    else
    {
        BasicViewController_ipa *viewControllerList = [[LoginViewController_ipa alloc] init];
        [self.navigationController pushViewController:viewControllerList animated:YES];
    }
}

// 账号管理
-(void)onCountMngClicked:(UITapGestureRecognizer*)sender
{
    if ( [DataCenter sharedDataCenter].isLogin )
    {
        UserInfoViewController_ipa *viewControllerList = [[UserInfoViewController_ipa alloc] init];
        [self.navigationController pushViewController:viewControllerList animated:YES];
    }
    else
    {
        BasicViewController_ipa *viewControllerList = [[LoginViewController_ipa alloc] init];
        [self.navigationController pushViewController:viewControllerList animated:YES];
    }
}

// 我的订单
-(void)onMyOrderListClicked:(UITapGestureRecognizer*)sender
{
    if ( [DataCenter sharedDataCenter].isLogin == false )
    {
        BasicViewController_ipa *viewControllerList = [[LoginViewController_ipa alloc] init];
        [self.navigationController pushViewController:viewControllerList animated:YES];
        return;
    }
    
    BasicViewController_ipa *viewControllerList = [[OrderListViewController_ipa alloc] init];
    viewControllerList.orderType = @"";
    [self.navigationController pushViewController:viewControllerList animated:YES];
}
-(void)onAwaitPayOrderClicked:(UITapGestureRecognizer*)sender
{
    if ( [DataCenter sharedDataCenter].isLogin == false )
    {
        BasicViewController_ipa *viewControllerList = [[LoginViewController_ipa alloc] init];
        [self.navigationController pushViewController:viewControllerList animated:YES];
        return;
    }
    
    BasicViewController_ipa *viewControllerList = [[OrderListViewController_ipa alloc] init];
    viewControllerList.orderType = @"await_pay";
    [self.navigationController pushViewController:viewControllerList animated:YES];
}
-(void)onAwaitShipOrderClicked:(UITapGestureRecognizer*)sender
{
    if ( [DataCenter sharedDataCenter].isLogin == false )
    {
        BasicViewController_ipa *viewControllerList = [[LoginViewController_ipa alloc] init];
        [self.navigationController pushViewController:viewControllerList animated:YES];
        return;
    }
    
    BasicViewController_ipa *viewControllerList = [[OrderListViewController_ipa alloc] init];
    viewControllerList.orderType = @"await_ship";
    [self.navigationController pushViewController:viewControllerList animated:YES];
}
-(void)onShipedOrderClicked:(UITapGestureRecognizer*)sender
{
    if ( [DataCenter sharedDataCenter].isLogin == false )
    {
        BasicViewController_ipa *viewControllerList = [[LoginViewController_ipa alloc] init];
        [self.navigationController pushViewController:viewControllerList animated:YES];
        return;
    }
    
    BasicViewController_ipa *viewControllerList = [[OrderListViewController_ipa alloc] init];
    viewControllerList.orderType = @"shipped";
    [self.navigationController pushViewController:viewControllerList animated:YES];
}
-(void)onFinishedOrderClicked:(UITapGestureRecognizer*)sender
{
    if ( [DataCenter sharedDataCenter].isLogin == false )
    {
        BasicViewController_ipa *viewControllerList = [[LoginViewController_ipa alloc] init];
        [self.navigationController pushViewController:viewControllerList animated:YES];
        return;
    }
    
    BasicViewController_ipa *viewControllerList = [[OrderListViewController_ipa alloc] init];
    viewControllerList.orderType = @"finished";
    [self.navigationController pushViewController:viewControllerList animated:YES];
}


// 收货地址管理
-(void)onAddrManageClicked:(UITapGestureRecognizer*)sender
{
    if ( [DataCenter sharedDataCenter].isLogin == false )
    {
        BasicViewController_ipa *viewControllerList = [[LoginViewController_ipa alloc] init];
        [self.navigationController pushViewController:viewControllerList animated:YES];
        return;
    }
    
    BasicViewController_ipa *viewControllerList = [[AddrListMngViewController_ipa alloc] init];
    [self.navigationController pushViewController:viewControllerList animated:YES];
}

// 我的收藏
-(void)onMyCollectClicked:(UITapGestureRecognizer*)sender
{
    if ( [DataCenter sharedDataCenter].isLogin == false )
    {
        BasicViewController_ipa *viewControllerList = [[LoginViewController_ipa alloc] init];
        [self.navigationController pushViewController:viewControllerList animated:YES];
        return;
    }
    
    BasicViewController_ipa *viewControllerList = [[CollectViewController_ipa alloc] init];
    [self.navigationController pushViewController:viewControllerList animated:YES];
}

// 帮助
-(void)onHelpClicked:(UITapGestureRecognizer*)sender
{
    BasicViewController_ipa *viewControllerList = [[HelpListViewController_ipa alloc] init];
    [self.navigationController pushViewController:viewControllerList animated:YES];
}

// 关于
-(void)onAboutClicked:(UITapGestureRecognizer*)sender
{
    BasicViewController_ipa *viewControllerList = [[AboutViewController_ipa alloc] init];
    [self.navigationController pushViewController:viewControllerList animated:YES];
}



@end
