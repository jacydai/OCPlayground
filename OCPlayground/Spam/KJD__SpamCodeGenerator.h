//
//  KJD__SpamCodeGenerator.h
//  OCPlayground
//
//  Created by jacy on 20/04/2018.
//  Copyright © 2018 jacydai. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 插入冗余代码的位置

 - KJDInsertSpamCodeTypeFile_Interface: .h 中的interface 中插入先关代码
 - KJDInsertSpamCodeTypeFile_Implement: .m 中实现的方法中插入相关代码
 */
typedef NS_ENUM(NSInteger, KJDInsertSpamCodeType) {

    KJDInsertSpamCodeTypeFile_Interface = 1, // 默认为1
    KJDInsertSpamCodeTypeFile_Implement,

};

@interface KJD__SpamCodeGenerator : NSObject


+ (NSString *)generateSpamCodeWithType:(KJDInsertSpamCodeType)spamType;

@end
