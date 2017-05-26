//
//  MineViewController_iph.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "AddrEditViewController_iph.h"
#import "RDVTabBarController.h"
#import "MyAlert.h"

@interface AddrEditViewController_iph ()
{
    int                 _textFieldH;
    
    NSDictionary*       _addrDic;
    
    UITextField*        _nameField;
    UITextField*        _mobileField;
    UITextField*        _telField;
    UITextField*        _emailField;
    UITextField*        _districtField;
    UITextField*        _detailField;

    UIButton*           _pickerMaskBtn;
    UIPickerView*       _cityPicker;
    
    NSMutableArray*     _provinceArray;
    NSMutableArray*     _cityArray;
    NSMutableArray*     _districtArray;
    
    MyNetLoading*       _netLoading;
}
@end

@implementation AddrEditViewController_iph

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
    _textFieldH = 40;
    
    _addrDic = [[NSDictionary alloc] init];
    
    _provinceArray = [[NSMutableArray alloc] init];
    _cityArray = [[NSMutableArray alloc] init];
    _districtArray = [[NSMutableArray alloc] init];
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
    
    // 收货人
    CGPoint relationP = CGPointMake(0, 0);
    int height = 40;
    
    NSString* nameWds = @"  收货人:";
    float nameWdsW = [Utils widthForString:nameWds fontSize:14] + 10;
    UILabel* nameWdsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, nameWdsW, height)];
    nameWdsLabel.backgroundColor = [UIColor clearColor];
    nameWdsLabel.textColor = [UIColor grayColor];
    nameWdsLabel.font = [UIFont systemFontOfSize:14];
    nameWdsLabel.text = nameWds;
    
    _nameField = [[UITextField alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [_nameField setBorderStyle:UITextBorderStyleNone];
    [_nameField setBackgroundColor:[UIColor whiteColor]];
    _nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _nameField.textColor = [UIColor blackColor];
    _nameField.delegate = self;
    _nameField.font = [UIFont systemFontOfSize:14];
    _nameField.clearsOnBeginEditing = NO;
    _nameField.leftViewMode = UITextFieldViewModeAlways;
    _nameField.leftView = nameWdsLabel;
    [self.view addSubview:_nameField];
    [_nameField release];
    
    relationP.y = relationP.y + height;
    height = 0.5;
    UIView* seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:seperatorlINE];
    [seperatorlINE release];
    
    // 联系方式
    relationP.y = relationP.y + height;
    height = 40;
    
    NSString* mobileWds = @"  手机号码:";
    float mobileWdsW = [Utils widthForString:mobileWds fontSize:14] + 10;
    UILabel* mobileWdsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, mobileWdsW, height)];
    mobileWdsLabel.backgroundColor = [UIColor clearColor];
    mobileWdsLabel.textColor = [UIColor grayColor];
    mobileWdsLabel.font = [UIFont systemFontOfSize:14];
    mobileWdsLabel.text = mobileWds;
    
    _mobileField = [[UITextField alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [_mobileField setBorderStyle:UITextBorderStyleNone];
    [_mobileField setBackgroundColor:[UIColor whiteColor]];
    _mobileField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _mobileField.keyboardType = UIKeyboardTypeNumberPad;
    _mobileField.textColor = [UIColor blackColor];
    _mobileField.delegate = self;
    _mobileField.font = [UIFont systemFontOfSize:14];
    _mobileField.clearsOnBeginEditing = NO;
    _mobileField.leftViewMode = UITextFieldViewModeAlways;
    _mobileField.leftView = mobileWdsLabel;
    [self.view addSubview:_mobileField];
    [_mobileField release];
    
    // 联系方式
    relationP.y = relationP.y + height;
    height = 40;
    
    NSString* telWds = @"  座机号码:";
    float telWdsW = [Utils widthForString:telWds fontSize:14] + 10;
    UILabel* telWdsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, telWdsW, height)];
    telWdsLabel.backgroundColor = [UIColor clearColor];
    telWdsLabel.textColor = [UIColor grayColor];
    telWdsLabel.font = [UIFont systemFontOfSize:14];
    telWdsLabel.text = telWds;
    
    _telField = [[UITextField alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [_telField setBorderStyle:UITextBorderStyleNone];
    [_telField setBackgroundColor:[UIColor whiteColor]];
    _telField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _telField.keyboardType = UIKeyboardTypeNumberPad;
    _telField.textColor = [UIColor blackColor];
    _telField.delegate = self;
    _telField.font = [UIFont systemFontOfSize:14];
    _telField.clearsOnBeginEditing = NO;
    _telField.leftViewMode = UITextFieldViewModeAlways;
    _telField.leftView = telWdsLabel;
    [self.view addSubview:_telField];
    [_telField release];
    
    relationP.y = relationP.y + height - 0.5;
    height = 0.5;
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:seperatorlINE];
    [seperatorlINE release];
    
    // EMAIL
    relationP.y = relationP.y + height;
    height = 40;
    
    NSString* emailWds = @"  电子邮箱:";
    float emailWdsW = [Utils widthForString:emailWds fontSize:14] + 10;
    UILabel* emailWdsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, emailWdsW, height)];
    emailWdsLabel.backgroundColor = [UIColor clearColor];
    emailWdsLabel.textColor = [UIColor grayColor];
    emailWdsLabel.font = [UIFont systemFontOfSize:14];
    emailWdsLabel.text = emailWds;
    
    _emailField = [[UITextField alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [_emailField setBorderStyle:UITextBorderStyleNone];
    [_emailField setBackgroundColor:[UIColor whiteColor]];
    _emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _emailField.textColor = [UIColor blackColor];
    _emailField.delegate = self;
    _emailField.font = [UIFont systemFontOfSize:14];
    _emailField.clearsOnBeginEditing = NO;
    _emailField.leftViewMode = UITextFieldViewModeAlways;
    _emailField.leftView = emailWdsLabel;
    [self.view addSubview:_emailField];
    [_emailField release];
    
    relationP.y = relationP.y + height - 0.5;
    height = 0.5;
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:seperatorlINE];
    [seperatorlINE release];
    
    
    // 所在地区
    relationP.y = relationP.y + height;
    height = 40;
    
    NSString* districtWds = @"  所在地区:";
    float districtWdsW = [Utils widthForString:districtWds fontSize:14] + 10;
    UILabel* districtWdsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, districtWdsW, height)];
    districtWdsLabel.backgroundColor = [UIColor clearColor];
    districtWdsLabel.textColor = [UIColor grayColor];
    districtWdsLabel.font = [UIFont systemFontOfSize:14];
    districtWdsLabel.text = districtWds;
    
    _districtField = [[UITextField alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [_districtField setBorderStyle:UITextBorderStyleNone];
    [_districtField setBackgroundColor:[UIColor whiteColor]];
    _districtField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _districtField.textColor = [UIColor blackColor];
    _districtField.delegate = self;
    _districtField.font = [UIFont systemFontOfSize:14];
    _districtField.clearsOnBeginEditing = NO;
    _districtField.leftViewMode = UITextFieldViewModeAlways;
    _districtField.leftView = districtWdsLabel;
    [self.view addSubview:_districtField];
    [_districtField release];
    
    relationP.y = relationP.y + height - 0.5;
    height = 0.5;
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:seperatorlINE];
    [seperatorlINE release];
    
    
    // 详细地址
    relationP.y = relationP.y + height;
    height = 40;
    
    NSString* detailWds = @"  详细地址:";
    float detailWdsW = [Utils widthForString:detailWds fontSize:14] + 10;
    UILabel* detailWdsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, detailWdsW, height)];
    detailWdsLabel.backgroundColor = [UIColor clearColor];
    detailWdsLabel.textColor = [UIColor grayColor];
    detailWdsLabel.font = [UIFont systemFontOfSize:14];
    detailWdsLabel.text = detailWds;
    
    _detailField = [[UITextField alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [_detailField setBorderStyle:UITextBorderStyleNone];
    [_detailField setBackgroundColor:[UIColor whiteColor]];
    _detailField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _detailField.textColor = [UIColor blackColor];
    _detailField.delegate = self;
    _detailField.font = [UIFont systemFontOfSize:14];
    _detailField.clearsOnBeginEditing = NO;
    _detailField.leftViewMode = UITextFieldViewModeAlways;
    _detailField.leftView = detailWdsLabel;
    [self.view addSubview:_detailField];
    [_detailField release];
    
    relationP.y = relationP.y + height - 0.5;
    height = 0.5;
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:seperatorlINE];
    [seperatorlINE release];
    
    
    // 提交按钮
    UILabel* saveAddrLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width-60, 40)];
    [saveAddrLabel setCenter:CGPointMake(frameR.size.width/2, frameR.size.height-64-60/2)];
    saveAddrLabel.backgroundColor = [UIColor colorWithRed:241.0/255 green:83.0/255 blue:80.0/255 alpha:1.0];
    saveAddrLabel.text = @"保存";
    saveAddrLabel.textColor = [UIColor whiteColor];
    saveAddrLabel.userInteractionEnabled = YES;
    [saveAddrLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:saveAddrLabel];
    [saveAddrLabel release];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onConfirmClicked:)];
    [saveAddrLabel addGestureRecognizer:tap];
    [tap release];
    
    
    // 筛选时的背景遮罩
    _pickerMaskBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width, frameR.size.height)];
    [_pickerMaskBtn setBackgroundColor:[UIColor blackColor]];
    [_pickerMaskBtn setAlpha:0.3f];
    [_pickerMaskBtn setHidden:YES];
    [_pickerMaskBtn addTarget:self action:@selector(onPickerMaskBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_pickerMaskBtn];
    [_pickerMaskBtn release];
    
    // 城市筛选器
    _cityPicker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, frameR.size.height-64-180, frameR.size.width, 180)];
    _cityPicker.tag = 0;
    [_cityPicker setHidden:YES];
    _cityPicker.delegate = self;
    _cityPicker.dataSource = self;
    _cityPicker.showsSelectionIndicator = YES;
    [self.view addSubview:_cityPicker];
    _cityPicker.backgroundColor = [UIColor whiteColor];

    // loading
    _netLoading = [[MyNetLoading alloc] init];
    [_netLoading setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    [self.view addSubview:_netLoading];
    [_netLoading release];
}

