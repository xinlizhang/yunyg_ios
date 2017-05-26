//
//  GoodsListViewController_ipa.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "GoodsDetailViewController_ipa.h"
#import "RDVTabBarController.h"
#import "UIImageView+OnlineImage.h"
#import "MyAlert.h"
#import "PublicDefine.h"
#import "LoginViewController_ipa.h"
#import "GoodsDescriptionViewController_ipa.h"
#import "GoodsPropertiesViewController_ipa.h"
#import "CommentListViewController_ipa.h"
#import "CommentAddViewController_ipa.h"
#import "MZTimerLabel.h"
#import "MyWebViewController_ipa.h"

@interface GoodsDetailViewController_ipa ()
{
    UIScrollView*       _scrollView;            // 整个详情界面的scrollview
    int                 _iGoodsID;              // 进入时保存的商品ID
    int                 _iGoodsBuyCount;        // 购买的商品数量
    UILabel*            _goodsCountLable;       // 购买的商品数量显示
    UIButton*           _reduceBtn;             // 增加购买数量按钮
    UIButton*           _addBtn;                // 减少购买数量按钮
    UIButton*           _collectBtn;            // 收藏按钮
    bool                _isWaiting4AddToCart;   // 是否有等待加入购物车的任务 用于点击加入购物车后去登陆界面 然后返回继续任务
    bool                _isWaiting4AddToClet;   // 是否有等待加入收藏的任务 用于点击加入收藏后去登陆界面 然后返回继续任务
    bool                _isWaiting4BuyNow;      // 是否有立即购买的任务 用于点击立即购买后去登陆界面 然后返回继续任务
    bool                _isAlreadyInCart;       // 当前商品是否已经加入到购物车中
    MyNetLoading*       _netLoading;
    NSMutableArray*     _selAttriArray;         // 选中的商品属性ID记录
    UILabel*            _posLabel;              // 实时显示
}
@end

@implementation GoodsDetailViewController_ipa

@synthesize goodsDetailDic = _goodsDetailDic;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initData];
        [self initUI];
    }
    return self;
}

-(void)initData
{
    _goodsDetailDic = [[NSMutableDictionary alloc] init];
    _iGoodsID = -1;
    _iGoodsBuyCount = 1;
    _isWaiting4AddToCart = false;
    _isWaiting4AddToClet = false;
    _isWaiting4BuyNow = false;
    _isAlreadyInCart = false;
    _selAttriArray = [[NSMutableArray alloc] init];
}

