//
//  LSBasicVideoRequestManager.m
//  AliPlayer
//
//  Created by 石玉龙 on 2021/8/30.
//

#import "LSBasicVideoRequestManager.h"

#define TIME_OUT 10

@implementation LSBasicVideoRequestManager

static AFHTTPSessionManager *sessionManager = nil;

+ (AFHTTPSessionManager *)defaultSessionManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionManager = [AFHTTPSessionManager manager];
        sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        sessionManager.securityPolicy = [AFSecurityPolicy defaultPolicy];
        sessionManager.requestSerializer.timeoutInterval = TIME_OUT;
        sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"text/html", @"application/json", nil];
    });
    return sessionManager;
}

+ (void)startRequestTypeIsGet:(BOOL)isGet
                   parameters:(NSDictionary *)parameters
                   requestURL:(NSString *)requestURL
                      success:(RequestSuccess)success
                      failure:(RequestFailure)failure {
    AFHTTPSessionManager *manager = [self defaultSessionManager];
    if (isGet) {
        [manager GET:requestURL
          parameters:parameters
             headers:nil
            progress:nil
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (success) {
                success(responseObject);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self handleError:error failure:failure];
        }];
    }else {
        [manager POST:requestURL
           parameters:parameters
              headers:nil
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (success) {
                success(responseObject);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self handleError:error failure:failure];
        }];
    }
}

+ (void)handleError:(NSError *)error failure:(RequestFailure)failure {
    if (failure) {
        NSString *errorMsg = @"未知错误";
        switch (error.code) {
            case -1000:
            case -1002:
                errorMsg = @"非法URL";
                break;
            case -1001:
            case -2000:
                errorMsg = @"连接超时，请稍后重试";
                break;
            case -1003:
            case -1004:
                errorMsg = @"请检查服务器配置";
                break;
            case -1005:
                errorMsg = @"失去连接，请重试";
                break;
            case -1006:
                errorMsg = @"DNS查找失败";
                break;
            case -1007:
                errorMsg = @"HTTP重定向过多";
                break;
            case -1008:
            case -1011:
                errorMsg = @"服务器错误";
                break;
            case -1009:
                errorMsg = @"网络未连接，请检查网络";
                break;
            case -1015:
            case -1016:
            case -1201:
                errorMsg = @"服务器返回异常";
                break;
            default:
                errorMsg = @"未知错误";
                break;
        }
        failure(errorMsg);
    }
}

@end



@implementation LSPlayVideoRequestManager

+ (NSString *)getUrlFromType:(URLType)type {
    switch (type) {
        case URLTypeUser:
            return [BASE_URL stringByAppendingString:@"/player/getVideoSts"];
            break;
            
        default:
            return BASE_URL;
            break;
    }
}

+ (void)getWithParameters:(NSDictionary *)parameters
                  urlType:(URLType)type
                  success:(PVRequestSuccess)success
                  failure:(RequestFailure)failure {
    [self startRequestTypeIsGet:YES
                     parameters:parameters
                        urlType:type
                        success:success
                        failure:failure];
}

+ (void)postWithParameters:(NSDictionary *)parameters
                   urlTypr:(URLType)type
                   success:(PVRequestSuccess)success
                   failure:(RequestFailure)failure {
    [self startRequestTypeIsGet:NO
                     parameters:parameters
                        urlType:type
                        success:success
                        failure:failure];
}

+ (void)startRequestTypeIsGet:(BOOL)isGet
                   parameters:(NSDictionary *)parameters
                      urlType:(URLType)type
                      success:(RequestSuccess)success
                      failure:(RequestFailure)failure {
    NSString *requestURL = [self getUrlFromType:type];
    [self startRequestTypeIsGet:isGet
                     parameters:parameters
                     requestURL:requestURL
                        success:^(id  _Nonnull responseObject) {
        LSResponseModel *model = [[LSResponseModel alloc] initWithDictionary:responseObject error:nil];
        if (model.result) {
            if (success) {
                success(model);
            }
        }else {
            if (failure) {
                failure(model.message);
            }
        }
    } failure:failure];
}

@end




