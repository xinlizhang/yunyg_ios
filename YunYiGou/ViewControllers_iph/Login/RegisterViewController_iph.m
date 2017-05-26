//
//  MineViewController_iph.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "RegisterViewController_iph.h"
#import "RDVTabBarController.h"

@interface RegisterViewController_iph ()
{
    NSMutableArray* _fieldsArray;
    
    UIScrollView*   _scrollView;
    
    UITextField*    _accountField;
    UITextField*    _passwordField;
    UITextField*    _pswdConfirmFiled;
    UITextField*    _emailFiled;
    
    UITextField*    _currentTextFiled;
    
    NSString*       _accountDefault;
    NSString*       _passwordDefault;
    NSString*       _pswdConfirmDefault;
    NSString*       _emailDefault;
    
    UILabel*        _loginBtnLabel;
    
    MyNetLoading*   _netLoading;
    
    UILabel*        _keyboardCompleteLabel;
}
@end

@implementation RegisterViewController_iph


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initData];
        [self initUI];
        
        [self requestRegisterFields];
    }
    return self;
}

-(void)initData
{
    _fieldsArray = [[NSMutableArray alloc] init];
    
    _accountDefault = @"用户名";
    _passwordDefault = @"请输入密码";
    _pswdConfirmDefault = @"请再次输入密码";
    _emailDefault = @"邮箱";
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
    
    
    // 用户名
    CGPoint relationP = CGPointMake(0, 20);
    int height = 40;
    
    UILabel* accountWdsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, height)];
    accountWdsLabel.backgroundColor = [UIColor clearColor];
    accountWdsLabel.textColor = [UIColor grayColor];
    accountWdsLabel.text = @"   账       号";

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
    
    // 邮箱
    relationP.y = relationP.y + height;
    height = 40;
    
    UILabel* emailWdsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, height)];
    emailWdsLabel.backgroundColor = [UIColor clearColor];
    emailWdsLabel.textColor = [UIColor grayColor];
    emailWdsLabel.text = @"   邮       箱";
    
    _emailFiled = [[UITextField alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [_emailFiled setBorderStyle:UITextBorderStyleNone];
    [_emailFiled setBackgroundColor:[UIColor whiteColor]];
    _emailFiled.keyboardType = UIKeyboardTypeAlphabet;
    _emailFiled.autocapitalizationType =  UITextAutocapitalizationTypeNone;
    _emailFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
    _emailFiled.text = _emailDefault;
    _emailFiled.font = [UIFont systemFontOfSize:15];
    _emailFiled.textColor = [UIColor lightGrayColor];
    _emailFiled.delegate = self;
    //passwordField.secureTextEntry = YES;
    _emailFiled.clearsOnBeginEditing = YES;
    _emailFiled.leftViewMode = UITextFieldViewModeAlways;
    _emailFiled.leftView = emailWdsLabel;
    //[_scrollView addSubview:_emailFiled];
    [_emailFiled release];
    
    // 分割线
    relationP.y = relationP.y + height + 0.5;
    height = 0.5;
    
    startX = accountWdsLabel.frame.size.width;
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(startX, relationP.y, frameR.size.width-startX, height)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [_scrollView addSubview:seperatorlINE];
    [seperatorlINE release];
    
    // 密码
    relationP.y = relationP.y + height;
    height = 40;
    
    UILabel* passwordWdsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, height)];
    passwordWdsLabel.backgroundColor = [UIColor clearColor];
    passwordWdsLabel.textColor = [UIColor grayColor];
    passwordWdsLabel.text = @"   密       码";
    
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
    
    // 分割线
    relationP.y = relationP.y + height + 0.5;
    height = 0.5;
    
    startX = accountWdsLabel.frame.size.width;
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(startX, relationP.y, frameR.size.width-startX, height)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [_scrollView addSubview:seperatorlINE];
    [seperatorlINE release];
    
    // 确认密码
    relationP.y = relationP.y + height;
    height = 40;
    
    UILabel* pswdConfirmWdsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, height)];
    pswdConfirmWdsLabel.backgroundColor = [UIColor clearColor];
    pswdConfirmWdsLabel.textColor = [UIColor grayColor];
    pswdConfirmWdsLabel.text = @"   确认密码";
    
    _pswdConfirmFiled = [[UITextField alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [_pswdConfirmFiled setBorderStyle:UITextBorderStyleNone];
    [_pswdConfirmFiled setBackgroundColor:[UIColor whiteColor]];
    _pswdConfirmFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
    _pswdConfirmFiled.text = _pswdConfirmDefault;
    _pswdConfirmFiled.font = [UIFont systemFontOfSize:15];
    _pswdConfirmFiled.textColor = [UIColor lightGrayColor];
    _pswdConfirmFiled.delegate = self;
    //passwordField.secureTextEntry = YES;
    _pswdConfirmFiled.clearsOnBeginEditing = YES;
    _pswdConfirmFiled.leftViewMode = UITextFieldViewModeAlways;
    _pswdConfirmFiled.leftView = pswdConfirmWdsLabel;
    [_scrollView addSubview:_pswdConfirmFiled];
    [_pswdConfirmFiled release];
    
    // 分割线
    relationP.y = relationP.y + height + 0.5;
    height = 0.5;
    
    startX = accountWdsLabel.frame.size.width;
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(startX, relationP.y, frameR.size.width-startX, height)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [_scrollView addSubview:seperatorlINE];
    [seperatorlINE release];
    
    
    

    // 注册按钮
    relationP.y = relationP.y + height + 20;
    height = 30;

    _loginBtnLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, relationP.y, frameR.size.width-40, height)];
    [_loginBtnLabel.layer setBackgroundColor:[UIColor colorWithRed:241.0/255 green:83.0/255 blue:80.0/255 alpha:1.0].CGColor];
    [_loginBtnLabel.layer setCornerRadius:3];
    _loginBtnLabel.text = @"确认提交";
    _loginBtnLabel.textColor = [UIColor whiteColor];
    _loginBtnLabel.userInteractionEnabled = YES;
    [_loginBtnLabel setTextAlignment:NSTextAlignmentCenter];
    [_scrollView addSubview:_loginBtnLabel];
    [_loginBtnLabel release];
    
    UITapGestureRecognizer *loginReco = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onRegisterClicked:)];
    [_loginBtnLabel addGestureRecognizer:loginReco];
    [loginReco release];
    
    int iTotalH = relationP.y + height + 15;
    iTotalH += 60;
    [_scrollView setContentSize:CGSizeMake(frameR.size.width, iTotalH)];
    
    // loading
    _netLoading = [[MyNetLoading alloc] init];
    [_netLoading setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    [self.view addSubview:_netLoading];
    [_netLoading release];
    
    // 键盘收起按钮
    _keyboardCompleteLabel = [[UILabel alloc] init];
    _keyboardCompleteLabel.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:0.8];
    _keyboardCompleteLabel.text = @"完成";
    _keyboardCompleteLabel.font = [UIFont systemFontOfSize:12];
    _keyboardCompleteLabel.textColor = [UIColor redColor];
    _keyboardCompleteLabel.userInteractionEnabled = YES;
    [_keyboardCompleteLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_keyboardCompleteLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCancelKboradClicked:)];
    [_keyboardCompleteLabel addGestureRecognizer:tap];
    [tap release];

        
}

