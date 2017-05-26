//
//  TopOfHomeScrollView_iph.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GalleryScrollViewProtocol_iph <NSObject>

@required
-(void)onGalleryScrollViewPage:(int)curPage totalPage:(int)totalPage;

@end


@interface GalleryScrollView_iph : UIScrollView
{
    NSMutableArray*     _galleryDataArr;
}

@property (nonatomic, assign) id<GalleryScrollViewProtocol_iph> deleteGallery;

-(void)updateWithDataArray:(NSMutableArray*)dataArray;


@end
