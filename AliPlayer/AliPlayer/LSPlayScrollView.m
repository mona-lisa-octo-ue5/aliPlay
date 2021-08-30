//
//  LSPlayScrollView.m
//  AliPlayer
//
//  Created by 石玉龙 on 2021/8/30.
//

#import "LSPlayScrollView.h"


@interface LSPlayScrollView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *imgVArr;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UIView *playImgContainer;
@property (nonatomic, strong) UIImageView *playImgV;
@property (nonatomic, assign) BOOL isPlayStop;
@property (nonatomic, assign) BOOL hasLoad;

@end

@implementation LSPlayScrollView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame dataArray:(NSArray<LSVideoListModel *> *)arr {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.clearColor;
        self.imgVArr = [NSMutableArray arrayWithCapacity:0];
        self.dataArr = [NSMutableArray arrayWithCapacity:0];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.delegate = self;
        self.scrollView.pagingEnabled = YES;
        if (@available(iOS 11.0, *)) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        __weak typeof(self) weakSelf = self;
        self.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            if ([weakSelf.delegate respondsToSelector:@selector(playScrollViewHeaderRefreshing:)]) {
                [weakSelf.delegate playScrollViewHeaderRefreshing:weakSelf];
            }
        }];
        
        [self addDataArray:arr];
        
        self.playView = [[UIView alloc] initWithFrame:self.scrollView.bounds];
        [self.scrollView addSubview:self.playView];
        self.playView.hidden = YES;
        
        CGFloat width = 70;
        self.playImgContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        self.playImgContainer.layer.cornerRadius = width/2;
        self.playImgContainer.clipsToBounds = YES;
        self.playImgContainer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        self.playImgContainer.center = self.playView.center;
        [self.playView addSubview:self.playImgContainer];
        
        self.playImgV = [[UIImageView alloc] initWithImage:nil];
        self.playImgV.contentMode = UIViewContentModeScaleAspectFit;
        [self.playView addSubview:self.playImgV];
        self.playImgV.center = self.playView.center;
        self.showPlayImage = NO;
        
        [self addTapGesture];
        
        UIButton *backButton = [[UIButton alloc] init];
        [backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [backButton setImage:nil forState:UIControlStateNormal];
        backButton.frame = CGRectMake(0, 0, 40, 40);
        backButton.center = CGPointMake(15 + backButton.frame.size.width/2, 20 + 22);
        [self addSubview:backButton];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
    }
    return self;
}

- (void)applicationDidBecomeActive {
    [self scrollViewDidEndDecelerating:self.scrollView];
}

- (void)addDataArray:(NSArray<LSVideoListModel *> *)arr {
    LSVideoListModel *d = self.dataArr.lastObject;
    int lastIdx = -1;
    if (d) {
        lastIdx = (int)d.index;
    }
    
    LSVideoListModel *fd = arr.firstObject;
    if (fd.index > lastIdx) {
        [self.dataArr addObjectsFromArray:arr];
        CGFloat selfW = self.frame.size.width;
        CGFloat selfH = self.frame.size.height;
        self.scrollView.contentSize = CGSizeMake(selfW, self.scrollView.contentSize.height + selfH * arr.count);
        
        for (LSVideoListModel *dd in arr) {
            UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, selfH * dd.index, selfW, selfH)];
            imgV.contentMode = UIViewContentModeScaleAspectFit;
            if (dd.firstFrameUrl.length > 0) {
                [imgV sd_setImageWithURL:[NSURL URLWithString:dd.firstFrameUrl]];
            } else {
                [imgV sd_setImageWithURL:[NSURL URLWithString:dd.coverUrl]];
            }
            imgV.tag = dd.index + 100;
            [self.scrollView addSubview:imgV];
            [self.imgVArr addObject:imgV];
            [self.scrollView sendSubviewToBack:imgV];
        }
    }
}

- (void)removeDataArray:(NSArray<LSVideoListModel *> *)arr {
    for (LSVideoListModel *dd in arr) {
        UIImageView *imgV = [self findImageViewFromIndex:dd.index + 100];
        if (imgV) {
            [self.dataArr removeObject:dd];
            [imgV removeFromSuperview];
            [self.imgVArr removeObject:imgV];
        }
    }
    self.scrollView.contentInset = UIEdgeInsetsMake(self.scrollView.contentInset.top - arr.count * self.frame.size.height, 0, 0, 0);
}

