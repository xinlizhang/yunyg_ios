//
//  NewArrivalView_iph.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "NewArrivalView_iph.h"
#import "UIImageView+OnlineImage.h"


@interface NewArrivalView_iph ()
{

}
@end


@implementation NewArrivalView_iph

@synthesize arrivalDelegate = _arrivalDelegate;

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        _dataArr = [[NSMutableArray alloc] init];
        
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 90, 15)];
    [_titleLabel setText:NSLocalizedString(@"新品上架", nil)];
    [_titleLabel setTextColor:[UIColor redColor]];
    [self addSubview:_titleLabel];
    [_titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_titleLabel release];
}

- (void)dealloc
{
    [super dealloc];
    
    [_dataArr release];
}

-(void)updateWithDataArray:(NSMutableArray*)dataArray
{
    [_dataArr removeAllObjects];
    for ( UIView* subView in self.subviews )
    {
        [subView removeFromSuperview];
    }
    
    [_dataArr addObjectsFromArray:dataArray];
    
    [self initUI];
    
    CGRect r = self.frame;
    NSArray * colorArr = @[ [UIColor redColor],
                            [UIColor blueColor],
                            [UIColor orangeColor],
                            [UIColor greenColor]
                            ];
    for (int y = 0, b = 1; b && y < 2; y ++) {
        for (int x = 0; x < 2; x ++) {
            int index = y * 2 + x;
            if (index >= [_dataArr count]) {
                b = 0;
                break;
            }
            CGPoint p = CGPointMake(r.size.width/2*(x+1) - 55, 110 + 130 * y);
            NSDictionary * dic = _dataArr[index];
            
            UIImageView * iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
            [iv setOnlineImage:dic[@"img"][@"thumb"] placeholderImage:[UIImage imageNamed:@"common_img_loding"]];
            [iv setCenter:p];
            [iv setTag:[dic[@"goods_id"] intValue]];
            [self addSubview:iv];

            iv.userInteractionEnabled = YES;
            UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OnClickedGoods:)];
            [iv addGestureRecognizer:singleTap1];
            [singleTap1 release];
            [iv release];
            
            p.x = r.size.width/2*x + r.size.width/4;
            p.y -= 60;
            UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, r.size.width/2 - 30, 15)];
            [lbl setText:dic[@"name"]];
            [lbl setCenter:p];
            [lbl setTextAlignment:NSTextAlignmentLeft];
            [lbl setFont:[UIFont systemFontOfSize:13]];
            [lbl setTextColor:colorArr[index%4]];
            [self addSubview:lbl];
            [lbl release];
            
//            p.y += 20;
//            lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, r.size.width/2 - 30, 15)];
//            [lbl setText:dic[@"goods"][0][@"name"]];
//            [lbl setTextColor:[UIColor grayColor]];
//            [lbl setCenter:p];
//            [lbl setTextAlignment:NSTextAlignmentLeft];
//            [lbl setFont:[UIFont systemFontOfSize:13]];
//            [self addSubview:lbl];
//            [lbl release];
        }
    }
    [self drawSeperator];
}

-(void)OnClickedGoods:(id)sender;
{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
    NSInteger iID = tap.view.tag;
    [_arrivalDelegate onNewArrivalViewClickedAtIndex:iID];
    
}

-(void)drawSeperator
{
    //横
    UIView * seprator = [[UIView alloc] initWithFrame:CGRectMake(0, 160, self.frame.size.width, 0.5)];
    [seprator setBackgroundColor:[UIColor lightGrayColor]];
    [self addSubview:seprator];
    [seprator release];
    
    //竖
    seprator = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2, 40, 0.5, 245)];
    [seprator setBackgroundColor:[UIColor lightGrayColor]];
    [self addSubview:seprator];
    [seprator release];
}
@end
