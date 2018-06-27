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

@interface ViewController ()

@property (nonatomic, strong) UIView      *floatView;
@property (nonatomic, strong) UIButton    *skipBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *filePath = @"/Users/xxx/temp/note2";
    [KJD__MixFileName mixFileName:filePath restore:YES];
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


@end
