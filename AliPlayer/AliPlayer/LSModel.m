//
//  LSModel.m
//  AliPlayer
//
//  Created by 石玉龙 on 2021/8/30.
//

#import "LSModel.h"

@implementation LSModel

@end


@implementation LSVideoListModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

- (instancetype)init {
    if (self = [super init]) {
        self.uuid = [NSUUID UUID];
        self.index = 0;
        self.page = 1;
    }
    return self;
}

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{ @"descriptionStr" : @"description" }];
}

@end


@implementation LSResponseModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end

@implementation LSResponseDataModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end
