//
//  TFHRouter.m
//  TwentyFourHours
//
//  Created by Prewindemon on 2016/9/30.
//  Copyright © 2016年 ZBJT. All rights reserved.
//

#import "ZbRouter.h"
#import "ZbRouterNoneStatusViewController.h"

NSString *const ZbRouterDefaultScheme = @"zbrouter";

NSString *const ZbRouterDefaultClassPrefix = @"ZbRouter_Target";

NSString *const ZbRouterDefaultActionPrefix = @"zbRouter_Action";

NSString *const ZbRouterSchemeKey = @"com.zbjt.ZbRouterSchemeKey";
NSString *const ZbRouterClassPrefixKey = @"com.zbjt.ZbRouterClassPrefixKey";
NSString *const ZbRouterActionPrefixKey = @"com.zbjt.ZbRouterActionPrefixKey";

@interface ZbRouter (){
@private
    NSMutableDictionary *ZbRouterQuickLookTarget;
@private
    NSMutableDictionary *ZbRouterQuickLookAction;
}

@property(nonatomic, strong)NSString *ZbRouterScheme;
@property(nonatomic, strong)NSString *ZbRouterClassPrefix;
@property(nonatomic, strong)NSString *ZbRouterActionPrefix;

@end

@implementation ZbRouter

#pragma mark =========================初始化=========================
+ (instancetype)router{
    static id sharedRouter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedRouter = [[self alloc] init];
    });
    return sharedRouter;
}

#pragma mark 初始化init
- (instancetype)init{
    self = [super init];
    if (self) {
        self.ZbRouterScheme = ZbRouterDefaultScheme;
        self.ZbRouterClassPrefix = ZbRouterDefaultClassPrefix;
        self.ZbRouterActionPrefix = ZbRouterDefaultActionPrefix;
        
    }
    return self;
}

+ (UIViewController *)controllerFromString: (NSString *)controllerName;{
    UIViewController *controller = [NSClassFromString(controllerName) new];
    if (![controller isKindOfClass: [UIViewController class]]) {
        controller = [[ZbRouterNoneStatusViewController alloc] initWithErrorMsg: [NSString stringWithFormat: @"未找到：【%@】", controllerName]];
    }
    return controller;
}

#pragma mark =========================注册=========================
/**
 注册ZbRouterParams
 
 @param registerParams @{
 ZbRouterSchemeKey: NSString
 ZbRouterClassPrefixKey: NSString
 ZbRouterActionPrefixKey: NSString
 }
 
 @return 返回成功与否
 */
- (BOOL)registerZbRouter:(NSDictionary *)registerParams{
    if ([registerParams count]) {
        
        if (!self.isRegistered) {
            NSAssert([registerParams.allKeys containsObject: ZbRouterSchemeKey], @"参数中不包含[ZbRouterSchemeKey]");
            NSAssert([registerParams.allKeys containsObject: ZbRouterClassPrefixKey], @"参数中不包含[ZbRouterClassPrefixKey]");
            NSAssert([registerParams.allKeys containsObject: ZbRouterActionPrefixKey], @"参数中不包含[ZbRouterActionPrefixKey]");
            
            NSString *routerScheme = [registerParams objectForKey: ZbRouterSchemeKey];
            NSString *routerClassPrefix = [registerParams objectForKey: ZbRouterClassPrefixKey];
            NSString *routerActionPrefix = [registerParams objectForKey: ZbRouterActionPrefixKey];
            
            NSAssert([routerScheme isKindOfClass: [NSString class]] && [routerScheme length], @"参数[ZbRouterSchemeKey]格式必须为[NSString]，且长度大于0");
            NSAssert([routerClassPrefix isKindOfClass: [NSString class]] && [routerClassPrefix length], @"参数[ZbRouterClassPrefixKey]格式必须为[NSString]，且长度大于0");
            NSAssert([routerActionPrefix isKindOfClass: [NSString class]] && [routerActionPrefix length], @"参数[ZbRouterActionPrefixKey]格式必须为[NSString]，且长度大于0");
            
            return [self registerZbRouterScheme: routerScheme
                                    classPrefix: routerClassPrefix
                                   actionPreFix: routerActionPrefix];
        }
    }
    return NO;
    
}


/**
 注册ZbRouter
 
 @param scheme scheme
 @param classPrefix classPrefix
 @param actionPreFix actionPreFix
 @return 返回成功与否
 */
- (BOOL)registerZbRouterScheme: (NSString *)scheme
                   classPrefix: (NSString *)classPrefix
                  actionPreFix: (NSString *)actionPreFix;{
    if (!self.isRegistered) {
        self.ZbRouterScheme = scheme;
        self.ZbRouterClassPrefix = classPrefix;
        self.ZbRouterActionPrefix = actionPreFix;
        _isRegistered = YES;
        return YES;
    }
    return NO;
}