-(void)updateUI:(NSDictionary*)addrDic
{
    [_nameField setText:[addrDic objectForKey:@"consignee"]];
    [_mobileField setText:[addrDic objectForKey:@"mobile"]];
    [_telField setText:[addrDic objectForKey:@"tel"]];
    [_emailField setText:[addrDic objectForKey:@"email"]];
    NSString* addrWds = [NSString stringWithFormat:@"%@ %@ %@ %@",[addrDic objectForKey:@"country_name"],[addrDic objectForKey:@"province_name"],[addrDic objectForKey:@"city_name"],[addrDic objectForKey:@"district_name"]];
    [_districtField setText:addrWds];
    [_detailField setText:[addrDic objectForKey:@"address"]];
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
    
    BasicViewController_iph *basicViewController = (BasicViewController_iph*)[navigationController topViewController];
    _addrDic = basicViewController.editAddrDic;
    if ( _addrDic == nil )
        self.title = @"新增收货地址";
    else
    {
        self.title = @"编辑收货地址";
        [self updateUI:_addrDic];
    }
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

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // 返回一个BOOL值，指定是否循序文本字段开始编辑
    if ( textField == _districtField )
    {
        [_nameField resignFirstResponder];
        [_mobileField resignFirstResponder];
        [_telField resignFirstResponder];
        [_emailField resignFirstResponder];
        [_districtField resignFirstResponder];
        [_detailField resignFirstResponder];
        
        // 点击地址的情况调用 UIPickerView
        [_cityPicker setHidden:NO];
        [_pickerMaskBtn setHidden:NO];
        
        [self requestComponent0RegionInfo:1];
        [self requestComponent1RegionInfo:2];
        [self requestComponent2RegionInfo:52];
        
        return NO;
    }
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // 开始编辑时触发，文本字段将成为first responder
    //[self animateTextField: textField up: YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //[self animateTextField: textField up: NO];
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


#pragma mark - UIPackerView delegate
//返回显示的列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

//返回当前列显示的行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSLog(@"numberOfRowsInComponent");
    if (component == 0) {
        return [_provinceArray count];
    }
    else if (component == 1) {
        return [_cityArray count];
    }
    else {
        return [_districtArray count];
    }
}
//设置当前行的内容
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSLog(@"titleForRow");
    if(component == 0 && row < [_provinceArray count]) {
        return [[_provinceArray objectAtIndex:row] valueForKey:@"name"];
    }
    else if (component == 1 && row < [_cityArray count]) {
        return [[_cityArray objectAtIndex:row] valueForKey:@"name"];
    }
    else if (component == 3 && row < [_districtArray count]) {
        return [[_districtArray objectAtIndex:row] valueForKey:@"name"];
    }
    return nil;
    
}
//选择的行数
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"didSelectRow");
    if (component == 0 && row < [_provinceArray count])
    {
        NSDictionary* provinceDic = [_provinceArray objectAtIndex:row];
        int provinceID = [[provinceDic objectForKey:@"id"] intValue];
        [self requestComponent1RegionInfo:provinceID];
    }
    else if (component == 1 && row < [_cityArray count])
    {
        NSDictionary* cityDic = [_cityArray objectAtIndex:row];
        int cityID = [[cityDic objectForKey:@"id"] intValue];
        [self requestComponent2RegionInfo:cityID];
    }
    else if (component == 2 && row < [_districtArray count])
    {
        [self UpdateDistrictTextField];
    }
}
//每行显示的文字样式
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    NSLog(@"viewForRow");
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 107, 30)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.backgroundColor = [UIColor clearColor];
    if (component == 0) {
        titleLabel.text = [[_provinceArray objectAtIndex:row] valueForKey:@"name"];
    }
    else if (component == 1) {
        titleLabel.text = [[_cityArray objectAtIndex:row] valueForKey:@"name"];
    }
    else {
        titleLabel.text = [[_districtArray objectAtIndex:row] valueForKey:@"name"];
    }
    return titleLabel;
    
}
// 显示选择结果
- (void)UpdateDistrictTextField
{
    NSLog(@"UpdateDistrictTextField");
    NSInteger cityRow0 = [_cityPicker selectedRowInComponent:0];
    NSInteger cityRow1 = [_cityPicker selectedRowInComponent:1];
    NSInteger cityRow2 = [_cityPicker selectedRowInComponent:2];
    
    NSString* provinceWds = @"";
    NSString* cityWds = @"";
    NSString* district = @"";
    
    if ( 0 <= cityRow0 && cityRow0 < [_provinceArray count] )
         provinceWds = [[_provinceArray objectAtIndex:cityRow0] valueForKey:@"name"];
    
    if ( 0 <= cityRow1 && cityRow1 < [_cityArray count] )
        cityWds = [[_cityArray objectAtIndex:cityRow1] valueForKey:@"name"];
    
    if ( 0 <= cityRow2 && cityRow2 < [_districtArray count] )
        district = [[_districtArray objectAtIndex:cityRow2] valueForKey:@"name"];
    
    
    NSString* addrWds = [NSString stringWithFormat:@"中国 %@ %@ %@",provinceWds,cityWds,district];
    [_districtField setText:addrWds];
}