-(void)initUI
{
    CGRect frameR = self.view.frame;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width, frameR.size.height)];
    //[_scrollView setBackgroundColor:[UIColor colorWithRed:238.0/255 green:243.0/255 blue:246.0/255 alpha:1]];
    [_scrollView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_scrollView];
    [_scrollView setDelegate:self];
    [_scrollView release];
    
    // 收藏 加入购物车背景
    UIView* bottomBar1 = [[UIView alloc] initWithFrame:CGRectMake(0, frameR.size.height-60, frameR.size.width*3/5, 60)];
    [bottomBar1 setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
    [self.view addSubview:bottomBar1];
    [bottomBar1 release];
    
    // 收藏按钮
    _collectBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 33)];
    [_collectBtn setCenter:CGPointMake(frameR.size.width*3/20+10, frameR.size.height-bottomBar1.frame.size.height/2)];
    [_collectBtn setImage:[UIImage imageNamed:@"detail_attention_nor"] forState:UIControlStateNormal];
    [_collectBtn setImage:[UIImage imageNamed:@"detail_attention_hig"] forState:UIControlStateHighlighted];
    [_collectBtn setImage:[UIImage imageNamed:@"detail_attention_hig"] forState:UIControlStateDisabled];
    [_collectBtn addTarget:self action:@selector(onAttentionClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_collectBtn];
    [_collectBtn release];
    
    // 加入购物车按钮
    UIButton* addToCartBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 39, 26)];
    [addToCartBtn setCenter:CGPointMake(frameR.size.width*9/20-10, frameR.size.height-bottomBar1.frame.size.height/2+2)];
    [addToCartBtn setImage:[UIImage imageNamed:@"detail_add_car_nor"] forState:UIControlStateNormal];
    [addToCartBtn setImage:[UIImage imageNamed:@"detail_add_car_sel"] forState:UIControlStateSelected];
    [addToCartBtn addTarget:self action:@selector(onAddToCartClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addToCartBtn];
    [addToCartBtn release];
    

    
    // 立即购买
    UIView* bottomBar2 = [[UIView alloc] initWithFrame:CGRectMake(bottomBar1.frame.size.width, frameR.size.height-60, frameR.size.width*2/5, 60)];
    [bottomBar2 setBackgroundColor:[UIColor colorWithRed:255.0/255 green:78.0/255 blue:68.0/255 alpha:0.7]];
    [self.view addSubview:bottomBar2];
    bottomBar2.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBuyNowClicked:)];
    [bottomBar2 addGestureRecognizer:singleTap1];
    [singleTap1 release];
    [bottomBar2 release];
    UILabel* wordsBuyNowLabel = [[UILabel alloc] initWithFrame:bottomBar2.frame];
    [wordsBuyNowLabel setText:@"立即购买"];
    [wordsBuyNowLabel setNumberOfLines:1];
    [wordsBuyNowLabel setTextColor:[UIColor whiteColor]];
    [wordsBuyNowLabel setCenter:bottomBar2.center];
    [wordsBuyNowLabel setTextAlignment:NSTextAlignmentCenter];
    [wordsBuyNowLabel setFont:[UIFont systemFontOfSize:20]];
    [self.view addSubview:wordsBuyNowLabel];
    [wordsBuyNowLabel release];
    
    // loading
    _netLoading = [[MyNetLoading alloc] init];
    [_netLoading setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    [self.view addSubview:_netLoading];
    [_netLoading release];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"商品详情";
    self.view.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"viewWillAppear viewWillDisappear start!");
    [super viewWillAppear:animated];
    
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
    UINavigationController* navigationController = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
    [navigationController setNavigationBarHidden:NO animated:YES];
    
    if ( _iGoodsID <= 0 )
    {
        BasicViewController_ipa *basicViewController = (BasicViewController_ipa*)[navigationController topViewController];
        _iGoodsID = basicViewController.iGoodsIDClicked;
    
        [self requestData:_iGoodsID];
    }
    
    if ( _isWaiting4AddToCart )
    {
        if ( [DataCenter sharedDataCenter].isLogin )
        {
            _isWaiting4AddToCart = false;
            [self requestAddToCart];
        }
    }
    else if ( _isWaiting4BuyNow && [DataCenter sharedDataCenter].isLogin )
    {
        _isWaiting4BuyNow = false;
        
        [self EnterCartTab];
    }
    
    if ( _isWaiting4AddToClet && [DataCenter sharedDataCenter].isLogin )
    {
        _isWaiting4AddToClet = false;
        [self requestAddToCollect];
    }
    NSLog(@"viewWillAppear viewWillDisappear end!");
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"GoodsDetailViewController_ipa viewWillDisappear start!");
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    
    [super viewWillDisappear:animated];
    
    UINavigationController* pNv = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
    [pNv setNavigationBarHidden:YES animated:YES];
    NSLog(@"GoodsDetailViewController_ipa viewWillDisappear end!");
}