- (void)updateFieldsUI
{
    if ( [_fieldsArray count] <= 0 )
        return;

    CGPoint relationP = CGPointMake(0, 0);
    int height = 0;
    
    relationP.y = _loginBtnLabel.frame.origin.y;
    
    for ( int i = 0; i < [_fieldsArray count]; i++ )
    {
        NSDictionary* dic = [_fieldsArray objectAtIndex:i];

        height = 40;

        UILabel* fieldWdsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, height)];
        fieldWdsLabel.backgroundColor = [UIColor clearColor];
        fieldWdsLabel.textAlignment = NSTextAlignmentCenter;
        fieldWdsLabel.textColor = [UIColor grayColor];
        fieldWdsLabel.text = [dic valueForKey:@"name"];
        
        UITextField* field = [[UITextField alloc] initWithFrame:CGRectMake(0, relationP.y, self.view.frame.size.width, height)];
        [field setBorderStyle:UITextBorderStyleNone];
        [field setBackgroundColor:[UIColor whiteColor]];
        field.clearButtonMode = UITextFieldViewModeWhileEditing;
        field.keyboardType = UIKeyboardTypeAlphabet;
        field.autocapitalizationType =  UITextAutocapitalizationTypeNone;
        field.font = [UIFont systemFontOfSize:15];
        field.textColor = [UIColor lightGrayColor];
        field.tag = i+1000;
        field.delegate = self;
        field.clearsOnBeginEditing = YES;
        field.leftViewMode = UITextFieldViewModeAlways;
        field.leftView = fieldWdsLabel;
        [_scrollView addSubview:field];
        [field release];
        
        // 分割线
        relationP.y = relationP.y + height + 0.5;
        height = 0.5;
        
        float startX = fieldWdsLabel.frame.size.width;
        UIView* seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(startX, relationP.y, self.view.frame.size.width-startX, height)];
        [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
        [_scrollView addSubview:seperatorlINE];
        [seperatorlINE release];
        
        relationP.y = relationP.y + height;
    }
    
    relationP.y = relationP.y + height + 20;
    CGRect frame = _loginBtnLabel.frame;
    frame.origin.y = relationP.y;
    [_loginBtnLabel setFrame:frame];
    
    int iTotalH = relationP.y + frame.size.height + 15;
    iTotalH += 60;
    [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, iTotalH)];
}

