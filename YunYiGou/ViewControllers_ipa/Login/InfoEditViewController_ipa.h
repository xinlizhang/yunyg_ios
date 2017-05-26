//
//  MineViewController_ipa.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "BasicViewController_ipa.h"


typedef enum
{
    ENUM_EDIT_MODE_START,
    
    ENUM_EDIT_MODE_SEX,
    ENUM_EDIT_MODE_BIRTHDAY,
    ENUM_EDIT_MODE_EMAIL,
    ENUM_EDIT_MODE_PASSWORD,
    
    ENUM_EDIT_MODE_END
}
ENUM_EDIT_MODE;

@interface InfoEditViewController_ipa : BasicViewController_ipa

- (void)setEditMode:(ENUM_EDIT_MODE)editMode;

@end