#pragma mark - network
-(void)updateUI
{
    CGRect frameR = self.view.frame;
    
    // 滚动相册
    float top = 0;
    float height = 500;
    
    _posLabel = [[UILabel alloc] initWithFrame:CGRectMake(frameR.size.width-30-10, height-30-10, 30, 30)];
    [_posLabel setBackgroundColor:[UIColor clearColor]];
    [_posLabel setTextColor:[UIColor whiteColor]];
    [_posLabel setFont:[UIFont systemFontOfSize:13]];
    [_posLabel setTextAlignment:NSTextAlignmentCenter];
    [_posLabel.layer setCornerRadius:15.0];
    [_posLabel.layer setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f].CGColor];
    
    GalleryScrollView_ipa* galleryScrollView = [[GalleryScrollView_ipa alloc] initWithFrame:CGRectMake(0, top, frameR.size.width, height)];
    [galleryScrollView setDeleteGallery:self];
    [galleryScrollView updateWithDataArray:[_goodsDetailDic objectForKey:@"pictures"]];
    
    [_scrollView addSubview:galleryScrollView];
    [galleryScrollView release];
    
    [_scrollView addSubview:_posLabel];
    [_posLabel release];
    
    // 属性共同的横坐标
    int commonX = 80;
    
    top += height;
    height = 0.5;
    UIView* seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(5, top, frameR.size.width-10, height)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [_scrollView addSubview:seperatorlINE];
    [seperatorlINE release];
    
    // 商品名称
    top = top + height + 10;
    height = 40;
    UILabel* goodsNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(commonX, top, frameR.size.width-15-25, height)];
    [goodsNameLabel setText:[_goodsDetailDic objectForKey:@"goods_name"]];
    [goodsNameLabel setNumberOfLines:2];
    [goodsNameLabel setTextColor:[UIColor colorWithRed:24.0/255 green:24.0/255 blue:24.0/255 alpha:1]];
    [goodsNameLabel setTextAlignment:NSTextAlignmentLeft];
    [goodsNameLabel setFont:[UIFont systemFontOfSize:14]];
    [_scrollView addSubview:goodsNameLabel];
    [goodsNameLabel release];
    
    goodsNameLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onIntroductionClicked:)];
    [goodsNameLabel addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    UIImageView* rightIdentify = [[UIImageView alloc] initWithFrame:CGRectMake(frameR.size.width-20, 0, 10, 10)];
    [rightIdentify setImage:[UIImage imageNamed:@"home_btn_godetail"]];
    [_scrollView addSubview:rightIdentify];
    [rightIdentify release];
    CGPoint rightPos = rightIdentify.center;
    rightPos.y = goodsNameLabel.center.y;
    [rightIdentify setCenter:rightPos];
    
    
    // 商品价格
    top = top + height + 10;
    height = 16;
    UILabel* goodsPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(commonX, top, frameR.size.width-30, height)];
    if ( [[_goodsDetailDic objectForKey:@"is_promote"] compare:@"1"] == NSOrderedSame )
    {
        [goodsPriceLabel setText:[_goodsDetailDic objectForKey:@"formated_promote_price"]];
    }
    else
    {
        [goodsPriceLabel setText:[_goodsDetailDic objectForKey:@"shop_price"]];
    }
    [goodsPriceLabel setNumberOfLines:1];
    [goodsPriceLabel setTextColor:[UIColor colorWithRed:233.0/255 green:83.0/255 blue:83.0/255 alpha:1]];
    [goodsPriceLabel setTextAlignment:NSTextAlignmentLeft];
    [goodsPriceLabel setFont:[UIFont systemFontOfSize:14]];
    [_scrollView addSubview:goodsPriceLabel];
    [goodsPriceLabel release];

    // 显示打折时间倒计时
    if ( [[_goodsDetailDic objectForKey:@"is_promote"] compare:@"1"] == NSOrderedSame )
    {
        top = top + height + 10;
        height = 16;
        
        UILabel* timerWdsLabel = [[UILabel alloc] initWithFrame:CGRectMake(commonX, top, 70, height)];
        [timerWdsLabel setBackgroundColor:[UIColor clearColor]];
        [timerWdsLabel setTextColor:[UIColor lightGrayColor]];
        [timerWdsLabel setFont:[UIFont systemFontOfSize:15]];
        [timerWdsLabel setText:@"剩余时间:"];
        [_scrollView addSubview:timerWdsLabel];
        [timerWdsLabel release];
        
        MZTimerLabel* timerLabel = [[MZTimerLabel alloc] initWithTimerType:MZTimerLabelTypeTimer];
        timerLabel.frame = CGRectMake(commonX+70, top, frameR.size.width-100, height);
        timerLabel.textAlignment = NSTextAlignmentLeft;
        timerLabel.timeLabel.font = [UIFont systemFontOfSize:15];
        timerLabel.timeLabel.textColor = [UIColor lightGrayColor];
        
        int iPromoteEndTime = [[_goodsDetailDic valueForKey:@"promote_end_date"] intValue];
        int now = [[NSDate date] timeIntervalSince1970];
        [timerLabel setCountDownTime:(iPromoteEndTime - now)];
        [timerLabel setShouldCountBeyondHHLimit:YES];
        [timerLabel start];
        
        [_scrollView addSubview:timerLabel];
        [timerLabel release];
    }
    
    top = top + height + 10;
    height = 0.5;
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(5, top, frameR.size.width-10, height)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [_scrollView addSubview:seperatorlINE];
    [seperatorlINE release];
    
    // 属性选择
    NSArray* attributeArray = [_goodsDetailDic objectForKey:@"specification"];
    // 存在属性选择
    for (int i = 0; i < [attributeArray count]; i++)
    {
        // 逐个取出商品属性
        top = top + height + 10;
        height = 20;
        NSDictionary* attriDic = [attributeArray objectAtIndex:i];
        
        // 显示属性标题
        UILabel* attriNameLable= [[UILabel alloc] initWithFrame:CGRectMake(commonX, top, frameR.size.width-2*commonX, height)];
        [attriNameLable setText:[NSString stringWithFormat:@"%@",[attriDic valueForKey:@"name"]]];
        [attriNameLable setNumberOfLines:1];
        [attriNameLable setTextColor:[UIColor blackColor]];
        [attriNameLable setTextAlignment:NSTextAlignmentLeft];
        [attriNameLable setFont:[UIFont systemFontOfSize:13]];
        [_scrollView addSubview:attriNameLable];
        [attriNameLable release];
        
        // 显示属性内容 所有内容填充到背景上 用以区分具体是哪个属性
        NSArray* valueArray = [attriDic objectForKey:@"value"];
        top = top + height + 5;
        height = 0; // 整体高度 排版后重置
        
        UIView* attributeBG = [[UIView alloc] initWithFrame:CGRectMake(0, top, frameR.size.width, 0)];
        [attributeBG setBackgroundColor:[UIColor clearColor]];
        attributeBG.tag = (i + 1000);
        [_scrollView addSubview:attributeBG];
        [attributeBG release];
        
        int iRowNum = 0;                // 记录行数 用于纵向排版
        int iStartX = 30;               // 每个控件起始坐标
        for (int j = 0; j < [valueArray count]; j++)
        {
            NSDictionary* valueDic = [valueArray objectAtIndex:j];
            float wdsW = [Utils widthForString:[valueDic valueForKey:@"label"] fontSize:12] + 10;
            
            // 控件创建
            UILabel* valueLabel = [[UILabel alloc] init];
            [valueLabel setText:[valueDic valueForKey:@"label"]];
            [valueLabel.layer setBorderColor:[UIColor grayColor].CGColor];
            [valueLabel setTag:(j+1000)];
            [valueLabel.layer setCornerRadius:3.0];
            [valueLabel.layer setBorderWidth:0.5f];
            [valueLabel setBackgroundColor:[UIColor whiteColor]];
            [valueLabel setFont:[UIFont systemFontOfSize:12]];
            [valueLabel setTextAlignment:NSTextAlignmentCenter];
            [valueLabel setTextColor:[UIColor grayColor]];
            [attributeBG addSubview:valueLabel];
            [valueLabel release];
            
            // 第一件默认选中
            if ( j == 0 )
            {
                [valueLabel.layer setBorderColor:[UIColor redColor].CGColor];
                [_selAttriArray insertObject:[valueDic valueForKey:@"id"] atIndex:i];       // 每个大的属性分类只有一个是被选中的
            }
            
            // touch事件注册
            valueLabel.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAttributeClicked:)];
            [valueLabel addGestureRecognizer:tapGesture];
            [tapGesture release];
            
            // 动态排版
            if ( frameR.size.width < (iStartX + wdsW + 15) )
            {
                iStartX = 30;
                iRowNum++;
            }
            [valueLabel setFrame:CGRectMake(iStartX, iRowNum*(20+5), wdsW, 20)];
            iStartX = iStartX + wdsW + 10;
        }
        
        top = top + height;
        height = (iRowNum + 1) * (20 + 5);
        CGRect attrBgR = attributeBG.frame;
        attrBgR.size.height = height;
        [attributeBG setFrame:attrBgR];
    }
    
    
    top = top + height + 10;
    height = 25;
    _reduceBtn = [[UIButton alloc] initWithFrame:CGRectMake(commonX, top, 25, height)];
    [_reduceBtn setImage:[UIImage imageNamed:@"goods_redu_btn_nor"] forState:UIControlStateNormal];
    [_reduceBtn setImage:[UIImage imageNamed:@"goods_redu_btn_sel"] forState:UIControlStateSelected];
    [_reduceBtn setImage:[UIImage imageNamed:@"goods_redu_btn_dis"] forState:UIControlStateDisabled];
    [_reduceBtn addTarget:self action:@selector(onReduBuyCountClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_reduceBtn];
    [_reduceBtn release];
    if ( _iGoodsBuyCount <=0 )
        _reduceBtn.enabled = false;
    
    UIImageView* goodsCountBG = [[UIImageView alloc] initWithFrame:CGRectMake(_reduceBtn.frame.origin.x+_reduceBtn.frame.size.width, top, 25+10, height)];
    [goodsCountBG setImage:[UIImage imageNamed:@"goods_count_bg"]];
    [_scrollView addSubview:goodsCountBG];
    [goodsCountBG release];
    
    _goodsCountLable= [[UILabel alloc] initWithFrame:goodsCountBG.frame];
    [_goodsCountLable setText:[NSString stringWithFormat:@"%d",_iGoodsBuyCount]];
    [_goodsCountLable setNumberOfLines:1];
    [_goodsCountLable setTextColor:[UIColor blackColor]];
    [_goodsCountLable setCenter:goodsCountBG.center];
    [_goodsCountLable setTextAlignment:NSTextAlignmentCenter];
    [_goodsCountLable setFont:[UIFont systemFontOfSize:14]];
    [_scrollView addSubview:_goodsCountLable];
    [_goodsCountLable release];
    
    float addBtnX = goodsCountBG.frame.origin.x + goodsCountBG.frame.size.width;
    _addBtn = [[UIButton alloc] initWithFrame:CGRectMake(addBtnX, top, 25, height)];
    [_addBtn setImage:[UIImage imageNamed:@"goods_add_btn_nor"] forState:UIControlStateNormal];
    [_addBtn setImage:[UIImage imageNamed:@"goods_add_btn_sel"] forState:UIControlStateSelected];
    [_addBtn setImage:[UIImage imageNamed:@"goods_add_btn_dis"] forState:UIControlStateDisabled];
    [_addBtn addTarget:self action:@selector(onAddBuyCountClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_addBtn];
    [_addBtn release];
    int goodsNum = [[_goodsDetailDic objectForKey:@"goods_number"] intValue];
    if ( goodsNum <= _iGoodsBuyCount )
        _addBtn.enabled = false;
    
    top = top + height + 10;
    height = 0.5;
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(5, top, frameR.size.width-10, height)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [_scrollView addSubview:seperatorlINE];
    [seperatorlINE release];
    
    // 送至
    top = top + height + 10;
    height = 16;
    UILabel* addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(commonX, top, frameR.size.width-30, height)];
    [addressLabel setText:@"送至"];
    [addressLabel setNumberOfLines:1];
    [addressLabel setTextColor:[UIColor lightGrayColor]];
    [addressLabel setTextAlignment:NSTextAlignmentLeft];
    [addressLabel setFont:[UIFont systemFontOfSize:12]];
    [_scrollView addSubview:addressLabel];
    [addressLabel release];
    
    addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(commonX + 35, top, frameR.size.width-30, height)];
    [addressLabel setText:@"辽宁 葫芦岛市 建昌县"];
    [addressLabel setNumberOfLines:1];
    [addressLabel setTextColor:[UIColor grayColor]];
    [addressLabel setTextAlignment:NSTextAlignmentLeft];
    [addressLabel setFont:[UIFont systemFontOfSize:12]];
    [_scrollView addSubview:addressLabel];
    [addressLabel release];
    
    // 服务
    top = top + height + 10;
    height = 16;
    UILabel* serviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(commonX, top, frameR.size.width-30, height)];
    [serviceLabel setText:@"服务"];
    [serviceLabel setNumberOfLines:1];
    [serviceLabel setTextColor:[UIColor lightGrayColor]];
    [serviceLabel setTextAlignment:NSTextAlignmentLeft];
    [serviceLabel setFont:[UIFont systemFontOfSize:12]];
    [_scrollView addSubview:serviceLabel];
    [serviceLabel release];
    
    serviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(commonX + 35, top, frameR.size.width-30, height)];
    [serviceLabel setText:@"由雲易购发货并提供售后服务"];
    [serviceLabel setNumberOfLines:1];
    [serviceLabel setTextColor:[UIColor grayColor]];
    [serviceLabel setTextAlignment:NSTextAlignmentLeft];
    [serviceLabel setFont:[UIFont systemFontOfSize:12]];
    [_scrollView addSubview:serviceLabel];
    [serviceLabel release];
    
    // 提示
    top = top + height + 10;
    height = 16;
    UILabel* noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(commonX, top, frameR.size.width-30, height)];
    [noticeLabel setText:@"提示"];
    [noticeLabel setNumberOfLines:1];
    [noticeLabel setTextColor:[UIColor lightGrayColor]];
    [noticeLabel setTextAlignment:NSTextAlignmentLeft];
    [noticeLabel setFont:[UIFont systemFontOfSize:12]];
    [_scrollView addSubview:noticeLabel];
    [noticeLabel release];
    
    noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(commonX + 35, top, frameR.size.width-30, height)];
    [noticeLabel setText:@"支持7天无理由退货"];
    [noticeLabel setNumberOfLines:1];
    [noticeLabel setTextColor:[UIColor colorWithRed:109.0/255 green:121.0/255 blue:171.0/255 alpha:1.0]];
    [noticeLabel setTextAlignment:NSTextAlignmentLeft];
    [noticeLabel setFont:[UIFont systemFontOfSize:12]];
    [_scrollView addSubview:noticeLabel];
    [noticeLabel release];
    
    top = top + height + 10;
    height = 0.5;
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(5, top, frameR.size.width-10, height)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [_scrollView addSubview:seperatorlINE];
    [seperatorlINE release];
    
    // 商品介绍
    top = top + height + 10;
    height = 40;
    UILabel* introductionLable = [[UILabel alloc] initWithFrame:CGRectMake(commonX, top, frameR.size.width-2*commonX, height)];
    [introductionLable.layer setBackgroundColor:[UIColor whiteColor].CGColor];
    [introductionLable.layer setCornerRadius:5];
    [introductionLable.layer setBorderWidth:1];
    [introductionLable.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [introductionLable setText:@"商品介绍"];
    [introductionLable setNumberOfLines:1];
    [introductionLable setTextColor:[UIColor blackColor]];
    [introductionLable setTextAlignment:NSTextAlignmentCenter];
    [introductionLable setFont:[UIFont systemFontOfSize:14]];
    [_scrollView addSubview:introductionLable];
    [introductionLable release];
    
    introductionLable.userInteractionEnabled = YES;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onIntroductionClicked:)];
    [introductionLable addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    // 规格参数
    top = top + height + 10;
    height = 40;
    UILabel* specificationParamLable = [[UILabel alloc] initWithFrame:CGRectMake(commonX, top, frameR.size.width-2*commonX, height)];
    [specificationParamLable.layer setBackgroundColor:[UIColor whiteColor].CGColor];
    [specificationParamLable.layer setCornerRadius:5];
    [specificationParamLable.layer setBorderWidth:1];
    [specificationParamLable.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [specificationParamLable setText:@"规格参数"];
    [specificationParamLable setNumberOfLines:1];
    [specificationParamLable setTextColor:[UIColor blackColor]];
    [specificationParamLable setTextAlignment:NSTextAlignmentCenter];
    [specificationParamLable setFont:[UIFont systemFontOfSize:14]];
    [_scrollView addSubview:specificationParamLable];
    [specificationParamLable release];
    
    specificationParamLable.userInteractionEnabled = YES;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSpecificationParamClicked:)];
    [specificationParamLable addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    
    // 查看评论
    top = top + height + 10;
    height = 40;
    UILabel* customerServiceLable = [[UILabel alloc] initWithFrame:CGRectMake(commonX, top, frameR.size.width-2*commonX, height)];
    [customerServiceLable.layer setBackgroundColor:[UIColor whiteColor].CGColor];
    [customerServiceLable.layer setCornerRadius:5];
    [customerServiceLable.layer setBorderWidth:1];
    [customerServiceLable.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [customerServiceLable setText:@"查看评论"];
    [customerServiceLable setNumberOfLines:1];
    [customerServiceLable setTextColor:[UIColor blackColor]];
    [customerServiceLable setTextAlignment:NSTextAlignmentCenter];
    [customerServiceLable setFont:[UIFont systemFontOfSize:14]];
    [_scrollView addSubview:customerServiceLable];
    [customerServiceLable release];
    
    customerServiceLable.userInteractionEnabled = YES;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCustomerServiceClicked:)];
    [customerServiceLable addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    
    // 增加评论
    top = top + height + 10;
    height = 40;
    UILabel* commentAddLable = [[UILabel alloc] initWithFrame:CGRectMake(commonX, top, frameR.size.width-2*commonX, height)];
    [commentAddLable.layer setBackgroundColor:[UIColor whiteColor].CGColor];
    [commentAddLable.layer setCornerRadius:5];
    [commentAddLable.layer setBorderWidth:1];
    [commentAddLable.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [commentAddLable setText:@"增加评论"];
    [commentAddLable setNumberOfLines:1];
    [commentAddLable setTextColor:[UIColor blackColor]];
    [commentAddLable setTextAlignment:NSTextAlignmentCenter];
    [commentAddLable setFont:[UIFont systemFontOfSize:14]];
    [_scrollView addSubview:commentAddLable];
    [commentAddLable release];
    
    commentAddLable.userInteractionEnabled = YES;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCommentAddClicked:)];
    [commentAddLable addGestureRecognizer:tapGesture];
    [tapGesture release];
    

    // 联系客服
    top = top + height + 10;
    height = 40;
    UILabel* customerLable = [[UILabel alloc] initWithFrame:CGRectMake(commonX, top, frameR.size.width-2*commonX, height)];
    [customerLable.layer setBackgroundColor:[UIColor whiteColor].CGColor];
    [customerLable.layer setCornerRadius:5];
    [customerLable.layer setBorderWidth:1];
    [customerLable.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [customerLable setText:@"联系客服"];
    [customerLable setNumberOfLines:1];
    [customerLable setTextColor:[UIColor blackColor]];
    [customerLable setTextAlignment:NSTextAlignmentCenter];
    [customerLable setFont:[UIFont systemFontOfSize:14]];
    [_scrollView addSubview:customerLable];
    [customerLable release];
    
    customerLable.userInteractionEnabled = YES;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCustomerAddClicked:)];
    [customerLable addGestureRecognizer:tapGesture];
    [tapGesture release];
    

    top = top + height + 10;
    height = 0.5;
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(5, top, frameR.size.width-10, height)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [_scrollView addSubview:seperatorlINE];
    [seperatorlINE release];
    
    int iTotalH = top + height + 60 + 3;        // 60 底边栏高度
    [_scrollView setContentSize:CGSizeMake(frameR.size.width, iTotalH)];
}