- (void)dealloc
{
    [super dealloc];
    
    [_fieldsArray release];
    [_keyboardCompleteLabel release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)handleKeyboardDidShow:(NSNotification *)notification
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    NSDictionary *info = [notification userInfo];
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
    CGFloat distanceToMove = kbSize.height;
    NSLog(@"---->动态键盘高度:%f",distanceToMove);
    
    CGRect exitBtFrame = CGRectMake(self.view.frame.size.width-40, self.view.frame.size.height-distanceToMove-30.0f, 50.0f, 30.0f);
    _keyboardCompleteLabel.frame = exitBtFrame;
    _keyboardCompleteLabel.hidden = NO;
    
    // 移动scrollview 处理键盘覆盖
    float yKboard = self.view.frame.size.height - distanceToMove;
    float yTxtfield = _currentTextFiled.frame.origin.y + _scrollView.frame.origin.y;
    float hTxtfield = _currentTextFiled.frame.size.height;

    if ( yKboard < (yTxtfield + hTxtfield + 64) )
    {
        float moveDistance = (yTxtfield+hTxtfield) - yKboard + 10;
        
        [UIView beginAnimations: nil context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: 0.3f];
        [_scrollView setContentOffset:CGPointMake(0, moveDistance)];
        [UIView commitAnimations];
    }
}
- (void)handleKeyboardWillHide:(NSNotification *)notification
{
    _keyboardCompleteLabel.hidden = YES;
    [_scrollView setContentOffset:CGPointMake(0, -64)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"用户注册";
    
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
-(void)onRegisterClicked:(UITapGestureRecognizer*)sender
{
    // 基本项校验
    NSString* account = _accountField.text;
    NSString* password = _passwordField.text;
    NSString* pswdConfirm = _pswdConfirmFiled.text;
    NSString* email = @"";//_emailFiled.text;

    if ( NSOrderedSame == [account compare:_accountDefault] || NSOrderedSame == [account compare:@""] )
    {
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"用户名不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alter show];
        [alter release];
        return;
    }
    if ( NSOrderedSame == [password compare:_passwordDefault] || NSOrderedSame == [password compare:@""] )
    {
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"密码不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alter show];
        [alter release];
        return;
    }
    if ( NSOrderedSame == [pswdConfirm compare:_pswdConfirmDefault] || NSOrderedSame == [pswdConfirm compare:@""] )
    {
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确认密码不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alter show];
        [alter release];
        return;
    }
    if ( NSOrderedSame != [pswdConfirm compare:password] )
    {
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"两次输入密码不一致" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alter show];
        [alter release];
        return;
    }
    
    /*if ( NSOrderedSame == [email compare:_emailDefault] || NSOrderedSame == [email compare:@""] )
    {
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"电子邮箱不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alter show];
        [alter release];
        return;
    }*/
    
    
    // 扩展项校验
    NSMutableArray* fieldsArray = [[NSMutableArray alloc] init];
    for ( int i = 0; i < [_fieldsArray count]; i++ )
    {
        NSMutableDictionary* dicSend = [[NSMutableDictionary alloc] init];
        NSDictionary* dicRecive = [_fieldsArray objectAtIndex:i];

        UITextField* textField = (UITextField*)[_scrollView viewWithTag:(i+1000)];
        if ( textField == nil )
            continue;
        
        if ( 1 == [[dicRecive valueForKey:@"need"] intValue] )
        {
            if ( NSOrderedSame != [textField.text compare:@""] )
            {
                [dicSend setValue:[dicRecive valueForKey:@"id"] forKey:@"id"];
                [dicSend setValue:textField.text forKey:@"value"];
            }
            else
            {
                NSString* stringDetail = [NSString stringWithFormat:@"必填项%@不能为空",[dicRecive valueForKey:@"name"]] ;
                UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:stringDetail delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alter show];
                [alter release];
                return;
            }
        }
        else
        {
            if ( NSOrderedSame != [textField.text compare:@""] )
            {
                [dicSend setValue:[dicRecive valueForKey:@"id"] forKey:@"id"];
                [dicSend setValue:textField.text forKey:@"value"];
            }
            else
            {
                continue;
            }
        }
        [fieldsArray addObject:dicSend];
    }
    
    // 校验通过
    [self requestRegister:account password:password email:email fields:fieldsArray];
}

