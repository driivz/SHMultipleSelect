//
//  SHMultipleSelect.h
//  Bugzilla
//
//  Created by Shamsiddin Saidov on 07/22/2015.
//  Copyright (c) 2015 shamsiddin.saidov@gmail.com. All rights reserved.
//

#import "SHMultipleSelect.h"

#define MAIN_SCREEN_RECT [[UIScreen mainScreen] bounds]

@interface SHMultipleSelect () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UITableView *table;

- (void)btnClick:(UIButton *)sender;

@end

@implementation SHMultipleSelect

const CGFloat kSelectionRowHeight  = 40.0;
const CGFloat kSelectionBtnHeight  = 40.0;
const CGFloat kSelectionLeftMargin = 10.0;
const CGFloat kSelectionTopMargin  = 30.0;

const CGFloat kAnimationTimeInterval  = 0.2;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, MAIN_SCREEN_RECT.size.width, MAIN_SCREEN_RECT.size.height);
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
        self.layer.opacity = 0.0;
        
        _hasSelectAll = NO;
        _onlyOneChoice = NO;
    }
    
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *text = nil;
    if ([self.delegate respondsToSelector:@selector(multipleSelectView:titleForRowAtIndexPath:)]) {
        text = [self.delegate multipleSelectView:self titleForRowAtIndexPath:indexPath];
    }
    cell.textLabel.text = text;
    
    BOOL selected = NO;
    if ([self.delegate respondsToSelector:@selector(multipleSelectView:setSelectedForRowAtIndexPath:)]) {
        selected = [self.delegate multipleSelectView:self setSelectedForRowAtIndexPath:indexPath];
    }
    
    if (selected) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.onlyOneChoice) {
        // deselecting all before
        for (NSUInteger i = 0; i < self.rowsCount; ++i) {
            [tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO];
        }
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(multipleSelectView:didSelectRowAtIndexPath:)]) {
        [self.delegate multipleSelectView:self didSelectRowAtIndexPath:indexPath];
    }
    
    if (self.hasSelectAll && (indexPath.row == 0)) {
        for (NSUInteger i = 1; i < self.rowsCount; ++i) {
            [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]
                                   animated:NO
                             scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(multipleSelectView:didDeselectRowAtIndexPath:)]) {
        [self.delegate multipleSelectView:self didDeselectRowAtIndexPath:indexPath];
    }
    
    if (self.hasSelectAll && (indexPath.row == 0)) {
        for (NSUInteger i = 1; i < self.rowsCount; ++i) {
            [tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO];
        }
    }
    else if (self.hasSelectAll) {
        [tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kSelectionRowHeight;
}

- (void)show {
    
    //Fixes an issue when triggerring while keyboard is showing
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    
    [UIView animateWithDuration:kAnimationTimeInterval animations:^{
        self.layer.opacity = 1;
    }];
    
    UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(kSelectionLeftMargin, 0.0,
                                                                 MAIN_SCREEN_RECT.size.width - (2 * kSelectionLeftMargin), 0.0)];
    
    coverView.layer.cornerRadius = 7;
    coverView.clipsToBounds = YES;
    coverView.backgroundColor = [UIColor whiteColor];
    [self addSubview:coverView];
    
    UIScrollView *tableScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, coverView.width, 0.0)];
    
    // table settings
    CGFloat allRowsHeight = kSelectionRowHeight * self.rowsCount;
    
    if (allRowsHeight + 100 > self.height) {
        coverView.top = kSelectionTopMargin;
        coverView.height = self.height - (2 * kSelectionTopMargin);
    }
    else {
        coverView.top = (self.height - (allRowsHeight + kSelectionBtnHeight)) / 2;
        coverView.height = allRowsHeight + kSelectionBtnHeight;
    }
    
    tableScroll.top = 0;
    tableScroll.height = coverView.height - kSelectionBtnHeight;
    
    tableScroll.contentSize = CGSizeMake(tableScroll.width, allRowsHeight);
    
    [coverView addSubview:tableScroll];
    
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, tableScroll.width, allRowsHeight)
                                                      style:UITableViewStylePlain];
    table.dataSource = self;
    table.delegate = self;
    table.scrollEnabled = NO;
    table.allowsMultipleSelectionDuringEditing = YES;
    [table setEditing:YES animated:NO];
    
    [tableScroll addSubview:table];
    _table = table;
    
    CGSize imageSize = CGSizeMake(10.0, 10.0);
    UIImage *btnImageNormal = [[UIImage imageWithColor:[UIColor whiteColor]
                                                  size:imageSize] stretchableImageWithLeftCapWidth:3 topCapHeight:3];
    UIImage *btnImageHighlighted = [[UIImage imageWithColor:[UIColor colorWithRed:208/255.0 green:208/255.0 blue:208/255.0 alpha:1.0]
                                                       size:imageSize] stretchableImageWithLeftCapWidth:3 topCapHeight:3];
    
    // _cancelBtn settings
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, tableScroll.bottom,
                                                                     coverView.width / 2.0, kSelectionBtnHeight)];
    cancelBtn.tag = 0;
    [cancelBtn setTitle:NSLocalizedString(@"Cancel", @"Cancel") forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:btnImageNormal forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:btnImageHighlighted forState:UIControlStateHighlighted];
    [cancelBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [coverView addSubview:cancelBtn];
    
    // _doneBtn settings
    UIButton *doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(cancelBtn.right,
                                                                   tableScroll.bottom,
                                                                   coverView.width / 2.0,
                                                                   kSelectionBtnHeight)];
    doneBtn.tag = 1;
    [doneBtn setTitle:NSLocalizedString(@"Done", @"Done") forState:UIControlStateNormal];
    [doneBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [doneBtn setBackgroundImage:btnImageNormal forState:UIControlStateNormal];
    [doneBtn setBackgroundImage:btnImageHighlighted forState:UIControlStateHighlighted];
    [doneBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [coverView addSubview:doneBtn];
    
    // btnsSeparator settings
    UIView *btnsSeparator = [[UIView alloc] initWithFrame:CGRectMake(cancelBtn.right,
                                                                     tableScroll.bottom,
                                                                     0.7,
                                                                     kSelectionBtnHeight)];
    btnsSeparator.backgroundColor = [UIColor lightGrayColor];
    [coverView addSubview:btnsSeparator];
    
    [[UIApplication sharedApplication].delegate.window addSubview:self];
}

- (IBAction)btnClick:(UIButton *)sender {
    __weak typeof(self) weak = self;
    [UIView animateWithDuration:kAnimationTimeInterval
                     animations:^{
                         weak.layer.opacity = 0;
                     }
                     completion:^(BOOL finished) {
                         [weak removeFromSuperview];
                         if ([weak.delegate respondsToSelector:@selector(multipleSelectView:clickedBtnAtIndex:withSelectedIndexPaths:)]) {
                             [weak.delegate multipleSelectView:weak
                                             clickedBtnAtIndex:sender.tag
                                        withSelectedIndexPaths:weak.table.indexPathsForSelectedRows];
                         }
                     }];
}

@end