#pragma mark - 各种点击事件
-(void)onReduBuyCountClicked:(id)sender
{
    _iGoodsBuyCount--;
    int goodsNum = [[_goodsDetailDic objectForKey:@"goods_number"] intValue];
    if ( _iGoodsBuyCount <= 0 )
    {
        _iGoodsBuyCount = 0;
        _reduceBtn.enabled = false;
    }
    if ( _addBtn.enabled == false && _iGoodsBuyCount < goodsNum )
        _addBtn.enabled = true;

    [_goodsCountLable setText:[NSString stringWithFormat:@"%d",_iGoodsBuyCount]];
}

-(void)onAddBuyCountClicked:(id)sender
{
    _iGoodsBuyCount++;
    int goodsNum = [[_goodsDetailDic objectForKey:@"goods_number"] intValue];
    if ( goodsNum <= _iGoodsBuyCount )
    {
        _addBtn.enabled = false;
        _reduceBtn.enabled = true;
    }
    if ( _reduceBtn.enabled == false && 0 < _iGoodsBuyCount )
        _reduceBtn.enabled = true;
    
    [_goodsCountLable setText:[NSString stringWithFormat:@"%d",_iGoodsBuyCount]];
}

-(void)EnterCartTab
{
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    
    UINavigationController* pNv = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
    [pNv setNavigationBarHidden:YES animated:YES];
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    RDVTabBarController* tabBarController = (RDVTabBarController*)[UIApplication sharedApplication].keyWindow.rootViewController;
    [tabBarController setSelectedIndex:2];
}