-(void)onCancelKboradClicked:(id)sender
{
    if ( _currentTextFiled )
    {
        [_currentTextFiled resignFirstResponder];
        _currentTextFiled = nil;
    }
    
}

#pragma mark - UITextFiled

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _currentTextFiled = textField;
    
    if ( textField == _passwordField )
    {
        textField.secureTextEntry = true;
    }
    if ( textField == _pswdConfirmFiled )
    {
        textField.secureTextEntry = true;
    }
}

#pragma mark - network

- (void)requestRegisterFields
{
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    [_netLoading startAnimating];
    [net request_RegisterFields_Datasuc:^(id success) {
        [_netLoading stopAnimating];
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            [_fieldsArray addObjectsFromArray:success[@"data"]];
            [self updateFieldsUI];
        }
        
    } fail:^(NSError *error) {
        [_netLoading stopAnimating];
    }];
}


- (void)registerSuccess
{
    [self viewWillDisappear:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)requestRegister:(NSString*)account password:(NSString*)password email:(NSString*)email fields:(NSArray*)fields
{
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    [_netLoading startAnimating];
    [net request_Register_Datasuc:^(id success) {
        [_netLoading stopAnimating];
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            // 数据持久化
            [DataCenter sharedDataCenter].isLogin = true;
            [[DataCenter sharedDataCenter] writeSessionInfo:[success[@"data"] objectForKey:@"session"]];
            [[DataCenter sharedDataCenter] writeLoginInfo:[success[@"data"] objectForKey:@"user"]];
            [[DataCenter sharedDataCenter] synchronizeLoginData];
            
            [self registerSuccess];
        }
        else
        {
            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:[success[@"status"] valueForKey:@"error_desc"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alter show];
            [alter release];
        }
    } fail:^(NSError *error) {
        [_netLoading stopAnimating];
    } account:account email:email password:password fieldArray:fields];
}



@end
