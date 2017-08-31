//
//  TFHRouter.h
//  TwentyFourHours
//
//  Created by Prewindemon on 2016/9/30.
//  Copyright © 2016年 ZBJT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *const ZbRouterSchemeKey;
extern NSString *const ZbRouterClassPrefixKey;
extern NSString *const ZbRouterActionPrefixKey;

@interface ZbRouter : NSObject

+ (instancetype)router;


/**
 获取指定Controller名称的Controller
 */
+ (UIViewController *)controllerFromString: (NSString *)controllerName;


@property(nonatomic, assign, readonly)BOOL isRegistered;
/**
 注册ZbRouterParams
 
 @param registerParams @{
 ZbRouterSchemeKey: NSString
 ZbRouterClassPrefixKey: NSString
 ZbRouterActionPrefixKey: NSString
 }
 
 @return 返回成功与否
 */
- (BOOL)registerZbRouter:(NSDictionary *)registerParams;

/**
 注册ZbRouter
 
 @param scheme scheme
 @param classPrefix classPrefix
 @param actionPreFix actionPreFix
 @return 返回成功与否
 */
- (BOOL)registerZbRouterScheme: (NSString *)scheme
                   classPrefix: (NSString *)classPrefix
                  actionPreFix: (NSString *)actionPreFix;


/**
 添加便捷访问入口

 @param quickName 便捷访问地址
 @param targetName 映射地址
 */
- (void)addQuickTarget: (NSString *)quickName targetName: (NSString *)targetName;

/**
 添加便捷访问入口
 
 @param quickName 便捷访问地址
 @param actionName 映射地址
 */
- (void)addQuickAction: (NSString *)quickName actionName: (NSString *)actionName;

// 远程App调用入口
- (id)router_performActionWithUrl: (NSURL *)url completion: (void(^)(NSDictionary *info))completion NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, "请使用router_performActionWithUrl:param:方法");

/**
 远程App调用入口

 @param url 链接
 @param param 参数
 @return 输出
 */
- (id)router_performActionWithUrl: (NSURL *)url param: (NSDictionary *)param;


// 远程App调用入口
- (id)router_performActionWithHttpUrl: (NSString *)url completion: (void(^)(NSDictionary *info))completion NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, "请使用router_performActionWithHttpUrl:param:方法");

/**
 远程App调用

 @param url 链接
 @param param 参数
 @return 输出
 */
- (id)router_performActionWithHttpUrl: (NSString *)url param: (NSDictionary *)param;

// 本地组件调用入口
- (id)router_performTarget: (NSString *)targetName action: (NSString *)actionName params: (NSDictionary *)params;

@end