-(void)onBuyNowClicked:(id)sender
{
    if ( _isAlreadyInCart == false )
    {
        _isWaiting4BuyNow = true;
        [self onAddToCartClicked:nil];
        return;
    }
    else
    {
        NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
        if ( [sessionDic count] <= 0 || [DataCenter sharedDataCenter].isLogin == false )
        {
            _isWaiting4BuyNow = true;
            BasicViewController_ipa *viewControllerList = [[LoginViewController_ipa alloc] init];
            [self.navigationController pushViewController:viewControllerList animated:YES];
            return;
        }
    }
    
    [self EnterCartTab];
}

-(void)onAttentionClicked:(id)sender
{
    if ( _iGoodsID <= 0 )
        return;
    
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    if ( [sessionDic count] <= 0 || [DataCenter sharedDataCenter].isLogin == false )
    {
        BasicViewController_ipa *viewControllerList = [[LoginViewController_ipa alloc] init];
        [self.navigationController pushViewController:viewControllerList animated:YES];
        _isWaiting4AddToClet = true;
        return;
    }
    
    [self requestAddToCollect];
}

-(void)onAddToCartClicked:(id)sender
{
    if ( _iGoodsID <= 0 )
        return;
    if ( NSOrderedSame == [_goodsCountLable.text compare:@""] )
        return;
    
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    if ( [sessionDic count] <= 0 || [DataCenter sharedDataCenter].isLogin == false )
    {
        BasicViewController_ipa *viewControllerList = [[LoginViewController_ipa alloc] init];
        [self.navigationController pushViewController:viewControllerList animated:YES];
        _isWaiting4AddToCart = true;
        return;
    }
    
    [self requestAddToCart];
}

