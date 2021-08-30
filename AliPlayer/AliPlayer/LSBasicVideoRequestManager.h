//
//  LSBasicVideoRequestManager.h
//  AliPlayer
//
//  Created by 石玉龙 on 2021/8/30.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "LSModel.h"


#define  BASE_URL @"https://alivc-demo.aliyuncs.com"


NS_ASSUME_NONNULL_BEGIN

typedef void(^RequestSuccess)(id responseObject);
typedef void(^RequestFailure)(NSString *errorMsg);

@interface LSBasicVideoRequestManager : NSObject

+ (void)startRequestTypeIsGet:(BOOL)isGet
                   parameters:(NSDictionary *)parameters
                   requestURL:(NSString *)requestURL
                      success:(RequestSuccess)success
                      failure:(RequestFailure)failure;

@end


typedef void(^PVRequestSuccess)(LSResponseModel *responseModel);

typedef NS_ENUM(NSUInteger, URLType) {
    URLTypeUser,
};

@interface LSPlayVideoRequestManager : LSBasicVideoRequestManager

+ (void)getWithParameters:(NSDictionary *)parameters
                  urlType:(URLType)type
                  success:(PVRequestSuccess)success
                  failure:(RequestFailure)failure;

+ (void)postWithParameters:(NSDictionary *)parameters
                   urlTypr:(URLType)type
                   success:(PVRequestSuccess)success
                   failure:(RequestFailure)failure;

@end




NS_ASSUME_NONNULL_END
