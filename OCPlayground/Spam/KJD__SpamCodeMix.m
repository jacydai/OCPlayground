//
//  KJD__SpamCodeMix.m
//  OCPlayground
//
//  Created by jacy on 20/04/2018.
//  Copyright © 2018 jacydai. All rights reserved.
//

#import "KJD__SpamCodeMix.h"
#import "KJD__SpamCodeGenerator.h"

@interface KJD__SpamCodeMix ()

@property (nonatomic, copy)   NSString                   *filePath;
@property (nonatomic, strong) NSFileManager              *fileManager;

//
@property (nonatomic, strong) NSMutableArray <NSNumber *>            *interfaceIndexArray;

@property (nonatomic, strong) NSMutableArray <NSNumber *>            *implementIndexArray;

@property (nonatomic, strong) NSMutableArray <NSString *>            *rawFileStrArray;

@property (nonatomic, strong) NSMutableArray <NSString *>            *modifyFileStrArray;

@property (nonatomic, strong) NSMutableArray <NSString *>            *methodRangeArray;

- (BOOL)stringIsMethodStart:(NSString *)line;
- (BOOL)fileExtensionIsValidate:(NSString *)filePath;

@end

@implementation KJD__SpamCodeMix

- (instancetype)initWithPath:(NSString *)path {

    if (self = [super init]) {
        _fileManager = [NSFileManager defaultManager];
        _filePath = path;
        _interfaceIndexArray = [NSMutableArray array];
        _implementIndexArray = [NSMutableArray array];
        _rawFileStrArray = [NSMutableArray array];
        _modifyFileStrArray = [NSMutableArray array];
        _methodRangeArray = [NSMutableArray array];
    }

    return self;
}

+ (void)addSpamCodeToFile:(NSString *)path {

    KJD__SpamCodeMix *spamCodeMix = [[self alloc] initWithPath:path];

    [spamCodeMix mixLocalFile];
}

- (void)mixLocalFile {

    [self matchLocalFile:self.filePath];
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

// 当前文件夹
- (void)matchLocalFile:(NSString *)path {

    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];

    // 遍历文件
    for (NSString *file in files) {

        // 0. 过滤文件

        // 文件路径
        NSString *filePath = [path stringByAppendingPathComponent:file];
        // 文件夹
        BOOL directory = [self currentFileIsDirectory:filePath];
        if (!directory) {

            // 添加垃圾代码
            [self insertSpamcode:filePath];

        } else {

            // 文件夹，递归遍历
            [self matchLocalFile:filePath];
        }
    }
}

// 扫描文件
- (void)scanFileWithPath:(NSString *)filePath {

    // 0. 异常处理
    if (![self fileExtensionIsValidate:filePath]) {
        NSLog(@"=======\n\nfilePath:%@ \nfileExtension:%@ \n\n ",filePath,filePath.pathExtension);
        return;
    }

    // 1. 文件字符串
    NSError *error;
    NSMutableString *dataString = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {

        NSLog(@"=======\n\nmethod:%@ \nerror:%@ \n\n ",NSStringFromSelector(_cmd),error);
        return;
    }

    // 3. 文件字符串数组
    [self clearLocalCacheData];

    self.rawFileStrArray = [[dataString componentsSeparatedByString:@"\n"] mutableCopy];
//    self.modifyFileStrArray = [self.rawFileStrArray mutableCopy];

    // 3. 扫描文件
    for (int i = 0; i < self.rawFileStrArray.count; ++i) {

        // 1. interface 插入属性 备注： 不能添加到成员变量声明 {}块中
        NSString *line = self.rawFileStrArray[i];
        if ([line hasPrefix:@"@interface"]) {
            [self.interfaceIndexArray addObject:@(i)];
        }

        if (self.implementIndexArray.count == 0&&self.interfaceIndexArray.count > 0 && [line hasPrefix:@"@end"]) {

            [self.interfaceIndexArray addObject:@(i)];
        }

        // 2. implementation 插入代码块 备注：a.注意代码{}出入到方法的开头，导致方法截断 b. 注意插入的位置为方法体之外 c.对于条件和循环语句的截断问题
        if ([line hasPrefix:@"@implementation"]) {

             [self.implementIndexArray addObject:@(i)];
        }

        if (self.implementIndexArray.count > 0 && [line hasPrefix:@"@end"]) {

            [self.implementIndexArray addObject:@(i)];
        }
    }
}

// 文件中插入垃圾代码
- (void)insertSpamcode:(NSString *)filePath {
    [self scanFileWithPath:filePath];
    [self insertSpamCodeToFile:filePath];
    [self writeSpamCodeToLocalFile:filePath];
}

