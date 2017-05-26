//
//  TopOfHomeScrollView_ipa.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GalleryScrollViewProtocol_ipa <NSObject>

@required
-(void)onGalleryScrollViewPage:(int)curPage totalPage:(int)totalPage;

@end


@interface GalleryScrollView_ipa : UIScrollView
{
    NSMutableArray*     _galleryDataArr;
}

@property (nonatomic, assign) id<GalleryScrollViewProtocol_ipa> deleteGallery;

-(void)updateWithDataArray:(NSMutableArray*)dataArray;


@end
