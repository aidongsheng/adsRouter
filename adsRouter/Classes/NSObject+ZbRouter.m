//
//  NSObject+Router.m
//  TwentyFourHours
//
//  Created by Prewindemon on 2016/10/6.
//  Copyright © 2016年 ZBJT. All rights reserved.
//

#import "NSObject+ZbRouter.h"

@implementation NSObject (ZbRouter)

- (id)zbRouter_ActionNotfound: (NSDictionary *)params{
    NSLog(@"404NotFound");
    return nil;
}

@end
