//
//  ZZFileTableView.h
//  MacDemo
//
//  Created by JB-Mac on 2018/1/26.
//  Copyright © 2018年 MacDemo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZZPathModel.h"
@interface ZZFileTableView : NSView
@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) NSInteger tableLevel;
@property (nonatomic, strong) ZZPathModel *pathModel;
/**
 更新
 */
- (void)updateWith:(ZZPathModel *)model;
/**
 刷新
 */
- (void)reload;
@end
@protocol ZZFileTableViewDelegate <NSObject>
/**
 选中文件夹
 */
- (void)selectedFolder:(ZZPathModel *)pathModel tableview:(ZZFileTableView *)tableview;
@end