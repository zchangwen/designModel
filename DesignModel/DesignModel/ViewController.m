//
//  ViewController.m
//  DesignModel
//
//  Created by ken on 2018/8/22.
//  Copyright © 2018年 zchangwen. All rights reserved.
//

#import "ViewController.h"

#import "Singleton.h"
#import "PriceTest.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createButtonWithIndex:0 withTitle:@"单例模式" withAction:@selector(singletonAction)];
    
    [self createButtonWithIndex:1 withTitle:@"策略模式" withAction:@selector(strategyAction)];
}


#pragma mark - action
- (void) singletonAction
{
    Singleton *singleton = [Singleton sharedInstance];
    NSLog(@"单例");
}

- (void) strategyAction
{
    [PriceTest price:15];
    [PriceTest price:8];
    NSLog(@"策略");
}

#pragma mark
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation
static CGFloat SizeFitWidthPlus(CGFloat value)
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    return screenWidth < 375? (value/375)*screenWidth:value;
}

static CGFloat SizeFitHeightPlus(CGFloat value)
{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    return screenHeight < 667? (value/667)*screenHeight:value;
}
- (void)createButtonWithIndex:(NSInteger)index withTitle:(NSString *)title withAction:(SEL)action
{
    CGFloat offsetX = SizeFitWidthPlus(12.f);
    CGFloat rowMargin = SizeFitHeightPlus(13.f);
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat buttonWidth = screenWidth - 2*offsetX;
    CGFloat buttonHeight = SizeFitHeightPlus(44.f);
    
    CGFloat offsetY = SizeFitHeightPlus(10) + (index+1) * rowMargin + index *buttonHeight;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(offsetX, offsetY, buttonWidth, buttonHeight);
    button.layer.cornerRadius = SizeFitHeightPlus(5);
    button.layer.masksToBounds = YES;
    UIColor *color = [self colorWithRGBHexString:@"#049DFF"];
    UIImage *normalBack = [self imageFromColor:color];
    [button setBackgroundImage:normalBack forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
}

- (UIColor *)colorWithRGBHexString:(NSString *)rgbString
{
    if ([rgbString length] == 0) {
        return nil;
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:rgbString];
    if ([rgbString hasPrefix:@"#"]) {
        scanner.scanLocation = 1;
    }
    else if (rgbString.length >= 2 && [[[rgbString substringToIndex:2] lowercaseString] isEqualToString:@"0x"]) {
        scanner.scanLocation = 2;
    }
    
    unsigned int value = 0;
    [scanner scanHexInt:&value];
    
    return [self colorWithRGBHex:value];
}

- (UIColor *)colorWithRGBHex: (unsigned int)hex
{
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:1.0f];
}
- (UIImage *)imageFromColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
