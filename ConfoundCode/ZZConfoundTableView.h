//
//  ZZConfoundTableView.h
//  MacDemo
//
//  Created by JB-Mac on 2018/1/31.
//  Copyright © 2018年 MacDemo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZZConfoundModel.h"
@interface ZZConfoundTableView : NSView
@property (nonatomic, strong) NSArray *dataArray;
/**
 更新
 */
- (void)updateWith:(NSArray *)array isSelected:(BOOL)isSelected;
@end
