//
//  ViewController.m
//  OCPlayground
//
//  Created by jacydai on 18/04/2018.
//  Copyright © 2018 jacydai. All rights reserved.
//

#import "ViewController.h"
#import "KJD__SpamCodeMix.h"
#import "KJD__MixFileName.h"
#import "SJDRegionData.h"

@interface ViewController () <UIPickerViewDelegate,UIPickerViewDataSource,NSXMLParserDelegate>

@property (nonatomic, strong) UIView      *floatView;
@property (nonatomic, strong) UIButton    *skipBtn;

@property (nonatomic, strong) UIPickerView            *provinceView;
@property (nonatomic, strong) NSDictionary            *provinceDict;
@property (nonatomic, strong) NSDictionary            *cityDict;

@property (nonatomic, copy) NSString                  *selectedProvince;
@property (nonatomic, copy) NSString                  *selectedCity;
@property (nonatomic, copy) NSString                  *selecDistrt;

@property (nonatomic, copy) NSArray                   *selecCity;
@property (nonatomic, copy) NSArray                   *selecDistrict;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *filePath = @"/Users/xxx/temp/note2";
//    [KJD__MixFileName mixFileName:filePath restore:YES];
    SJDRegionData *provinceData = [[SJDRegionData alloc] init];
    self.provinceDict = provinceData.provinceData;
    self.cityDict     = provinceData.cityData;
    [self setupPickerView];

//    [self parseXMLFile];
}

- (NSString *)generatorRandomString {

    NSInteger len = 6;
    NSString *baseStr = @"abcdefghigklmnopqrstuvwxyzABCDEFGHIGKLMNOPQRSTUVWXYZ0123456789";

    len =((arc4random() % 36) + 6);

    NSLog(@"\n\n=======%ld=======",len);

    NSMutableString *randomString = [NSMutableString stringWithCapacity:len];
    [randomString appendString:@"KJD"];// 方案1

    for (NSInteger i = 0; i < len; i++) {

        NSUInteger index = (NSUInteger)arc4random_uniform((uint32_t)baseStr.length);
        [randomString appendFormat: @"%C",[baseStr characterAtIndex:index]];
    }

    return randomString;
}
- (void)clickTheView {

    NSLog(@"111111111111");
}


- (void)skipBtnClicked {

    NSLog(@"2222222222");
}

- (void)setupUI {

    self.floatView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 500)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTheView)];
    self.floatView.backgroundColor = [UIColor magentaColor];

    [self.floatView addGestureRecognizer:tap];

    self.skipBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, 100, 50)];
    [self.skipBtn setTitle:@"Skip" forState:UIControlStateNormal];
    [self.skipBtn addTarget:self action:@selector(skipBtnClicked) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.floatView];
    [self.floatView addSubview:self.skipBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Picker View
- (void)setupPickerView {

    self.provinceView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 300, self.view.bounds.size.width, 200)];
    self.provinceView.delegate = self;
    self.provinceView.dataSource = self;

    [self.view addSubview:self.provinceView];

    [self.provinceView reloadAllComponents];
}

#pragma mark - Picker View DataSource && Delegate
// returns width of column and height of row for each component.
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {

    return (self.view.bounds.size.width -30) / 3.0;

}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {

    return 40;
};

// these methods return either a plain NSString, a NSAttributedString, or a view (e.g UILabel) to display the row for the component.
// for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
// If you return back a different object, the old one will be released. the view will be centered in the row rect
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component  {

    NSString *name = @"131341";
    if (component == 0) {
        if (row < self.provinceDict.allKeys.count) {

            name = [self.provinceDict.allKeys objectAtIndex:row];
        }
    }

    if (component == 1) {

        if (row < self.selecCity.count) {

            name = [self.selecCity objectAtIndex:row];
        }
    }

    if (component == 2) {

        if (row < self.selecDistrict.count) {

            name = [self.selecDistrict objectAtIndex:row];
        }
    }

    return name;
}
//- (nullable NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component NS_AVAILABLE_IOS(6_0) __TVOS_PROHIBITED {
//
//
//} // attributed title is favored if both methods are implemented
//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view __TVOS_PROHIBITED;

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component __TVOS_PROHIBITED {

//    NSLog(@"%@  \n row = %d \n component %d\n",pickerView,row,component);

    if (component == 0) {

        if (row < self.provinceDict.allKeys.count) {
            NSString *selProvince = [self.provinceDict.allKeys objectAtIndex:row];
            self.selectedProvince = selProvince;
            self.selecCity = [self.provinceDict objectForKey:selProvince];
            self.selecDistrt = self.cityDict[self.selecCity.firstObject];

            [pickerView reloadComponent:1];
        }
    }

    if (component == 1) {

        if (row < self.selecCity.count) {
            self.selectedCity = [self.selecCity objectAtIndex:row];
            self.selecDistrict = self.cityDict[self.selectedCity];

            [pickerView reloadComponent:2];
        }
    }

    if (component == 2) {

        if (row < self.selecDistrict.count) {
            self.selecDistrt = [self.selecDistrict objectAtIndex:row];
        }
    }

//    [pickerView reloadAllComponents];
}



// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {

    return 3;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {


    if (component == 0) {
        return self.provinceDict.allKeys.count;
    }

    if (component == 1) {

        return self.selecCity.count;
    }

    if (component == 2) {
        return self.selecDistrict.count;
    }

    return 0;
}


@end
