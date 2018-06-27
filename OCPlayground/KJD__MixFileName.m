//
//  KJD__MixFileName.m
//  OCPlayground
//
//  Created by jacy on 22/05/2018.
//  Copyright © 2018 jacydai. All rights reserved.
//

#import "KJD__MixFileName.h"


static NSString *kOriginalNameLog = @"FileNameLog_Original.plist";
static NSString *kRevertedNameLog = @"FileNameLog_Reverted.plist";

@interface KJD__MixFileName ()

// 文件路径
@property (nonatomic, copy) NSString         *filePath;
@property (nonatomic, strong) NSFileManager  *fileManager;

// 当前文件路径
@property (nonatomic, copy) NSString         *currentFilePath;

//
@property (nonatomic, assign) BOOL            restore;

@end

@implementation KJD__MixFileName


+ (void)mixFileName:(NSString *)fileDirectory restore:(BOOL)restore {

    KJD__MixFileName *fileName = [[KJD__MixFileName alloc] init];
    fileName.filePath = fileDirectory;
    fileName.currentFilePath = nil;
    fileName.restore = restore;
    fileName.fileManager = [NSFileManager defaultManager];

    [fileName findValidateFile];
}

#pragma mark - 查找文件名称
- (void)findValidateFile {

    // 判断本地是否有RevertFileLog 文件
    if (self.restore) {
        [self createLocalRevertedFileLog];
    }

    // 匹配本地文件
    [self matchLocalFile:self.filePath];

    // 删除混淆后生成的冗余文件
    [self deleteUnusedFiles:self.filePath];
}

// 当前文件夹
- (void)matchLocalFile:(NSString *)path {

    NSError *error;
    NSArray *files = [self.fileManager contentsOfDirectoryAtPath:path error:&error];
    if (error) {
        NSLog(@"\n\nOpen File Error:%@\n\n",error);
        return;
    }
    
    // 遍历文件
    for (NSString *file in files) {
        // 文件路径
        NSString *filePath = [path stringByAppendingPathComponent:file];
        // 文件夹
        BOOL directory = [self currentFileIsDirectory:filePath];
        BOOL ignoreDir = [self ignoreFile:file];
        if (directory && ignoreDir) {
            continue;
        }

        if (!directory) {
            BOOL replaceFileName = [self needReplaceFileName:file filePath:filePath];
            if (replaceFileName) {
                self.currentFilePath = nil;
                // 匹配文件名称和内容
                [self replaceCurrentFileName:file filePath:filePath];
            }
        } else {
            // 文件夹，递归遍历
            [self matchLocalFile:filePath];
        }
    }
}

// 替换文件名称
- (void)replaceCurrentFileName:(NSString *)file filePath:(NSString *)filePath {

    BOOL hTypeFile = [filePath.pathExtension isEqualToString:@"h"];
    if (!hTypeFile) {
        return;
    }

    NSString *oldFileName = file;
    NSString *newFileName;

    // 生成新名字，需要对已生成过的文件做过滤
    BOOL needReplacName = [self needReplaceFile:file];
    // 加密
    if (needReplacName && !self.restore) {
        NSString *logFileName = [self findSavedLogFileName:oldFileName];
        BOOL fileType = [logFileName containsString:@"KJD"] && (![logFileName containsString:@"KJD__"]);
        if (logFileName.length > 0 && fileType) {
            newFileName = logFileName;
        } else {
            // 本地找不到，则生成新的混淆串
            newFileName = [self returnMixFileName:file];
        }

    } else if (self.restore) {
        // 还原
        NSString *logFileName = [self findSavedLogFileName:oldFileName];
        BOOL fileType = ([logFileName containsString:@"KJD__"]);
        if (logFileName.length > 0 &&fileType) {

            newFileName = logFileName;
        } else {
            //  还原找不到文件，直接返回
            return;
        }
    } else {
        // 其他，直接返回
        return;
    }

    // 修改文件名称 对修改过的文件名，不能重新命名
    NSString *oldFilePath = filePath;
    if (hTypeFile && oldFileName != newFileName) {

        NSString *newFilePath = [filePath stringByReplacingOccurrencesOfString:oldFileName withString:newFileName];
        NSString *hNewPath = [NSString stringWithFormat:@"%@.%@",newFilePath,oldFilePath.pathExtension];

        NSString *mOldPath = [oldFilePath stringByReplacingOccurrencesOfString:@".h" withString:@".m"];
        NSString *mNewFilePath = [newFilePath stringByReplacingOccurrencesOfString:@".h" withString:@".m"];
        NSString *mNewPath = [NSString stringWithFormat:@"%@.%@",mNewFilePath,mOldPath.pathExtension];

        // 对.m .h 文件重命名
        [self reNameCurrentFileName:oldFilePath newFileName:hNewPath];
        [self reNameCurrentFileName:mOldPath newFileName:mNewPath];

        NSString *oldName = [self fileNameRemoveFileExtension:oldFileName];
        NSString *newName = [self fileNameRemoveFileExtension:newFileName];
        // 保存本地记录
        [self saveFileNameLog:oldName newFileName:newName]; // 记录替换日志
        // 全局查找
        [self globalReplaceFileContentOldFileName:oldName newFileName:newName];
    }
}