#pragma mark - clicked event
-(void)onConfirmClicked:(UITapGestureRecognizer*)sender
{
    NSString* str = _nameField.text;
    if ( [str compare:@""] == NSOrderedSame )
    {
        [MyAlert showMessage:@"收货人信息不能为空" timer:2.0f];
        return;
    }
    
    str = _mobileField.text;
    if ( [str compare:@""] == NSOrderedSame )
    {
        [MyAlert showMessage:@"手机号码信息不能为空" timer:2.0f];
        return;
    }
    
    str = _emailField.text;
    if ( [str compare:@""] == NSOrderedSame )
    {
        [MyAlert showMessage:@"电子邮箱信息不能为空" timer:2.0f];
        return;
    }
    
    str = _districtField.text;
    if ( [str compare:@""] == NSOrderedSame )
    {
        [MyAlert showMessage:@"所在区域信息不能为空" timer:2.0f];
        return;
    }
    
    str = _detailField.text;
    if ( [str compare:@""] == NSOrderedSame )
    {
        [MyAlert showMessage:@"详细地址信息不能为空" timer:2.0f];
        return;
    }
    
    NSMutableDictionary* addAddrDic = [[NSMutableDictionary alloc] init];
    if ( _addrDic == nil )
    {
    }
    else
    {
        [addAddrDic setValuesForKeysWithDictionary:_addrDic];
    }
    
    [addAddrDic setValue:_nameField.text forKey:@"consignee"];
    [addAddrDic setValue:_mobileField.text forKey:@"mobile"];
    [addAddrDic setValue:_telField.text forKey:@"tel"];
    [addAddrDic setValue:_emailField.text forKey:@"email"];
    [addAddrDic setValue:_detailField.text forKey:@"address"];
    [addAddrDic setValue:@"1" forKey:@"country"];
    
    // 地址
    NSInteger cityRow0 = [_cityPicker selectedRowInComponent:0];
    NSInteger cityRow1 = [_cityPicker selectedRowInComponent:1];
    NSInteger cityRow2 = [_cityPicker selectedRowInComponent:2];
    if ( 0 <= cityRow0 && cityRow0 < [_provinceArray count] )
    {
        [addAddrDic setValue:[[_provinceArray objectAtIndex:cityRow0] valueForKey:@"id"] forKey:@"province"];
    }
    if ( 0 <= cityRow1 && cityRow1 < [_cityArray count] )
    {
        [addAddrDic setValue:[[_cityArray objectAtIndex:cityRow1] valueForKey:@"id"] forKey:@"city"];
    }
    if ( 0 <= cityRow2 && cityRow2 < [_districtArray count] )
    {
        [addAddrDic setValue:[[_districtArray objectAtIndex:cityRow2] valueForKey:@"id"] forKey:@"district"];
    }
    
    if ( _addrDic == nil )
    {
        [self requestAddAddress:addAddrDic];
    }
    else
    {
        [self requestUpdateAddress:[[_addrDic objectForKey:@"id"] intValue] addrDic:addAddrDic];
    }
    
    [addAddrDic release];
}

