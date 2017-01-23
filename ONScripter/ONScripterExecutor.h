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
    ONSExecuteScriptError,
    ONSExecuteStillRunning
};

NS_ASSUME_NONNULL_BEGIN

@interface ONSConfiguration : NSObject<NSCopying>

@property (nonatomic) NSString *archivePath;

@property (nonatomic) NSString *savePath;

- (instancetype)initWithArchivePath:(NSString *)archivePath savePath:(NSString *)savePath;

@end

@interface ONScripterExecutor : NSObject

- (instancetype)initWithConfiguration:(ONSConfiguration *)configuration;

- (ONSExecuteErrorCode)exec;

- (void)quit;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
