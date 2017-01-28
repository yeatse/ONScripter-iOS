//
//  ONScripterExecutor.h
//  ONScripter
//
//  Created by Yang Chao on 2017/1/23.
//  Copyright © 2017年 Yang Chao. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT double ONScripterVersionNumber;

FOUNDATION_EXPORT const unsigned char ONScripterVersionString[];

typedef NS_ENUM(NSInteger, ONSExecuteErrorCode) {
    ONSExecuteNoError,
    ONSExecuteInitializationError,
    ONSExecuteCantOpenScript,
    ONSExecuteRuntimeError,
    ONSExecuteStillRunning
};

typedef NS_ENUM(NSInteger, ONScripterEncoding) {
    ONScripterSJISEncoding,
    ONScripterGBKEncoding
};

NS_ASSUME_NONNULL_BEGIN

@interface ONScripterConfiguration : NSObject

@property (nonatomic) NSString *archivePath;
@property (nonatomic) NSString *savePath;
@property (nonatomic) ONScripterEncoding encoding;

- (instancetype)initWithArchivePath:(NSString *)archivePath savePath:(NSString *)savePath encoding:(ONScripterEncoding)encoding;

@end

@interface ONScripterExecutor : NSObject

+ (instancetype)sharedExecutor;

- (ONSExecuteErrorCode)executeWithConfiguration:(ONScripterConfiguration *)configuration;

- (void)quit;

@end

NS_ASSUME_NONNULL_END