// 全局替换文件名称
- (void)globalReplaceFileContentOldFileName:(NSString *)oldFileName newFileName:(NSString *)newFileName {

    NSError *error;
    NSString *path = self.currentFilePath ? self.currentFilePath : self.filePath;
    NSArray *files = [self.fileManager contentsOfDirectoryAtPath:path error:&error];
    // 遍历文件
    for (NSString *fileName in files) {

        // 文件路径
        NSString *filePath = [path stringByAppendingPathComponent:fileName];
        // 文件夹
        BOOL directory = [self currentFileIsDirectory:filePath];
        BOOL ignoreDir =[self ignoreFile:fileName];
        if (directory && ignoreDir) {
            continue;
        }
        if (directory) {
            self.currentFilePath = filePath;
            [self globalReplaceFileContentOldFileName:oldFileName newFileName:newFileName];
        } else {

            NSString *fileExtentsion = filePath.pathExtension;
            if ([fileExtentsion isEqualToString:@"pbxproj"]) {

                NSLog(@"pbxproj %@",fileName);
            }
            BOOL fileType = [fileExtentsion isEqualToString:@"h"] || [fileExtentsion isEqualToString:@"m"] || [fileExtentsion isEqualToString:@"pbxproj"];
            if (fileType) {

                NSError *error = nil;
                NSMutableString *contentString = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
                if (error) {

                    NSLog(@"\n================================\n error %@\n================================\n",error);
                }

                if ([contentString containsString:oldFileName]) {


                    NSLog(@"\n++++++++ \n fileName: %@ \n oldName:%@  \nnewName:%@\n +++++++++\n\n",fileName,oldFileName,newFileName);

                    NSRange range = NSMakeRange(0, contentString.length);
                    NSInteger count = [contentString replaceOccurrencesOfString:oldFileName withString:newFileName options:NSCaseInsensitiveSearch range:range];

                    NSError *error2 = nil;
                    [contentString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error2];
                    if (error2) {

                        NSLog(@"\n================================\n write error %@\n================================\n",error);
                    }
                }
            }
        }
    }
}

- (void)deleteUnusedFiles:(NSString *)filePath {

    NSError *error;
    NSArray *files = [self.fileManager contentsOfDirectoryAtPath:filePath error:&error];

    for (NSString *fileName in files) {
        // 文件路径
        NSString *path = [filePath stringByAppendingPathComponent:fileName];
        // 文件夹
        BOOL directory = [self currentFileIsDirectory:filePath];
        if (directory && [self ignoreFile:fileName]) {
            continue;
        }
        if (!directory) {

            BOOL hasReferenc = [self globalFindFile:fileName filePath:self.filePath];
            if (!hasReferenc) {
                NSString *hPath = path;
                NSString *mPath = [hPath stringByReplacingOccurrencesOfString:@".h" withString:@".m"];
                [self.fileManager removeItemAtPath:hPath error:nil];
                [self.fileManager removeItemAtPath:mPath error:nil];
            }

        } else {

            [self deleteUnusedFiles:path];
        }
    }
}

- (BOOL)globalFindFile:(NSString *)fileName filePath:(NSString *)filePath {

    NSError *error;
    NSArray *files = [self.fileManager contentsOfDirectoryAtPath:filePath error:&error];

    BOOL reference = NO;
    // 遍历文件
    for (NSString *file in files) {

        // 文件路径
        NSString *path = [filePath stringByAppendingPathComponent:file];
        // 文件夹
        BOOL directory = [self currentFileIsDirectory:path];
        BOOL ignoreDir =[self ignoreFile:file];
        if (directory && ignoreDir) {
            continue;
        }
        if (directory) {

            [self globalFindFile:fileName filePath:path];
        } else {

            NSString *fileExtentsion = filePath.pathExtension;
            BOOL fileType = [fileExtentsion isEqualToString:@"h"]|| [fileExtentsion isEqualToString:@"m"];
            if (fileType) {
                NSError *error = nil;
                NSMutableString *contentString = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];

                // 已经被引用
                if ([contentString containsString:fileName]) {

                    reference = YES;
                    break;
                }
            }
        }
    }

    return reference;
}


