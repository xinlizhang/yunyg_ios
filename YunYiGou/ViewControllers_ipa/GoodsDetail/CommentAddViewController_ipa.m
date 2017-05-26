//
//  MineViewController_ipa.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "CommentAddViewController_ipa.h"
#import "RDVTabBarController.h"
#import "EGORefreshTableFooterView.h"
#import "MyAlert.h"
#import "UIImageView+OnlineImage.h"

@interface CommentAddViewController_ipa () <UITextViewDelegate>
{
    int                         _iTopBarH;
    int                         _iGoodsID;                      // 记录被评论商品的ID
    int                         _iRandCount;                    // 评星等级
    
    UIImageView*                _goodsImageView;
    UILabel*                    _goodsNameLabel;
    
    UILabel*                    _cmtWdsCountLabel;              // 评论字数计数
    
    UITextView*                 _commentTextView;               // 评论内容
    
    MyNetLoading*               _netLoading;

}

@end

@implementation CommentAddViewController_ipa

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
    _iTopBarH = 64;
    _iGoodsID = 0;
    _iRandCount = 0;
}

-(void)initUI
{
    NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: @"7.0" options: NSNumericSearch];
    if (order == NSOrderedSame || order == NSOrderedDescending)
    {
        // OS version >= 7.0
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    CGRect frameR = self.view.frame;
    
    // 商品
    CGPoint relationP = CGPointMake(0, 0);
    int height = 80;
    
    UILabel* goodsBGLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width, height)];
    [goodsBGLabel setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:goodsBGLabel];
    [goodsBGLabel release];
    
    _goodsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, height - 20, height - 20)];
    [self.view addSubview:_goodsImageView];
    [_goodsImageView release];
    
    _goodsNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(height, 10, frameR.size.width-height-10, height-20)];
    [_goodsNameLabel setNumberOfLines:3];
    [_goodsNameLabel setTextColor:[UIColor colorWithRed:38.0/255 green:38.0/255 blue:38.0/255 alpha:1]];
    [_goodsNameLabel setTextAlignment:NSTextAlignmentLeft];
    [_goodsNameLabel setFont:[UIFont systemFontOfSize:12]];
    [self.view addSubview:_goodsNameLabel];
    [_goodsNameLabel release];
    
    // 评论
    relationP.y = relationP.y + height + 10;
    height = 120;
    UILabel* commentBGLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [commentBGLabel setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:commentBGLabel];
    [commentBGLabel release];
    
    CGPoint commentRP = CGPointMake(relationP.x, relationP.y);
    int commentH = 30;
    UILabel* randLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, commentRP.y, 50, commentH)];
    [randLabel setBackgroundColor:[UIColor clearColor]];
    [randLabel setText:@"评价:"];
    [randLabel setTextAlignment:NSTextAlignmentCenter];
    [randLabel setFont:[UIFont systemFontOfSize:13]];
    [randLabel setTextColor:[UIColor grayColor]];
    [self.view addSubview:randLabel];
    [randLabel release];
    
    for ( int i = 0; i < 5; i++ )
    {
        UIButton* editBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 13, 13)];
        [editBtn setCenter:CGPointMake(randLabel.frame.size.width+10 + i*30, commentRP.y + randLabel.frame.size.height/2)];
        [editBtn setImage:[UIImage imageNamed:@"comment_star_dis"] forState:UIControlStateNormal];
        [editBtn setImage:[UIImage imageNamed:@"comment_star_ena"] forState:UIControlStateSelected];
        [editBtn setImage:[UIImage imageNamed:@"comment_star_dis"] forState:UIControlStateDisabled];
        [editBtn addTarget:self action:@selector(OnRankClicked:) forControlEvents:UIControlEventTouchUpInside];
        [editBtn setTag:(i+1000)];
        [self.view addSubview:editBtn];
        [editBtn release];
    }
    
    _cmtWdsCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(frameR.size.width-50, commentRP.y, 50, 30)];
    _cmtWdsCountLabel.backgroundColor = [UIColor clearColor];
    _cmtWdsCountLabel.text = @"0";
    _cmtWdsCountLabel.textColor = [UIColor lightGrayColor];
    _cmtWdsCountLabel.font = [UIFont systemFontOfSize:13];
    _cmtWdsCountLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_cmtWdsCountLabel];
    [_cmtWdsCountLabel release];
    
    
    commentRP.y = commentRP.y + commentH;
    commentH = 80;
    _commentTextView= [[UITextView alloc] initWithFrame:CGRectMake(10, commentRP.y, frameR.size.width-20, commentH)];
    _commentTextView.text = @"长度在10~500个字之间\n写下购买体会或使用过程中带来的帮助等，可以为其他小伙伴提供参考~";
    _commentTextView.keyboardType = UIKeyboardAppearanceDefault;
    _commentTextView.backgroundColor = [UIColor whiteColor];
    _commentTextView.textAlignment = NSTextAlignmentLeft;
    _commentTextView.font = [UIFont systemFontOfSize:12];
    _commentTextView.textColor = [UIColor grayColor];
    _commentTextView.clearsContextBeforeDrawing = YES;
    _commentTextView.delegate = self;
    [self.view addSubview:_commentTextView];
    [_commentTextView release];
    
    // 提交按钮
    relationP.y = relationP.y + height + 10;
    height = 30;
    UILabel* commitBtnLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, relationP.y, frameR.size.width-40, height)];
    commitBtnLabel.backgroundColor = [UIColor colorWithRed:241.0/255 green:83.0/255 blue:80.0/255 alpha:1.0];
    commitBtnLabel.text = @"确认提交";
    commitBtnLabel.textColor = [UIColor whiteColor];
    commitBtnLabel.userInteractionEnabled = YES;
    [commitBtnLabel setTextAlignment:NSTextAlignmentCenter];
    //commitBtnLabel.layer.cornerRadius = commitBtnLabel.bounds.size.width/2;
    //commitBtnLabel.layer.masksToBounds = YES;
    [self.view addSubview:commitBtnLabel];
    [commitBtnLabel release];
    
    UITapGestureRecognizer *loginReco = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OnCommitClicked:)];
    [commitBtnLabel addGestureRecognizer:loginReco];
    [loginReco release];
    
    // loading
    _netLoading = [[MyNetLoading alloc] init];
    [_netLoading setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    [self.view addSubview:_netLoading];
    [_netLoading release];
}