- (void)insertSpamCodeToFile:(NSString *)filePath {

    for (int i = 0; i < self.rawFileStrArray.count; ++i) {

        NSString *line = self.rawFileStrArray[i];

        if ([self currentLineInInterface:i]) {

            NSString *interCode = [KJD__SpamCodeGenerator generateSpamCodeWithType:KJDInsertSpamCodeTypeFile_Interface];
            [self.modifyFileStrArray addObject:interCode];
        }

        if ([self currentLineInImplementation:i]) {

            // TODO: 随机插入代码片段

            [self currentLineInMethod:i];

            if (self.methodRangeArray) {

                NSInteger methodStart = self.methodRangeArray.firstObject.integerValue;
                NSInteger mehtodEnd   = self.methodRangeArray.lastObject.integerValue;

                if (i > methodStart && i < mehtodEnd) {

                    NSInteger randamIndex = (NSInteger)arc4random_uniform((uint32_t)(mehtodEnd - methodStart));

                    if (randamIndex == 2 || randamIndex == 5 || randamIndex == 3 || randamIndex == 7) {
                        // 只能插入到方法内部
                        NSString *impCode = [KJD__SpamCodeGenerator generateSpamCodeWithType:KJDInsertSpamCodeTypeFile_Implement];
                        [self.modifyFileStrArray addObject:impCode];
                    }
                }
            }

        }

        [self.modifyFileStrArray addObject:line];
    }
}

- (BOOL)currentLineInInterface:(NSInteger)lineNum {

    // 正常的 数组应该是2的整数倍，有一个@interface ,对应有一个@end
    NSInteger valideCount = self.interfaceIndexArray.count % 2;
    if (self.interfaceIndexArray.count < 2) {
        return NO;
    }

    if (valideCount != 0) {

        return NO;
    }

    NSInteger start;
    NSInteger end;
    start = self.interfaceIndexArray[0].intValue;
    end = self.interfaceIndexArray[1].intValue;

    if (lineNum > start && lineNum < end) {

        return YES;
    }

    return NO;
}

- (BOOL)currentLineInImplementation:(NSInteger)lineNum {

    if (self.implementIndexArray.count < 2) {
        return NO;
    }

    NSInteger start;
    NSInteger end;
    start = self.implementIndexArray[0].intValue;
    end = self.implementIndexArray[1].intValue;

    if (lineNum > start && lineNum < end) {

        return YES;
    }

    return NO;
}

- (void)currentLineInMethod:(NSInteger)lineNum {


    if (self.methodRangeArray.count) {

        if (lineNum >= self.methodRangeArray.firstObject.integerValue && lineNum <= self.methodRangeArray.lastObject.integerValue) {

            return;
        }

    }

    [self.methodRangeArray removeAllObjects];
    for (NSInteger i = lineNum; i < self.rawFileStrArray.count; ++i) {
        // 找出函数开始
        NSString *currentLine = self.rawFileStrArray[i];

        // 注释和空行不做判断
        if ([currentLine hasPrefix:@"// "] || [currentLine hasPrefix:@"//"] || currentLine.length == 0) {
            continue;
        }
        BOOL methodStart = [self stringIsMethodStart:currentLine];

        // 方法开始
        if (methodStart && self.methodRangeArray.count < 1) {

            NSInteger nextLine = i + 1;
            BOOL innerStart = NO;
            if (nextLine < self.rawFileStrArray.count && ![currentLine hasSuffix:@"{"]) {
                NSString *nextLineStr = self.rawFileStrArray[nextLine];


                innerStart = [nextLineStr hasPrefix:@"{"];
            }

            if (innerStart) {
                [self.methodRangeArray addObject:@(nextLine).stringValue];
            } else {
                [self.methodRangeArray addObject:@(i).stringValue];
            }
        }

        // 方法结束
        if (methodStart && self.methodRangeArray.count == 1) {

            // 向上寻找方法结束标记
            for (NSInteger nextMethodStart = i; nextMethodStart > lineNum; --nextMethodStart) {

                NSString *lastLine = self.rawFileStrArray[nextMethodStart];
                if ([lastLine hasPrefix:@"}"] && nextMethodStart > self.methodRangeArray.firstObject.intValue) {
                    [self.methodRangeArray addObject:@(nextMethodStart).stringValue];
                }
            }
        }

        // 找到一个方法，结束查找
        if (self.methodRangeArray.count == 2) {
            break;
        }
    }
}

// 修改结果写入到文件
- (void)writeSpamCodeToLocalFile:(NSString *)filePath {

    NSString *modifyContentStr = [self.modifyFileStrArray componentsJoinedByString:@"\n"];

    NSError *error;
    [modifyContentStr writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    [self clearLocalCacheData];
    if (error) {

        NSLog(@"\n\n file:%@ \n write error:%@\n\n",filePath,error);
    }
}

- (void)clearLocalCacheData {
    [self.rawFileStrArray removeAllObjects];
    [self.modifyFileStrArray removeAllObjects];
    [self.interfaceIndexArray removeAllObjects];
    [self.implementIndexArray removeAllObjects];
}

#pragma mark - 匹配当前文件的类型

- (BOOL)stringIsMethodStart:(NSString *)line {

    return [line hasPrefix:@"- ("] || [line hasPrefix:@"-("] ||[line hasPrefix:@"+ ("]||[line hasPrefix:@"+("];
}

- (BOOL)fileExtensionIsValidate:(NSString *)filePath {

//    NSArray *fileExtensions = @[@"m",@"h",@"swift"];
    NSArray *fileExtensions = @[@"m",@"h"];
    BOOL validateExtensiion = [fileExtensions containsObject:filePath.pathExtension];

    return validateExtensiion;
}

@end




