//
//  ZZCustomFilterVC.h
//  OC_Confound
//
//  Created by JB-Mac on 2018/2/6.
//  Copyright © 2018年 MacDemo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
typedef NS_OPTIONS(NSInteger, fModeType) {
    fModeTypeAdd = 0,       //增加自定义混淆字段
    fModeTypeFilter,        //增加自定义过滤字段
};
@interface ZZCustomFilterVC : NSViewController
@property (nonatomic, assign) fModeType modeType;
@end