-(void)onPickerMaskBtnClicked:(UIButton*)sender
{
    [_cityPicker setHidden:YES];
    [_pickerMaskBtn setHidden:YES];
}

#pragma mark - network

-(void)userInfoEditResult:(NSDictionary*)resultDic
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)requestAddAddress:(NSDictionary*)addrDic
{
    [_netLoading startAnimating];
    
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [net request_AddrAdd_Datasuc:^(id success) {
        
        [_netLoading stopAnimating];
        
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            [MyAlert showMessage:@"操作成功" timer:2.0f];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if( success[@"status"] && [[success[@"status"] valueForKey:@"error_code"] intValue] == 100 )
        {
            [MyAlert showMessage:@"您的账号已过期，请尝试重新登陆！" timer:4.0f];
            [[DataCenter sharedDataCenter] removeLoginData];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:[success[@"status"] valueForKey:@"error_desc"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alter show];
            [alter release];
        }
    } fail:^(NSError *error) {
        
        [_netLoading stopAnimating];
        [MyAlert showMessage:@"操作失败" timer:2.0f];
        
    } addrDic:addrDic];
}

-(void)requestUpdateAddress:(int)addrID addrDic:(NSDictionary*)addrDic
{
    [_netLoading startAnimating];
    
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [net request_AddrUpdate_Datasuc:^(id success) {
        
        [_netLoading stopAnimating];
        
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            [MyAlert showMessage:@"操作成功" timer:2.0f];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [MyAlert showMessage:@"操作失败" timer:2.0f];
        }
        
    } fail:^(NSError *error) {
        
        [_netLoading stopAnimating];
        [MyAlert showMessage:@"操作失败" timer:2.0f];
        
    } addrID:addrID addrDic:addrDic];
}

