//
//  KJD__SpamCodeGenerator.m
//  OCPlayground
//
//  Created by jacy on 20/04/2018.
//  Copyright © 2018 jacydai. All rights reserved.
//

#import "KJD__SpamCodeGenerator.h"

@interface KJD__SpamCodeGenerator ()

@property (nonatomic, assign) NSInteger spamCodeType;
@end

@implementation KJD__SpamCodeGenerator
+ (NSString *)generateSpamCodeWithType:(KJDInsertSpamCodeType)spamType {

    KJD__SpamCodeGenerator *generator = [[self alloc] initWithSpamCodeType:spamType];

    NSString *spamCodeString = [generator spamCodeStringWithType:spamType];

    return spamCodeString;
}

- (instancetype)initWithSpamCodeType:(KJDInsertSpamCodeType)type {

    if (self = [super init]) {

        _spamCodeType = type;
    }

    return self;
}

- (NSString *)spamCodeStringWithType:(KJDInsertSpamCodeType)spamType {

    NSString *spamCodeStr = nil;
    switch (spamType) {
        case KJDInsertSpamCodeTypeFile_Interface:
        {

            spamCodeStr = [self generateInterfaceSpameCode];
            break;
        }
        case KJDInsertSpamCodeTypeFile_Implement:
        {

            spamCodeStr = [self generateImplementSpamCode];
            break;
        }

        default:
            break;
    }

    return spamCodeStr;
}

- (NSString *)generateInterfaceSpameCode {

    NSArray *baseType = @[
                          @"NSInteger",
                          @"int",
                          @"long",
                          @"long long",
                          @"double",
                          @"NSTimeInterval",
                          @"CGFloat",
                          @"float",
                          @"BOOL",
                          ];
    NSString *strP;
    NSString *varType = [self generatorVaribleType];
    NSString *varName = [self generatorVaribleName];
    NSString *memoryType;
    if ([baseType containsObject:varType]) {

        memoryType = @"assign";
    } else {

        if ([baseType isEqual:@"NSString"]) {
            memoryType = @"copy";
        } else {
            memoryType = @"strong";
        }
    }

    strP = [NSString stringWithFormat:@"\n@property (nonatomic, %@) %@ *%@;\n",memoryType, varType, varName];

    return strP;
}

- (NSString *)generateImplementSpamCode {


    NSString *varType = [self generatorVaribleType];
    NSString *varName = [self generatorVaribleName];
    NSString *methodStr = [NSString stringWithFormat:@"\n %@ *%@;{\nNSString *name = @\"spamddd\";\nif(name){\nNSLog(@\"%@\",name);\n}\n}",varType,varName,self.superclass];
    return methodStr;
}

- (NSString *)methodInnerCode:(NSInteger)type {


    return @"";
}

#pragma mark - 垃圾代码文件

- (NSArray<NSString *> *)basePropertyTypeArray {

    NSArray *array = @[
                       // base type
                       @"NSInteger",
                       @"int",
                       @"long",
                       @"long long",
                       @"double",
                       @"NSTimeInterval",
                       @"CGFloat",
                       @"float",
                       @"BOOL",

                       // Set
                       @"NSArray",
                       @"NSMutableArray",
                       @"NSDictionary",
                       @"NSMutableDictionary",
                       @"NSSet",

                       //
                       @"NSData",
                       @"NSDate",
                       @"NSNumber",
                       @"NSString",

                       // UI
                       @"UIView",
                       @"UILabel",
                       @"UIButton",
                       @"UIImageView",
                       @"UIImage",
                       @"UITextField",
                       @"UITextView",
                       @"UISearchView",
                       @"UISwitch",
                       @"UIControl",
                       @"UIProgressView",
                       ];

    return array;
}

- (NSString *)generatorVaribleType {

    NSArray *type = [self basePropertyTypeArray];
    NSInteger index = arc4random() % type.count;
    NSString *typeStr = [type objectAtIndex:index];

    return typeStr;
}

- (NSString *)generatorVaribleName {

    NSString *var = [self generatorRandomString];

    return var;
}

- (NSString *)generatorRandomString {

    NSInteger len = 26;
    NSString *baseStr = @"abcdefghigklmnopqrstuvwxyzABCDEFGHIGKLMNOPQRSTUVWXYZ0123456789";

    len = len + 2;
    NSMutableString *randomString = [NSMutableString stringWithCapacity:len];
//    [randomString appendString:@"kjd__var_"];// 方案1

    for (NSInteger i = 0; i < len; i++) {

        NSUInteger index = (NSUInteger)arc4random_uniform((uint32_t)baseStr.length);
        [randomString appendFormat: @"%C",[baseStr characterAtIndex:index]];
    }

    // 排除以数字和大写开头的变量
    // 生成字符串的规则，可以考虑使用正则表达式
    // 如果以数字或者大写字母开头
    // 小写字母
    NSString *smallLetters = @"abcdefghigklmnopqrstuvwxyz";
    char headerChar = [randomString characterAtIndex:0];
    BOOL validHeaderStr = [self pureBigLetter:headerChar] || [self pureNumber:headerChar];
    if (validHeaderStr) {
        NSMutableString *replaceStr = [NSMutableString string];
        NSUInteger replaceIndex = (NSUInteger)arc4random_uniform((uint32_t)smallLetters.length);
        [replaceStr appendFormat: @"%C",[smallLetters characterAtIndex:replaceIndex]];
        [randomString replaceCharactersInRange:NSMakeRange(0, 1) withString:replaceStr];
    }

    return randomString;
}

- (BOOL)pureBigLetter:(char)letter {

    // ASSIC A~Z (65 ~90)
    if (letter > 64 && letter < 91 ) {
        return YES;
    }
    return NO;
}

- (BOOL)pureNumber:(char)letter {

    // ASSIC 0~9(48~57)
    if (letter > 47 && letter < 58) {

        return YES;
    }

    return NO;
}

- (NSString *)generateReplaceHeaderInvalideStr:(NSString *)inputStr {

    NSString *smallLetters = @"abcdefghigklmnopqrstuvwxyz";
    NSMutableString *replaceStr = [NSMutableString string];


    NSUInteger replaceIndex = (NSUInteger)arc4random_uniform((uint32_t)smallLetters.length);
    [replaceStr appendFormat: @"%C",[smallLetters characterAtIndex:replaceIndex]];

    return replaceStr;
}

@end