-(void)onIntroductionClicked:(id)sender
{
    BasicViewController_ipa *viewController = [[GoodsDescriptionViewController_ipa alloc] init];
    viewController.iGoodsID2Info = _iGoodsID;
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)onSpecificationParamClicked:(id)sender
{
    GoodsPropertiesViewController_ipa *viewController = [[GoodsPropertiesViewController_ipa alloc] init];
    [viewController updateUI:[_goodsDetailDic objectForKey:@"properties"]];
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)onCustomerServiceClicked:(id)sender
{
    CommentListViewController_ipa *viewController = [[CommentListViewController_ipa alloc] init];
    viewController.iGoodsID2Info = _iGoodsID;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)onCommentAddClicked:(id)sender
{
    CommentAddViewController_ipa *viewController = [[CommentAddViewController_ipa alloc] init];
    [viewController showGoodsInfo:_goodsDetailDic];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)onCustomerAddClicked:(id)sender
{
    BasicViewController_ipa *viewController = [[MyWebViewController_ipa alloc] init];
    viewController.strURL = CUSTOMER_URL;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)onAttributeClicked:(UITapGestureRecognizer*)sender
{
    // UI处理
    UIView* attributeBG = sender.view.superview;
    for ( UIView* subView in attributeBG.subviews )
    {
        [subView.layer setBorderColor:[UIColor grayColor].CGColor];
    }
    
    [sender.view.layer setBorderColor:[UIColor redColor].CGColor];
    
    // 数据处理
    NSInteger attributeArrayIndex = attributeBG.tag - 1000;
    NSArray* attributeArray = [_goodsDetailDic objectForKey:@"specification"];
    if ( attributeArrayIndex < 0 || [attributeArray count] <= attributeArrayIndex )
        return;
    
    NSInteger valueArrayIndex = sender.view.tag - 1000;
    NSDictionary* attriDic = [attributeArray objectAtIndex:attributeArrayIndex];
    NSArray* valueArray = [attriDic objectForKey:@"value"];
    if ( valueArrayIndex < 0 || [valueArray count] <= valueArrayIndex )
        return;
    
    NSDictionary* valueDic = [valueArray objectAtIndex:valueArrayIndex];
    NSString* strValueID = [valueDic valueForKey:@"id"];
    
    [_selAttriArray removeObjectAtIndex:attributeArrayIndex];
    [_selAttriArray insertObject:strValueID atIndex:attributeArrayIndex];
}

