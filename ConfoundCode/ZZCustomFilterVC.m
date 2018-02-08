//
//  ZZCustomFilterVC.m
//  OC_Confound
//
//  Created by JB-Mac on 2018/2/6.
//  Copyright © 2018年 MacDemo. All rights reserved.
//

#import "ZZCustomFilterVC.h"
#import "Tools.h"
@interface ZZCustomFilterVC ()<NSWindowDelegate, NSTextViewDelegate>
@property (nonatomic, strong) NSTextView *theTextView;
@property (nonatomic, strong) NSScrollView *scrollView;
@property (weak) IBOutlet NSButton *okButton;
@end
@implementation ZZCustomFilterVC
- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize{
    return NSMakeSize(800, 380);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self textViewInit];
}
- (void)viewWillAppear {
    switch (self.modeType) {
        case fModeTypeAdd:{
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:ADD_NORMAL_CONFOUNDS] length]) {
                
                self.theTextView.string = [[NSUserDefaults standardUserDefaults] valueForKey:ADD_NORMAL_CONFOUNDS];
            }else {
                self.theTextView.string = @"confoundValue1,confoundValue2,...";
            }
        }
            break;
        case fModeTypeFilter:{
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:ADD_NORMAL_FILTERS] length]) {
                
                self.theTextView.string = [[NSUserDefaults standardUserDefaults] valueForKey:ADD_NORMAL_FILTERS];
            }else {
                self.theTextView.string = @"filterValue1,filterValue2,...";
            }
        }
            break;
        default:
            break;
    }
}
#pragma mark - 取消
- (IBAction)cancelAction:(NSButton *)sender {
    
    [self dismissController:self];
}
#pragma mark - 确定
- (IBAction)okAction:(NSButton *)sender {
    
    switch (self.modeType) {
        case fModeTypeAdd:{
            
            [[NSUserDefaults standardUserDefaults] setObject:self.theTextView.string forKey:ADD_NORMAL_CONFOUNDS];
            
        }
            break;
        case fModeTypeFilter:{
            
            [[NSUserDefaults standardUserDefaults] setObject:self.theTextView.string forKey:ADD_NORMAL_FILTERS];
            
        }
            break;
        default:
            break;
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dismissController:self];
}
#pragma mark - 代理
- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(nullable NSString *)replacementString {
    if (!self.okButton.enabled) {
        self.okButton.enabled = YES;
    }
    return YES;
}
- (void)textViewInit {
    self.theTextView = [[NSTextView alloc]initWithFrame:CGRectMake(0, 22, 800, 358)];
    [self.view addSubview:self.theTextView];
    self.theTextView.backgroundColor = [NSColor whiteColor];
    self.theTextView.editable = YES;
    self.theTextView.textColor = [NSColor blackColor];
    self.theTextView.delegate = self;
    
    // NSScrollView
    self.scrollView = [[NSScrollView alloc]initWithFrame:CGRectMake(0, 22, 800, 358)];
    [self.scrollView setBorderType:NSNoBorder];
    [self.scrollView setHasVerticalScroller:YES];
    [self.scrollView setHasHorizontalScroller:NO];
    [self.scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    [self.theTextView setMinSize:NSMakeSize(800, 360)];
    [self.theTextView setMaxSize:NSMakeSize(800, FLT_MAX)];
    [self.theTextView setVerticallyResizable:YES];
    [self.theTextView setHorizontallyResizable:NO];
    [self.theTextView setAutoresizingMask:NSViewWidthSizable];
    [[self.theTextView textContainer]setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [[self.theTextView textContainer]setWidthTracksTextView:YES];
    [self.theTextView setFont:[NSFont fontWithName:@"PingFang-SC-Regular" size:14.0]];
    [self.theTextView setEditable:YES];
    
    [self.scrollView setDocumentView:self.theTextView];
    [self.view addSubview:self.scrollView];
    
}
@end
