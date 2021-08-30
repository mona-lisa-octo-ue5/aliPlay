//
//  LSModel.h
//  AliPlayer
//
//  Created by 石玉龙 on 2021/8/30.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSModel : NSObject

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


@class LSResponseDataModel;
@interface LSResponseModel : JSONModel

@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) LSResponseDataModel *data;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *requestId;
@property (nonatomic, assign) BOOL result;
@end


@interface LSResponseDataModel : JSONModel

@property (nonatomic, strong) NSString *videoId;
@property (nonatomic, strong) NSString *accessKeyId;
@property (nonatomic, strong) NSString *accessKeySecret;
@property (nonatomic, strong) NSString *securityToken;
@property (nonatomic, strong) NSString *expiration;

@end



NS_ASSUME_NONNULL_END
