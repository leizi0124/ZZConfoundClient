//
//  ZZFileTableView.m
//  MacDemo
//
//  Created by JB-Mac on 2018/1/26.
//  Copyright © 2018年 MacDemo. All rights reserved.
//

#import "ZZFileTableView.h"
#import "Tools.h"
@interface ZZFileTableView ()<NSTableViewDelegate, NSTableViewDataSource>
{
    
    NSScrollView      *_tableContainerView;
    NSTableView       *_tableView;
}
@end
@implementation ZZFileTableView

- (instancetype)initWithFrame:(NSRect)frameRect {
    
    if (self = [super initWithFrame:frameRect]) {
        
        _tableContainerView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, frameRect.size.width, frameRect.size.height)];
        
        _tableView = [[NSTableView alloc] initWithFrame:NSMakeRect(0, 0, frameRect.size.width, frameRect.size.height)];
        [_tableView setBackgroundColor:[NSColor colorWithCalibratedRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:1.0]];
        _tableView.focusRingType = NSFocusRingTypeNone;                             //tableview获得焦点时的风格
        _tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;//行高亮的风格
        _tableView.headerView.frame = NSZeroRect;                                   //表头
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleRegular;
        
        [_tableContainerView setDocumentView:_tableView];
        [_tableContainerView setDrawsBackground:NO];        //不画背景（背景默认画成白色）
        [_tableContainerView setHasVerticalScroller:YES];   //有垂直滚动条
        _tableContainerView.autohidesScrollers = YES;       //自动隐藏滚动条（滚动的时候出现）
        [self addSubview:_tableContainerView];
        
        NSTableColumn * column1 = [[NSTableColumn alloc] initWithIdentifier:@"Column"];
        [column1 setWidth:self.frame.size.width];
        [_tableView addTableColumn:column1];//第一列
    }
    return self;
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return  self.pathModel.filesArray.count + self.pathModel.dirsArray.count;
}
//这个方法虽然不返回什么东西，但是必须实现，不实现可能会出问题－比如行视图显示不出来等。（10.11貌似不实现也可以，可是10.10及以下还是不行的）
- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    return nil;
}
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 30;
}
- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    
    NSString *strIdt=[tableColumn identifier];
    NSTableCellView *aView = [tableView makeViewWithIdentifier:strIdt owner:self];
    
    if (!aView){
        aView = [[NSTableCellView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
    }else {
        for (NSView *view in aView.subviews)[view removeFromSuperview];
    }
    
    NSTextField *textField = [[NSTextField alloc] initWithFrame:CGRectMake(2, -5, self.frame.size.width, 30)];
    textField.font = [NSFont systemFontOfSize:15.0f];
    textField.drawsBackground = NO;
    textField.bordered = NO;
    textField.focusRingType = NSFocusRingTypeNone;
    textField.editable = NO;
    [aView addSubview:textField];
    
    NSButton *selectBtn = [[NSButton alloc] initWithFrame:NSMakeRect(self.frame.size.width - 35, 5, 20, 20)];
    [selectBtn setButtonType:NSSwitchButton];
    [selectBtn setTarget:self];
    selectBtn.tag = 1000 + row;
    [selectBtn setAction:@selector(selectBtnAction:)];
    [aView addSubview:selectBtn];
    
    NSView *line = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width, 0.5)];
    [line setWantsLayer:YES];
    [line.layer setBackgroundColor:[[NSColor whiteColor] CGColor]];
    [aView addSubview:line];
    
    ZZPathModel *cellModel = nil;
    
    if (row < self.pathModel.filesArray.count) {
        cellModel = [self.pathModel.filesArray objectAtIndex:row];
    }else {
        cellModel = [self.pathModel.dirsArray objectAtIndex:row - self.pathModel.filesArray.count];
    }
    
    [textField setStringValue:cellModel.title];
    
    if (cellModel.isSelected) {
        selectBtn.state = 1;
    }else {
        selectBtn.state = 0;
    }
    
    return aView;
}
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {

    if (row >= self.pathModel.filesArray.count) {
        ZZPathModel *cellModel = [self.pathModel.dirsArray objectAtIndex:row - self.pathModel.filesArray.count];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(selectedFolder:tableview:)]) {
            [self.delegate selectedFolder:cellModel tableview:self];
        }
    }
    return NO;
}
#pragma mark - cell选中
- (void)selectBtnAction:(NSButton *)sender {
    
    NSInteger selectIndex = sender.tag - 1000;
    
    ZZPathModel *cellModel = nil;
    
    if (selectIndex < self.pathModel.filesArray.count) {
        cellModel = [self.pathModel.filesArray objectAtIndex:selectIndex];
    }else {
        cellModel = [self.pathModel.dirsArray objectAtIndex:selectIndex - self.pathModel.filesArray.count];
    }
    
    [Tools subfiles:cellModel selectState:sender.state];
    [Tools sharedInstance].selectPathChange = YES;
}
- (void)updateWith:(ZZPathModel *)model {
    self.pathModel = model;
    [_tableView reloadData];
}
- (void)reload {
    [_tableView reloadData];
}
@end