#pragma mark - 写入文件

// 重命名文件
- (void)reNameCurrentFileName:(NSString *)oldPath newFileName:(NSString *)newPath {

    NSError *error;
    [self.fileManager moveItemAtPath:oldPath toPath:newPath error:&error];
    if (error) {

        NSLog(@"\n================================\n \n【【【【 reName】】】】error %@\n\n================================\n",error);
    }
}

- (void)saveFileNameLog:(NSString *)fileName newFileName:(NSString *)newFileName {

    NSString *path;
    if (self.restore) {

        path = [self.filePath stringByAppendingPathComponent:kRevertedNameLog];
    } else {

        path = [self.filePath stringByAppendingPathComponent:kOriginalNameLog];
    }

    NSArray *savedArray = [NSArray arrayWithContentsOfFile:path];

    NSMutableArray *namesArray = [NSMutableArray array];
    [namesArray addObjectsFromArray:savedArray];

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString *fileNameStr = [self fileNameRemoveFileExtension:fileName];
    dict[fileNameStr] = newFileName;

    BOOL existObj = [namesArray containsObject:dict];

    // 如果不存在该文件，则直接插入
    if (!existObj) {
        [namesArray addObject:dict];
        [namesArray writeToFile:path atomically:YES];
    }
}

- (NSString *)findSavedLogFileName:(NSString *)fileName {

    NSString *path;
    if (self.restore) {

        path = [self.filePath stringByAppendingPathComponent:kRevertedNameLog];
    } else {

        path = [self.filePath stringByAppendingPathComponent:kOriginalNameLog];
    }

    NSString *innerName = [self fileNameRemoveFileExtension:fileName];
    NSArray *currentSavedArray = [NSArray arrayWithContentsOfFile:path];
    NSMutableArray *namesArray = [NSMutableArray array];
    [namesArray addObjectsFromArray:currentSavedArray];

    if (innerName.length <=0) {
        return nil;
    }

    NSString *oldFileName;
    for (NSDictionary *dict in namesArray) {
        NSArray *allKeys = dict.allKeys;
        NSString *key = allKeys[0];
        if ([innerName containsString:key]) {

            oldFileName = dict[key];
            break;
        }
    }

    NSString *oldName = [self fileNameRemoveFileExtension:oldFileName];
    return oldName;
}


- (NSString *)fileNameRemoveFileExtension:(NSString *)fileName {

    if (fileName.length <= 0) {
        return nil;
    }
    NSMutableString *name = [NSMutableString stringWithString:fileName];

    NSString *validStr;
    if ([fileName hasSuffix:@".m"]) {

        validStr =  [name stringByReplacingOccurrencesOfString:@".m" withString:@""];
    } else if ([fileName hasSuffix:@".h"]) {

        validStr =  [name stringByReplacingOccurrencesOfString:@".h" withString:@""];
    } else {
        validStr = fileName;
    }

    return validStr;
}

// 对本地的log表先做一次值的替换
- (void)createLocalRevertedFileLog {

    [self revertFileNameLog];
}

- (void)revertFileNameLog {

    NSString *revertPath = [self.filePath stringByAppendingPathComponent:kRevertedNameLog];
    NSArray *revertArray = [NSArray arrayWithContentsOfFile:revertPath];
    NSMutableArray *revertNamesArray = [NSMutableArray array];
    [revertNamesArray addObjectsFromArray:revertArray];

    NSString *path = [self.filePath stringByAppendingPathComponent:kOriginalNameLog];
    NSArray *originalArray = [NSArray arrayWithContentsOfFile:path];
    NSMutableArray *namesArray = [NSMutableArray array];
    [namesArray addObjectsFromArray:originalArray];

    for (NSDictionary *originalDict in namesArray) {

        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        // 考虑到此处只有一个key，对应一个value
        NSArray *allKeys = originalDict.allKeys;
        NSArray *allValues = originalDict.allValues;
        NSString *key = allKeys[0];
        NSString *vlaue = allValues[0];
        if ([vlaue isKindOfClass:[NSString class]] && [vlaue isKindOfClass:[NSString class]]) {

            dict[vlaue] = key;

            BOOL existObj = [revertNamesArray containsObject:dict];

            // 如果不存在该文件，则直接插入
            if (!existObj) {
                [revertNamesArray addObject:dict];
            }
        }
    }

    [revertNamesArray writeToFile:revertPath atomically:YES];
}