#pragma mark - scroll view delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _scrollView)
    {
        
    }
}

-(void)onGalleryScrollViewPage:(int)curPage totalPage:(int)totalPage
{
    NSString* strPos = [NSString stringWithFormat:@"%d/%d", curPage, totalPage];
    [_posLabel setText:strPos];
}

#pragma mark - network
-(void)requestData : (int)goodsID
{
    [_netLoading startAnimating];
    
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [net request_GoodsDetail_Datasuc:^(id success) {
        
        [_netLoading stopAnimating];

        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            [_goodsDetailDic setValuesForKeysWithDictionary:success[@"data"]];
            if ( [[_goodsDetailDic objectForKey:@"collected"] intValue] == 1 )
                _collectBtn.enabled = false;
            [self updateUI];
        }
        else if( success[@"status"] && [[success[@"status"] valueForKey:@"error_code"] intValue] == 100 )
        {
            [MyAlert showMessage:@"您的账号已过期，请尝试重新登陆！" timer:4.0f];
            [[DataCenter sharedDataCenter] removeLoginData];
        }
        else if( success[@"status"] && [[success[@"status"] valueForKey:@"error_desc"] intValue] == 100 )
        {
            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:[success[@"status"] valueForKey:@"error_desc"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alter show];
            [alter release];
        }
    } fail:^(NSError *error) {
        
        [_netLoading stopAnimating];
        
    } goodsID:goodsID];
}