-(void)requestComponent0RegionInfo:(int)parentID
{
    [_netLoading startAnimating];
    
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [net request_Region_Datasuc:^(id success) {
        
        [_netLoading stopAnimating];
        
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            [_provinceArray removeAllObjects];
            [_provinceArray addObjectsFromArray:success[@"data"][@"regions"]];
            [_cityPicker reloadComponent:0];
            [self UpdateDistrictTextField];
        }
        
    } fail:^(NSError *error) {
        
        [_netLoading stopAnimating];
        
    } parentID:parentID];
}

-(void)requestComponent1RegionInfo:(int)parentID
{
    [_netLoading startAnimating];
    
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [net request_Region_Datasuc:^(id success) {
        
        [_netLoading stopAnimating];
        
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            [_cityArray removeAllObjects];
            [_cityArray addObjectsFromArray:success[@"data"][@"regions"]];
            [_cityPicker reloadComponent:1];
            [self UpdateDistrictTextField];
        }
        
    } fail:^(NSError *error) {
        
        [_netLoading stopAnimating];
        
    } parentID:parentID];
}

-(void)requestComponent2RegionInfo:(int)parentID
{
    [_netLoading startAnimating];
    
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [net request_Region_Datasuc:^(id success) {
        
        [_netLoading stopAnimating];
        
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            [_districtArray removeAllObjects];
            [_districtArray addObjectsFromArray:success[@"data"][@"regions"]];
            [_cityPicker reloadComponent:2];
            [self UpdateDistrictTextField];
        }
        
    } fail:^(NSError *error) {
        
        [_netLoading stopAnimating];
        
    } parentID:parentID];
}

@end
