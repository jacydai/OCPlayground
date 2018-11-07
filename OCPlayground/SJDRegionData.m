//
//  SJDRegionData.m
//  OCPlayground
//
//  Created by daixingsi on 2018/11/6.
//  Copyright © 2018 jacydai. All rights reserved.
//

#import "SJDRegionData.h"

@interface SJDRegionData () <NSXMLParserDelegate>

@property (nonatomic, strong) NSMutableArray          *innerCityArray;
@property (nonatomic, strong) NSMutableArray          *districtNameArray;
@property (nonatomic, strong) NSMutableDictionary     *provinceDict;
@property (nonatomic, strong) NSMutableDictionary     *cityDict;

@property (nonatomic, strong) NSMutableArray          *provinceNameArray;
@property (nonatomic, strong) NSMutableArray          *cityNameArray;
@property (nonatomic, strong) NSMutableArray          *districtArray;

@property (nonatomic, strong) NSMutableArray          *xmlTagStack;
@end

@implementation SJDRegionData

- (instancetype)init {

    if (self = [super init]) {
        [self parseXMLFile];
    }

    return self;
}

- (void)parseXMLFile {

    [self setupSets];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"province_data" ofType:@"xml"];
    NSData *xmlData = [NSData dataWithContentsOfFile:path];
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:xmlData];
    xmlParser.delegate = self;
    [xmlParser parse];
}

- (void)setupSets {

    self.provinceDict = [NSMutableDictionary dictionary];
    self.cityDict = [NSMutableDictionary dictionary];
    self.innerCityArray = [NSMutableArray array];
    self.districtNameArray = [NSMutableArray array];

    self.provinceNameArray = [NSMutableArray array];
    self.cityNameArray     = [NSMutableArray array];
    self.districtArray     = [NSMutableArray array];
    self.xmlTagStack = [NSMutableArray array];
}

#pragma mark - XMLParser Delegate
// Document handling methods
- (void)parserDidStartDocument:(NSXMLParser *)parser {


    NSLog(@"--开始解析----xml %@", parser);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSDictionary<NSString *, NSString *> *)attributeDict {

    [self parserXMLDataElementName:elementName attributes:attributeDict];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName {

    NSArray *endTagNames = @[@"root", @"province", @"city", @"district"];
    if ([endTagNames containsObject:elementName]) {
        // 1. Pop
        [self xmlTagStackPop:elementName];
        // 2. 操作数据
        [self operationData];
    }
}

// sent when the parser begins parsing of the document.
- (void)parserDidEndDocument:(NSXMLParser *)parser {

    NSLog(@"--完成解析----xml %@",parser);

    self.provinceData = self.provinceDict;
    self.cityData     = self.cityDict;
}

#pragma mark - 解析数据相关方法

- (void)parserXMLDataElementName:(NSString *)elementName attributes:(NSDictionary<NSString *, NSString *> *)attributeDict {

    NSArray *endTagNames = @[@"root", @"province", @"city", @"district"];
    if (![endTagNames containsObject:elementName]) {
        return;
    }

    NSString *name = attributeDict[@"name"];
    if ([elementName isEqualToString:@"province"]) {

        [self.provinceNameArray addObject:name];
    }
    if ([elementName isEqualToString:@"city"]) {

        [self.cityNameArray addObject:name];
    }
    if ([elementName isEqualToString:@"district"]) {

        [self.districtNameArray addObject:name];
    }

    // Push
    [self xmlTagStackPush:elementName];
}

- (void)operationData {

    if ([self.xmlTagStack.lastObject isEqualToString:@"root"]) {

        if (self.provinceNameArray.count) {

            NSString *province = self.provinceNameArray.lastObject;
            self.provinceDict[province] = [self.innerCityArray mutableCopy];

            [self.innerCityArray removeAllObjects];
            [self.provinceNameArray removeLastObject];
            return;
        }
    }
    if ([self.xmlTagStack.lastObject isEqualToString:@"province"]) {

        if (self.cityNameArray.count) {

            NSString *city = self.cityNameArray.lastObject;
            [self.innerCityArray addObject:city];
            self.cityDict[city] = [self.districtArray mutableCopy];

            [self.districtArray removeAllObjects];
            [self.cityNameArray removeAllObjects];
            return;
        }
    }

    if ([self.xmlTagStack.lastObject isEqualToString:@"city"]) {

        NSString *district = self.districtNameArray.lastObject;
        [self.districtArray addObject:district?:@""];
        [self.districtNameArray removeLastObject];
    }
}


- (void)xmlTagStackPush:(NSString *) elementName {

    if (!self.xmlTagStack) {
        return;
    }
    [self.xmlTagStack addObject:elementName];
}

- (void)xmlTagStackPop:(NSString *)elementName {

    if (!self.xmlTagStack) {
        return;
    }

    if ([self.xmlTagStack.lastObject isEqualToString:elementName]) {

        [self.xmlTagStack removeLastObject];
    }
}

@end