- (void)dealloc
{
    [super dealloc];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:238.0/255 green:243.0/255 blue:246.0/255 alpha:1];
    
    self.title = @"撰写评论";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
    UINavigationController* navigationController = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
    [navigationController setNavigationBarHidden:NO animated:YES];
    
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

- (void)showGoodsInfo:(NSDictionary*)goodsDic
{
    [_goodsImageView setOnlineImage:goodsDic[@"img"][@"small"] placeholderImage:[UIImage imageNamed:@"common_img_loding"]];
    [_goodsNameLabel setText:goodsDic[@"goods_name"]];
    _iGoodsID = [goodsDic[@"id"] intValue];
}

#pragma mark - button clicked event
- (void)OnCommitClicked:(id)sender
{
    if ( _iRandCount <= 0 )
    {
        [MyAlert showMessage:@"请选择评星等级" timer:2.0f];
        return;
    }
    if ( _commentTextView==nil || [_commentTextView.text compare:@""]==NSOrderedSame )
    {
        [MyAlert showMessage:@"评论内容不能为空" timer:2.0f];
        return;
    }
    
    [self requestAddComment:_commentTextView.text];
}

- (void)OnRankClicked:(UIButton*)sender
{
    UIButton* randBtn0 = (UIButton*)[self.view viewWithTag:1000];
    UIButton* randBtn1 = (UIButton*)[self.view viewWithTag:1001];
    UIButton* randBtn2 = (UIButton*)[self.view viewWithTag:1002];
    UIButton* randBtn3 = (UIButton*)[self.view viewWithTag:1003];
    UIButton* randBtn4 = (UIButton*)[self.view viewWithTag:1004];
    
    if ( randBtn0==nil || randBtn1==nil || randBtn2==nil || randBtn3==nil || randBtn4==nil )
        return;
    
    [randBtn0 setSelected:NO];
    [randBtn1 setSelected:NO];
    [randBtn2 setSelected:NO];
    [randBtn3 setSelected:NO];
    [randBtn4 setSelected:NO];
    
    NSInteger iTag = sender.tag;
    switch (iTag)
    {
        case 1000:
        {
            _iRandCount =1;
            [randBtn0 setSelected:YES];
        }
            break;
        case 1001:
        {
            _iRandCount = 2;
            [randBtn0 setSelected:YES];
            [randBtn1 setSelected:YES];
        }
            break;
        case 1002:
        {
            _iRandCount= 3;
            [randBtn0 setSelected:YES];
            [randBtn1 setSelected:YES];
            [randBtn2 setSelected:YES];
        }
            break;
        case 1003:
        {
            _iRandCount = 4;
            [randBtn0 setSelected:YES];
            [randBtn1 setSelected:YES];
            [randBtn2 setSelected:YES];
            [randBtn3 setSelected:YES];
        }
            break;
        case 1004:
        {
            _iRandCount = 5;
            [randBtn0 setSelected:YES];
            [randBtn1 setSelected:YES];
            [randBtn2 setSelected:YES];
            [randBtn3 setSelected:YES];
            [randBtn4 setSelected:YES];
        }
            break;
        default:
            break;
    }
    
    
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    textView.text = @"";
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ( [textView.text compare:@""] == NSOrderedSame )
        textView.text = @"长度在10~500个字之间\n写下购买体会或使用过程中带来的帮助等，可以为其他小伙伴提供参考~";
}
- (void)textViewDidChange:(UITextView *)textView
{
    NSString* cmtContent = textView.text;
    if ( 500 < [cmtContent length] )
    {
        [MyAlert showMessage:@"字数超限" timer:2.0f];
        cmtContent = [cmtContent substringToIndex:500];
        [textView setText:cmtContent];
        return;
    }
    if ( 450 < [cmtContent length] )
    {
        [_cmtWdsCountLabel setTextColor:[UIColor redColor]];
    }
    
    [_cmtWdsCountLabel setText:[NSString stringWithFormat:@"%lu",[cmtContent length]]];
    
}

#pragma mark - network
-(void)requestAddComment:(NSString*)content
{
    [_netLoading startAnimating];
    
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [net request_CommentAdd_Datasuc:^(id success) {
        
        [_netLoading stopAnimating];

        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            [MyAlert showMessage:@"评论成功" timer:2.0f];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [MyAlert showMessage:[success[@"status"] valueForKey:@"error_desc"] timer:2.0f];
        }
    } fail:^(NSError *error) {
        
        [_netLoading stopAnimating];
        
    } goodsID:_iGoodsID content:content commentRank:_iRandCount];
    
}

@end
