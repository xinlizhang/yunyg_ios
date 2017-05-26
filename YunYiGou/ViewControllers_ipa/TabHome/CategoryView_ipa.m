//
//  CategoryView_ipa.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//


#import "CategoryView_ipa.h"
#import "UIImageView+OnlineImage.h"


@interface CategoryView_ipa ()
{

}
@end

@implementation CategoryView_ipa

@synthesize cateDelegate = _cateDelegate;

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        _dataArr = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)initUI
{
    
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
    
    NSArray * colorArr = @[ [UIColor redColor],
                            [UIColor blueColor],
                            [UIColor orangeColor],
                            [UIColor greenColor]
                            ];
    CGRect r = self.frame;
    for (int y = 0, b = 1; b && y < 2; y ++) {
        for (int x = 0; x < 3; x ++) {
            int index = y * 3 + x;
            if (index >= [_dataArr count]) {
                b = 0;
                break;
            }
            
            NSDictionary * dic = _dataArr[index];
            
            CGPoint p = CGPointMake(r.size.width / 6 + r.size.width/3*x, 125 + 230 * y);
            
            UIImageView * iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 190, 190)];
            [iv setOnlineImage:dic[@"category_thumb"] placeholderImage:[UIImage imageNamed:@"common_img_loding"]];
            [iv setCenter:p];
            [iv setTag:[dic[@"id"] intValue]];
            [self addSubview:iv];
                        
            iv.userInteractionEnabled = YES;
            UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OnClickedGoods:)];
            [iv addGestureRecognizer:singleTap1];
            [singleTap1 release];
            [iv release];
            
            p.x += 10;
            p.y -= 110;
            UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 19)];
            [lbl setText:dic[@"name"]];
            [lbl setCenter:p];
            [lbl setTextAlignment:NSTextAlignmentLeft];
            [lbl setFont:[UIFont systemFontOfSize:18]];
            [lbl setTextColor:colorArr[index%4]];
            [self addSubview:lbl];
            [lbl release];
        }
    }
    
    [self drawSeperator];
    
}

-(void)OnClickedGoods:(id)sender;
{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
    NSInteger iID = tap.view.tag;
    [_cateDelegate onCategoryViewViewClickedAtIndex:iID];
}

-(void)drawSeperator
{
    //横
    UIView * seprator = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height / 2, self.frame.size.width, 0.5)];
    [seprator setBackgroundColor:[UIColor lightGrayColor]];
    [self addSubview:seprator];
    [seprator release];
    
    //竖
    for (int i = 1; i <= 2; i ++) {
        seprator = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width / 3 * i, 0, 0.5, self.frame.size.height)];
        [seprator setBackgroundColor:[UIColor lightGrayColor]];
        [self addSubview:seprator];
        [seprator release];
    }
}
@end
