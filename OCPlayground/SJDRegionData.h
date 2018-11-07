//
//  SJDRegionData.h
//  OCPlayground
//
//  Created by daixingsi on 2018/11/6.
//  Copyright © 2018 jacydai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJDRegionData : NSObject

// 行政省市 数据
@property (nonatomic, strong) NSDictionary <NSString *, NSArray *>       *provinceData;

// 市区数据
@property (nonatomic, strong) NSDictionary <NSString *, NSArray *>       *cityData;

@end

NS_ASSUME_NONNULL_END
