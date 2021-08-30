//
//  LSPlayScrollView.h
//  AliPlayer
//
//  Created by 石玉龙 on 2021/8/30.
//

#import <UIKit/UIKit.h>
#import <JSONModel/JSONModel.h>
#import <MJRefresh/MJRefresh.h>
#import <SDWebImage/UIImageView+WebCache.h>

NS_ASSUME_NONNULL_BEGIN

@class LSPlayScrollView;

@protocol LSPlayScrollViewDelegate <NSObject>

- (void)palyScrollViewBackButtonAction:(LSPlayScrollView *)sclView;
- (void)playScrollViewTapGetstureAction:(LSPlayScrollView *)sclView;
- (void)playScrollView:(LSPlayScrollView *)sclView scrollViewDidEndDeceleratingAtIndex:(NSInteger)idx;
- (void)playScrollView:(LSPlayScrollView *)sclView moteNextAtIndex:(NSInteger)idx;
- (void)playScrollView:(LSPlayScrollView *)sclView motoPreAtIndex:(NSInteger)idx;
- (void)playScrollViewScrollOut:(LSPlayScrollView *)sclView;
- (void)playScrollViewNeedNewData:(LSPlayScrollView *)sclView;
- (void)playScrollViewHeaderRefreshing:(LSPlayScrollView *)sclView;

@end


@class LSVideoListModel;

@interface LSPlayScrollView : UIView

@property (nonatomic, weak) id<LSPlayScrollViewDelegate> delegate;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) BOOL showPlayImage;
@property (nonatomic, strong) UIView *playView;

- (instancetype)initWithFrame:(CGRect)frame dataArray:(NSArray <LSVideoListModel *>*)arr;
- (void)showPlayView;
- (void)addDataArray:(NSArray <LSVideoListModel *>*)arr;
- (void)removeDataArray:(NSArray <LSVideoListModel *>*)arr;
- (void)endRefreshingAndReset:(BOOL)reset;

@end



@interface LSVideoListModel : JSONModel

@property (nonatomic, strong) NSString *coverUrl;
@property (nonatomic, strong) NSString *firstFrameUrl;
@property (nonatomic, strong) NSString *videoId;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) NSUUID *uuid;
@property (nonatomic, strong) NSString *fileUrl;
@property (nonatomic, strong) NSString *descriptionStr;
@property (nonatomic, strong) NSString *title;

@end

NS_ASSUME_NONNULL_END