#pragma mark =========================快捷映射=========================
/**
 添加便捷访问入口
 
 @param quickName 便捷访问地址
 @param targetName 映射地址
 */
- (void)addQuickTarget: (NSString *)quickName targetName: (NSString *)targetName;{
    NSAssert([quickName length], @"参数[quickName]格式不对，长度必须大于0");
    NSAssert([targetName length], @"参数[targetName]格式不对，长度必须大于0");
    if (!ZbRouterQuickLookTarget) {
        ZbRouterQuickLookTarget = [NSMutableDictionary dictionary];
    }
    [ZbRouterQuickLookTarget setObject: targetName forKey:quickName];
}

/**
 添加便捷访问入口
 
 @param quickName 便捷访问地址
 @param actionName 映射地址
 */
- (void)addQuickAction: (NSString *)quickName actionName: (NSString *)actionName;{
    NSAssert([quickName length], @"参数[quickName]格式不对，长度必须大于0");
    NSAssert([actionName length], @"参数[actionName]格式不对，长度必须大于0");
    if (!ZbRouterQuickLookAction) {
        ZbRouterQuickLookAction = [NSMutableDictionary dictionary];
    }
    [ZbRouterQuickLookAction setObject: actionName forKey:quickName];
}

#pragma mark =========================远程调用=========================

/**
 远程App调用入口
 zbrouter://test.target/demoaction/Demo?name=xiaoming&id=2312
 targetName: testtarget
 actionName: demoactionDemo
 parame: @{
 @"name": @"xiaoming",
 @"id": @"2312"
 }
 
 
 @param url        url链接
 @param completion 回调
 
 @return 实例对象
 */
