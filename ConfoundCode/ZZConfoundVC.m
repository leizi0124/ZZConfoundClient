//
//  ZZConfoundVC.m
//  MacDemo
//
//  Created by JB-Mac on 2018/1/30.
//  Copyright © 2018年 MacDemo. All rights reserved.
//

#import "ZZConfoundVC.h"
#import "Tools.h"
#import "ZZConfoundTableView.h"
#import "ZZCustomFilterVC.h"
@interface ZZConfoundVC ()<NSWindowDelegate>
{
    ZZConfoundTableView *selectedTableView;
    ZZConfoundTableView *unSelectedTableView;
}
@end

@implementation ZZConfoundVC
- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize{
    return NSMakeSize(1000, 422);
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"需要混淆 : 0                                             混淆字段筛选                                                    无需混淆 : 0"];
    
    selectedTableView = [[ZZConfoundTableView alloc] initWithFrame:NSMakeRect(0, 0, 450, self.view.frame.size.height)];
    [self.view addSubview:selectedTableView];
    
    unSelectedTableView = [[ZZConfoundTableView alloc] initWithFrame:NSMakeRect(550, 0, 450, self.view.frame.size.height)];
    [self.view addSubview:unSelectedTableView];
    
    [self updateTableviews:nil];
}
- (IBAction)updateTableviews:(NSButton *)sender {
    NSMutableArray *selectedArray = [NSMutableArray array];
    NSMutableArray *unSelectedArray = [NSMutableArray array];
    
    for (ZZPathModel *model in [Tools sharedInstance].confoundArray) {
        if (model.isSelected) {
            [selectedArray addObject:model];
        }else {
            [unSelectedArray addObject:model];
        }
    }
    
    [selectedTableView updateWith:selectedArray isSelected:YES];
    [unSelectedTableView updateWith:unSelectedArray isSelected:NO];
    
    self.title = [NSString stringWithFormat:@"需要混淆 : %zd                                             混淆字段筛选                                                    无需混淆 : %zd",selectedArray.count,unSelectedArray.count];
}
- (IBAction)buildConfoundFile:(NSButton *)sender {
    
    [self dismissController:self];
}
#pragma mark - 增加自定义混淆字段
- (IBAction)customFilters:(NSButton *)sender {
    ZZCustomFilterVC *customVC = [[ZZCustomFilterVC alloc] init];
    customVC.modeType = fModeTypeAdd;
    [self presentViewControllerAsSheet:customVC];
}
#pragma mark - 增加自定义过滤字段
- (IBAction)confoundFilters:(NSButton *)sender {
    ZZCustomFilterVC *customVC = [[ZZCustomFilterVC alloc] init];
    customVC.modeType = fModeTypeFilter;
    [self presentViewControllerAsSheet:customVC];
}
@end