- (UIImageView *)findImageViewFromIndex:(NSInteger)idx {
    for (UIImageView *imgV in self.imgVArr) {
        if (imgV.tag == idx) {
            return imgV;
        }
    }
    return nil;
}

- (void)addTapGesture {
    UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapViewAction)];
    t.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:t];
}

- (void)tapViewAction {
    if ([self.delegate respondsToSelector:@selector(playScrollViewTapGetstureAction:)]) {
        [self.delegate playScrollViewTapGetstureAction:self];
    }
}

- (void)backButtonAction {
    if ([self.delegate respondsToSelector:@selector(palyScrollViewBackButtonAction:)]) {
        [self.delegate palyScrollViewBackButtonAction:self];
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    self.scrollView.contentOffset = CGPointMake(0, self.frame.size.height * currentIndex);
    [self resetPlayViewFrame];
}

- (void)resetPlayViewFrame {
    LSVideoListModel *d = self.dataArr.lastObject;
    CGFloat maxoffsetY = self.scrollView.frame.size.height * d.index;
    if (self.scrollView.contentOffset.y < 0) {
        self.playView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    } else if (self.scrollView.contentOffset.y > maxoffsetY) {
        self.playView.frame = CGRectMake(0, maxoffsetY, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    } else {
        self.playView.frame = CGRectMake(0, self.scrollView.contentOffset.y, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    }
}

- (void)setShowPlayImage:(BOOL)showPlayImage {
    _showPlayImage = showPlayImage;
    self.playImgV.hidden = !showPlayImage;
    self.playImgContainer.hidden = !showPlayImage;
}

- (void)showPlayView {
    self.playView.hidden = NO;
    [self.playView bringSubviewToFront:self.playImgContainer];
    [self.playView bringSubviewToFront:self.playImgV];
}

- (void)endRefreshingAndReset:(BOOL)reset {
    if (reset) {
        self.scrollView.contentSize = CGSizeZero;
        self.scrollView.contentOffset = CGPointZero;
    }
    [self.scrollView.mj_header endRefreshing];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat idxFloat = scrollView.contentOffset.y / self.frame.size.height;
    NSInteger idx = (NSInteger)idxFloat;
    LSVideoListModel *fd = self.dataArr.firstObject;
    LSVideoListModel *ld = self.dataArr.lastObject;
    if (idx < fd.index || idx > ld.index) {
        return;
    }
    
    if (idx != self.currentIndex || self.isPlayStop) {
        self.playView.hidden = YES;
        self.isPlayStop = NO;
        [self resetPlayViewFrame];
        
        if (idx - self.currentIndex == 1) {
            if ([self.delegate respondsToSelector:@selector(playScrollView:moteNextAtIndex:)]) {
                [self.delegate playScrollView:self moteNextAtIndex:idx];
            }
        }else if (self.currentIndex - idx == 1) {
            if ([self.delegate respondsToSelector:@selector(playScrollView:motoPreAtIndex:)]) {
                [self.delegate playScrollView:self motoPreAtIndex:idx];
            }
        }else {
            if ([self.delegate respondsToSelector:@selector(playScrollView:scrollViewDidEndDeceleratingAtIndex:)]) {
                [self.delegate playScrollView:self scrollViewDidEndDeceleratingAtIndex:idx];
            }
        }
        
        self.currentIndex = idx;
        
        LSVideoListModel *ld = self.dataArr.lastObject;
        if (ld.index - idx < 4) {
            if ([self.delegate respondsToSelector:@selector(playScrollViewNeedNewData:)]) {
                [self.delegate playScrollViewNeedNewData:self];
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.hasLoad) {
        self.hasLoad = YES;
        return;
    }
    if (ABS(scrollView.contentOffset.y - self.playView.frame.origin.y) > self.frame.size.height) {
        if (self.isPlayStop == NO) {
            self.isPlayStop = YES;
            if ([self.delegate respondsToSelector:@selector(playScrollViewScrollOut:)]) {
                [self.delegate playScrollViewScrollOut:self];
            }
        }
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    return NO;
}

@end




