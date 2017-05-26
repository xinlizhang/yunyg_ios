//
//  MineViewController_ipa.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "LoginViewController_ipa.h"
#import "RDVTabBarController.h"
#import "RegisterViewController_ipa.h"

@interface LoginViewController_ipa ()
{
    UIScrollView*   _scrollView;
    
    UITextField*    _accountField;
    UITextField*    _passwordField;
    
    NSString*       _accountDefault;
    NSString*       _passwordDefault;
    
    UILabel*        _loginBtnLabel;
    UILabel*        _registerBtnLabel;
    
    MyNetLoading*   _netLoading;
}
@end

@implementation LoginViewController_ipa


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
    _accountDefault = @"用户名/邮箱/手机号";
    _passwordDefault = @"请输入密码";
}

-(void)initUI
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
 
    CGRect frameR = self.view.frame;
    
    // content
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width, frameR.size.height)];
    [_scrollView setBackgroundColor:[UIColor colorWithRed:238.0/255 green:243.0/255 blue:246.0/255 alpha:1]];
    [self.view addSubview:_scrollView];
    [_scrollView setDelegate:self];
    [_scrollView release];
    
    // 登陆用户名背景
    CGPoint relationP = CGPointMake(0, 0);
    int height = 130;
    UIImageView* userInfoBG = [[UIImageView alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, frameR.size.width, height)];
    [userInfoBG setImage:[UIImage imageNamed:@"mine_user_info_bg"]];
    [_scrollView addSubview:userInfoBG];
    [userInfoBG release];
    
    // 登陆 / 头像
    UIButton* loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(frameR.size.width/2-35, relationP.y+20, 70, 70)];
    [loginBtn setImage:[UIImage imageNamed:@"mine_login_btn_nor"] forState:UIControlStateNormal];
    [_scrollView addSubview:loginBtn];
    [loginBtn release];
    
    // 用户名
    relationP.y = relationP.y + height + 20;
    height = 40;
    
    UILabel* accountWdsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, height)];
    accountWdsLabel.backgroundColor = [UIColor clearColor];
    accountWdsLabel.textColor = [UIColor grayColor];
    accountWdsLabel.text = @"     账号:";

    _accountField = [[UITextField alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [_accountField setBorderStyle:UITextBorderStyleNone];
    [_accountField setBackgroundColor:[UIColor whiteColor]];
    _accountField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _accountField.keyboardType = UIKeyboardTypeAlphabet;
    _accountField.autocapitalizationType =  UITextAutocapitalizationTypeNone; 
    _accountField.text = _accountDefault;
    _accountField.font = [UIFont systemFontOfSize:15];
    _accountField.textColor = [UIColor lightGrayColor];
    _accountField.delegate = self;
    _accountField.clearsOnBeginEditing = YES;
    _accountField.leftViewMode = UITextFieldViewModeAlways;
    _accountField.leftView = accountWdsLabel;
    [_scrollView addSubview:_accountField];
    [_accountField release];
    
    // 分割线
    relationP.y = relationP.y + height + 0.5;
    height = 0.5;
    
    float startX = accountWdsLabel.frame.size.width;
    UIView* seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(startX, relationP.y, frameR.size.width-startX, height)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [_scrollView addSubview:seperatorlINE];
    [seperatorlINE release];
    
    // 密码
    relationP.y = relationP.y + height;
    height = 40;
    
    UILabel* passwordWdsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, height)];
    passwordWdsLabel.backgroundColor = [UIColor clearColor];
    passwordWdsLabel.textColor = [UIColor grayColor];
    passwordWdsLabel.text = @"     密码:";
    
    _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [_passwordField setBorderStyle:UITextBorderStyleNone];
    [_passwordField setBackgroundColor:[UIColor whiteColor]];
    _passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _passwordField.text = _passwordDefault;
    _passwordField.font = [UIFont systemFontOfSize:15];
    _passwordField.textColor = [UIColor lightGrayColor];
    _passwordField.delegate = self;
    //passwordField.secureTextEntry = YES;
    _passwordField.clearsOnBeginEditing = YES;
    _passwordField.leftViewMode = UITextFieldViewModeAlways;
    _passwordField.leftView = passwordWdsLabel;
    [_scrollView addSubview:_passwordField];
    [_passwordField release];
    
    
    // 登陆按钮
    relationP.y = relationP.y + height + 30;
    height = 30;

    _loginBtnLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, relationP.y, frameR.size.width-40, height)];
    [_loginBtnLabel.layer setBackgroundColor:[UIColor colorWithRed:241.0/255 green:83.0/255 blue:80.0/255 alpha:1.0].CGColor];
    [_loginBtnLabel.layer setCornerRadius:3];
    _loginBtnLabel.text = @"登 录";
    _loginBtnLabel.textColor = [UIColor whiteColor];
    _loginBtnLabel.userInteractionEnabled = YES;
    [_loginBtnLabel setTextAlignment:NSTextAlignmentCenter];
    [_scrollView addSubview:_loginBtnLabel];
    [_loginBtnLabel release];
    
    UITapGestureRecognizer *loginReco = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onLoginClicked:)];
    [_loginBtnLabel addGestureRecognizer:loginReco];
    [loginReco release];
    
    // 注册按钮
    relationP.y = relationP.y + height + 10;
    height = 30;
    
    _registerBtnLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, relationP.y, frameR.size.width-40, height)];
    [_registerBtnLabel.layer setBackgroundColor:[UIColor colorWithRed:154.0/255 green:205.0/255 blue:50.0/255 alpha:1.0].CGColor];
    [_registerBtnLabel.layer setCornerRadius:3];
    _registerBtnLabel.text = @"注 册";
    _registerBtnLabel.textColor = [UIColor whiteColor];
    _registerBtnLabel.userInteractionEnabled = YES;
    [_registerBtnLabel setTextAlignment:NSTextAlignmentCenter];
    [_scrollView addSubview:_registerBtnLabel];
    [_registerBtnLabel release];
    
    UITapGestureRecognizer *registerReco = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onRegisterClicked:)];
    [_registerBtnLabel addGestureRecognizer:registerReco];
    [registerReco release];
    
    int iTotalH = relationP.y + height + 15;
    iTotalH += 60;
    [_scrollView setContentSize:CGSizeMake(frameR.size.width, iTotalH)];
    
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
    self.view.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"登录";
    
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - clicked event
-(void)onLoginClicked:(UITapGestureRecognizer*)sender
{
    NSString* account = _accountField.text;
    NSString* password = _passwordField.text;

    if ( NSOrderedSame == [account compare:_accountDefault]
            || NSOrderedSame == [account compare:@""] )
    {
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"用户名不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alter show];
        [alter release];
        return;
    }
    if ( NSOrderedSame == [password compare:_passwordDefault]
        || NSOrderedSame == [password compare:@""] )
    {
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"密码不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alter show];
        [alter release];
        return;
    }
    
    // 用户名密码验证通过
    [self requestData:account password:password];
}