#pragma mark - 替换文件名称的条件

- (BOOL)needReplaceFile:(NSString *)file {

    BOOL needReplace = NO;
    if ([file containsString:@"__VC"]) {
        // VC

        needReplace = YES;
    } else if ([file containsString: @"__Model"]) {
        // Model
        needReplace = YES;
    } else if ([file containsString:@"__VM"]) {

        // VM
        needReplace = YES;
    } else if ([file containsString:@"__View"]) {
        // View
        needReplace = YES;
    } else if ([file containsString:@"__Cell"]) {
        // cell
        needReplace = YES;
    } else if ([file containsString:@"__Btn"]) {
        // btn
        needReplace = YES;
    } else if ([file containsString:@"__Service"]) {
        // Service
        needReplace = YES;
    } else if ([file containsString:@"__TF"]) {

        needReplace = YES;
    } else {

        needReplace = NO;
    }

    return needReplace;
}

// 生成对应的文件名称
- (NSString *)returnMixFileName:(NSString *)file {

    NSString *tail = @"";
    if ([file containsString:@"__VC"]) {
        // VC

        tail = @"Controller";
    } else if ([file containsString: @"__Model"]) {
        // Model
        tail = @"Model";

    } else if ([file containsString:@"__VM"]) {

        // VM
        tail = @"ViewModel";
    } else if ([file containsString:@"__View"]) {
        // View
        tail = @"View";
    } else if ([file containsString:@"__Cell"]) {
        // cell
        tail = @"Cell";
    } else if ([file containsString:@"__Btn"]) {
        // btn
        tail = @"Btn";
    } else if ([file containsString:@"__Service"]) {
        // Service
        tail = @"Service";
    } else if ([file containsString:@"__TF"]) {

        tail = @"View";
    }

    NSMutableString *newName = [NSMutableString string];
    [newName appendString:[self generatorRandomString]];
    [newName appendString:tail];

    return [newName copy];
}

// 替换文件名称
- (BOOL)needReplaceFileName:(NSString *)file filePath:(NSString *)filePath {

    NSString *fileExtentsion = filePath.pathExtension;
    BOOL fileType = [fileExtentsion isEqualToString:@"h"] || [fileExtentsion isEqualToString:@"m"];

    BOOL markFile = NO;
    if (self.restore) {

        markFile = (![file containsString:@"KJD__"]) && [file hasPrefix:@"KJD"];
    } else {
        markFile = [file containsString:@"KJD__"];
    }

    return fileType && markFile;
}

- (BOOL)ignoreFile:(NSString *)file {

    NSArray *ignoreDir = @[
                           @"Tests",
                           @"Pods",
                           @"Podifle",
                           @".xcworkspace",
                           @"Lib",
                           @"Resource",
                           @"Vendor",
                           @"Util",
                           @".xcassets",
                           @".git"
                           ];

    BOOL ignore = [ignoreDir containsObject:file];


    return ignore;
}

// 当前文件是否是文件夹
- (BOOL)currentFileIsDirectory:(NSString *)currentFile {

    NSError *error;
    NSArray *fileList = [self.fileManager contentsOfDirectoryAtPath:currentFile error:&error];

    // 当前文件为文件夹
    if (fileList.count > 1) {

        return YES;
    } else {

        return NO;
    }
}

#pragma mark - 生成随机字符串

- (NSString *)generatorRandomString {

    NSInteger len = 26;
    NSString *baseStr = @"abcdefghigklmnopqrstuvwxyzABCDEFGHIGKLMNOPQRSTUVWXYZ0123456789";

    len = len + 2;
    NSMutableString *randomString = [NSMutableString stringWithCapacity:len];
        [randomString appendString:@"KJD"];// 方案1

    for (NSInteger i = 0; i < len; i++) {

        NSUInteger index = (NSUInteger)arc4random_uniform((uint32_t)baseStr.length);
        [randomString appendFormat: @"%C",[baseStr characterAtIndex:index]];
    }

    return randomString;
}


@end
