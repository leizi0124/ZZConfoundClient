//
//  ZZConfoundTableView.m
//  MacDemo
//
//  Created by JB-Mac on 2018/1/31.
//  Copyright © 2018年 MacDemo. All rights reserved.
//

#import "ZZConfoundTableView.h"

@interface ZZConfoundTableView ()<NSTableViewDelegate, NSTableViewDataSource>
{
    
    NSScrollView      *_tableContainerView;
    NSTableView       *_tableView;
    //被选中字段不显示 √
    BOOL isConfoundTable;
}
@end
@implementation ZZConfoundTableView

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
    return  self.dataArray.count;
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
    selectBtn.enabled = NO;
    [aView addSubview:selectBtn];
    
    NSView *line = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width - 10, 0.5)];
    [line setWantsLayer:YES];
    [line.layer setBackgroundColor:[[NSColor whiteColor] CGColor]];
    [aView addSubview:line];
    
    ZZConfoundModel *cellModel = self.dataArray[row];
    
    [textField setStringValue:cellModel.title];
    
    selectBtn.state = (cellModel.isSelected == !isConfoundTable);
    
    return aView;
}
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    ZZConfoundModel *cellModel = self.dataArray[row];
    cellModel.isSelected = !cellModel.isSelected;
    [_tableView reloadData];
    return NO;
}
#pragma mark - 更新
- (void)updateWith:(NSArray *)array isSelected:(BOOL)isSelected {
    isConfoundTable = isSelected;
    self.dataArray = array;
    [_tableView reloadData];
}
@end
