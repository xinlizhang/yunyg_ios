//
//  TopOfHomeScrollView_iph.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "GalleryScrollView_iph.h"
#import "UIImageView+OnlineImage.h"

@interface GalleryScrollView_iph () <UIScrollViewDelegate>
{
    
}
@end

@implementation GalleryScrollView_iph

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        [self setPagingEnabled:YES];
        [self setShowsHorizontalScrollIndicator:NO];
        [self setShowsVerticalScrollIndicator:NO];
        [self setBounces:NO];
        [self setDelegate:self];
        
        
    }
    return self;
}

-(void)updateWithDataArray:(NSMutableArray*)dataArray
{
    _galleryDataArr = dataArray;
    
    CGRect r = self.frame;
    int iMarginTop = 25;
    int iMarginLft = 25;
    
    for (int i = 0; i < [_galleryDataArr count]; i ++) {
        NSDictionary * dic = _galleryDataArr[i];
        UIImageView * iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, r.size.width-2*iMarginLft, r.size.height-2*iMarginTop)];
        [iv setCenter:CGPointMake(r.size.width/2 + i*r.size.width, r.size.height/2)];
        [iv setOnlineImage:dic[@"url"] placeholderImage:[UIImage imageNamed:@"common_img_loding"]];
        [self addSubview:iv];
        [iv release];
    }
    
    [self setContentSize:CGSizeMake(r.size.width * [_galleryDataArr count], r.size.height)];
    
    [_deleteGallery onGalleryScrollViewPage:1 totalPage:(int)[_galleryDataArr count]];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pagewidth = self.frame.size.width;
    
    int currentPage = abs((int)self.contentOffset.x) / pagewidth + 1;
    NSInteger totalPage = [_galleryDataArr count];
    
    [_deleteGallery onGalleryScrollViewPage:currentPage totalPage:(int)totalPage];
}


@end