-(void)onRegisterClicked:(UITapGestureRecognizer*)sender
{
    BasicViewController_ipa *viewControllerList = [[RegisterViewController_ipa alloc] init];
    [self.navigationController pushViewController:viewControllerList animated:YES];
}

#pragma mark - UITextFiled

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ( textField == _passwordField )
        textField.secureTextEntry = true;
    [self animateTextField: textField up: YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
    [textField resignFirstResponder];
    return  YES;
}
// 键盘弹出时移动frame
- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 80; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    int offsetY = self.view.frame.origin.y;
    if ( up && offsetY < 0 && offsetY == movement )
        return;
    
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    
    [UIView commitAnimations];
    
}

#pragma mark - network

-(void)loginResult:(NSDictionary*)resultDic
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)requestData:(NSString*)account password:(NSString*)password
{
    [_netLoading startAnimating];
    
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [net request_Login_Datasuc:^(id success) {
        
        [_netLoading stopAnimating];
        
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            // 数据持久化
            [DataCenter sharedDataCenter].isLogin = true;
            
            [[DataCenter sharedDataCenter] writeSessionInfo:[success[@"data"] objectForKey:@"session"]];
            [[DataCenter sharedDataCenter] writeLoginInfo:[success[@"data"] objectForKey:@"user"]];
            [[DataCenter sharedDataCenter] synchronizeLoginData];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowCartCount" object:nil];
            [self loginResult:success[@"data"]];
        }
        else
        {
            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:[success[@"status"] valueForKey:@"error_desc"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alter show];
            [alter release];
        }
    } fail:^(NSError *error) {
        
        [_netLoading stopAnimating];
        
    } account:account password:password ];
}



@end