-(void)requestAddToCart
{
    int goodsNum = [_goodsCountLable.text intValue];
    
    [_netLoading startAnimating];
    
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [net request_AddToCart_Datasuc:^(id success) {
        
        [_netLoading stopAnimating];

        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            _isAlreadyInCart = true;
                
            if ( _isWaiting4BuyNow && [DataCenter sharedDataCenter].isLogin )
            {
                _isWaiting4BuyNow = false;
                    
                [self performSelector:@selector(EnterCartTab) withObject:nil afterDelay:0.2];
            }
                
            // 更新购物车商品数量显示
            int iCartNum = [[[DataCenter sharedDataCenter].loginInfoDic valueForKey:@"cart_num"] intValue] + 1;
            [[DataCenter sharedDataCenter] editLoginInfo:[NSString stringWithFormat:@"%d",iCartNum] forKey:@"cart_num"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowCartCount" object:nil];
            
            [MyAlert showMessage:@"添加成功" timer:2.0f];
        }
        else
        {
            [MyAlert showMessage:@"添加失败" timer:2.0f];
        }
        
    } fail:^(NSError *error) {
        
        [MyAlert showMessage:@"添加失败" timer:2.0f];
        [_netLoading stopAnimating];
        
    } goodsID:_iGoodsID goodsNum:goodsNum  specArray:_selAttriArray];
}

-(void)requestAddToCollect
{
    [_netLoading startAnimating];
    
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [net request_AddToCollect_Datasuc:^(id success) {
        
        [_netLoading stopAnimating];

        if (success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            _collectBtn.enabled = false;
                
            [MyAlert showMessage:@"添加成功" timer:2.0f];
        }
        else
        {
            [MyAlert showMessage:[success[@"status"] valueForKey:@"error_desc"] timer:2.0f];
        }
        
    } fail:^(NSError *error) {
        
        [MyAlert showMessage:@"添加失败" timer:2.0f];
        [_netLoading stopAnimating];
        
    } goodsID:_iGoodsID];
}

@end

