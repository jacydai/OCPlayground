//
//  KJD__MixFileName.h
//  OCPlayground
//
//  Created by jacy on 22/05/2018.
//  Copyright © 2018 jacydai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KJD__MixFileName : NSObject


/**
 混淆文件名

 @param fileDirectory 需要混淆的文件夹
 @param restore       是否是从混淆后的文件还原 默认为0
 */
+ (void)mixFileName:(NSString *)fileDirectory restore:(BOOL)restore;

@end