- (id)router_performActionWithUrl:(NSURL *)url completion:(void (^)(NSDictionary *))completion{
    //判定是否来自ZB请求
    if (![url.scheme isEqualToString: self.ZbRouterScheme]) {
        // 这里就是针对远程app调用404的简单处理了，根据不同app的产品经理要求不同，你们可以在这里自己做需要的逻辑
        return [[ZbRouterNoneStatusViewController alloc] initWithErrorMsg: [NSString stringWithFormat: @"【%@】Scheme不正确", url.scheme]];
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    //获取url请求属性，解码中文，只有属性中可能会有中文
    NSString* urlString = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    for (NSString *param in [urlString componentsSeparatedByString:@"&"]) {
        NSArray *elts = [param componentsSeparatedByString:@"="];
        if([elts count] < 2) continue;
        [params setObject:[elts lastObject] forKey:[elts firstObject]];
    }
    
    NSString *targetName = [url.host stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    // 这里这么写主要是出于安全考虑，防止黑客通过远程方式调用本地模块。这里的做法足以应对绝大多数场景，如果要求更加严苛，也可以做更加复杂的安全逻辑。
    NSString *actionName = [url.path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    if ([actionName hasPrefix:@"native"]) {
        return @(NO);
    }
    
    //针对URL的路由处理非常简单，就只是取对应的target名字和method名字，但这已经足以应对绝大部份需求。如果需要拓展，可以在这个方法调用之前加入完整的路由逻辑
    id result = [self router_performTarget: targetName action: actionName params: params];
    if (completion) {
        if (result) {
            completion(@{@"result":result});
        } else {
            completion(nil);
        }
    }
    return result;
}
/**
 远程App调用入口
 zbrouter://test.target/demoaction/Demo?name=xiaoming&id=2312
 targetName: testtarget
 actionName: demoactionDemo
 parame: @{
 @"name": @"xiaoming",
 @"id": @"2312"
 }
 
 
 @param url         url链接
 @param param       参数
 
 @return 实例对象
 */

- (id)router_performActionWithUrl: (NSURL *)url param: (NSDictionary *)param;{
    //判定是否来自ZB请求
    if (![url.scheme isEqualToString: self.ZbRouterScheme]) {
        // 这里就是针对远程app调用404的简单处理了，根据不同app的产品经理要求不同，你们可以在这里自己做需要的逻辑
        return [[ZbRouterNoneStatusViewController alloc] initWithErrorMsg: [NSString stringWithFormat: @"【%@】Scheme不正确", url.scheme]];
    }
    
    NSMutableDictionary *params = [param mutableCopy];
    if (!params) {
        params = [[NSMutableDictionary alloc] init];
    }
    
    //获取url请求属性，解码中文，只有属性中可能会有中文
    NSString* urlString = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    for (NSString *urlParam in [urlString componentsSeparatedByString:@"&"]) {
        NSArray *elts = [urlParam componentsSeparatedByString:@"="];
        if([elts count] < 2) continue;
        [params setObject:[elts lastObject] forKey:[elts firstObject]];
    }
    
    NSString *targetName = [url.host stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    // 这里这么写主要是出于安全考虑，防止黑客通过远程方式调用本地模块。这里的做法足以应对绝大多数场景，如果要求更加严苛，也可以做更加复杂的安全逻辑。
    NSString *actionName = [url.path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    if ([actionName hasPrefix:@"native"]) {
        return @(NO);
    }
    
    //针对URL的路由处理非常简单，就只是取对应的target名字和method名字，但这已经足以应对绝大部份需求。如果需要拓展，可以在这个方法调用之前加入完整的路由逻辑
    id result = [self router_performTarget: targetName action: actionName params: params];
    
    return result;
}

/**
 远程App调用入口
 
 @param url        url链接
 @param completion 回调
 
 @return 实例对象
 */
- (id)router_performActionWithHttpUrl:(NSString *)url completion:(void (^)(NSDictionary *))completion{
    if (![url containsString:@"://"]) {
        return [ZbRouter controllerFromString:url];
    }
    //为了防止有中文，提前进行编码
    NSString *cnUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return [self router_performActionWithUrl: [NSURL URLWithString: cnUrl] completion: completion];
}
/**
 远程App调用入口
 
 @param url        url链接
 @param param 回调
 
 @return 实例对象
 */
- (id)router_performActionWithHttpUrl:(NSString *)url param:(NSDictionary *)param{
    if (![url containsString:@"://"]) {
        return [ZbRouter controllerFromString:url];
    }
    //为了防止有中文，提前进行编码
    NSString *cnUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return [self router_performActionWithUrl: [NSURL URLWithString: cnUrl] param: param];
}


/**
 本地组件调用入口
 
 @param targetName 组件类名称
 @param actionName 组件方法名
 @param params     方法参数
 
 @return 实例对象
 */
- (id)router_performTarget:(NSString *)targetName action:(NSString *)actionName params:(NSDictionary *)params{
    
    /** 简写方法拼接 */
    NSString *prefixClassActionName = [NSString stringWithFormat:@"%@.%@", targetName, actionName];
    
    if ([ZbRouterQuickLookTarget.allKeys containsObject: targetName]) {
        targetName = ZbRouterQuickLookTarget[targetName];
    }
    
    /** 全写方法拼接 */
    NSString *classActionName = [NSString stringWithFormat:@"%@.%@", targetName, actionName];
    
    
    /** 如果注册了简写类方法 */
    if ([ZbRouterQuickLookAction.allKeys containsObject: classActionName]) {
        actionName = ZbRouterQuickLookAction[classActionName];
    }else{
        if (![classActionName isEqualToString:prefixClassActionName]) {
            /** 如果注册了全写类方法 */
            if ([ZbRouterQuickLookAction.allKeys containsObject: prefixClassActionName]) {
                actionName = ZbRouterQuickLookAction[prefixClassActionName];
            }
        }
        if ([ZbRouterQuickLookAction.allKeys containsObject: actionName]) {
            actionName = ZbRouterQuickLookAction[actionName];
        }
    }
    
    
    
    //获取类名称
    NSString *targetClassString = [NSString stringWithFormat:@"%@_%@", self.ZbRouterClassPrefix, targetName];
    //获取selecter名称
    NSString *actionString = [NSString stringWithFormat:@"%@_%@:", self.ZbRouterActionPrefix, actionName];
    
    NSLog(@"targetClass: %@", targetClassString);
    
    NSLog(@"actionSelector: %@", actionString);
    
    NSLog(@"params: %@", params);
    
    //获取类
    Class targetClass = NSClassFromString(targetClassString);
    //获取类的实例对象
    id target = [[targetClass alloc] init];
    //获取类的实例方法
    SEL action = NSSelectorFromString(actionString);
    
    // 这里是处理无响应请求的地方之一，这个demo做得比较简单，如果没有可以响应的target，就直接return了。实际开发过程中是可以事先给一个固定的target专门用于在这个时候顶上，然后处理这种请求的
    if (!target) {
        return [[ZbRouterNoneStatusViewController alloc] initWithErrorMsg: [NSString stringWithFormat:@"【%@】Target不正确", targetName]];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    //判定实例对象是否有对应方法
    if ([target respondsToSelector:action]) {
        //执行方法
        return [target performSelector:action withObject:params];
        
    } else {
        // 这里是处理无响应请求的地方，如果无响应，则尝试调用对应target的notFound方法统一处理
        return [[ZbRouterNoneStatusViewController alloc] initWithErrorMsg: [NSString stringWithFormat:@"【%@】Action不正确", actionName]];
    }
#pragma clang diagnostic pop
}
@end
