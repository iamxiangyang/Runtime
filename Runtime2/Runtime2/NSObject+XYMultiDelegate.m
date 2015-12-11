//
//  NSObject+XYMultiDelegate.m
//  Runtime2
//
//  Created by 陈向阳 on 15/12/10.
//  Copyright © 2015年 陈向阳. All rights reserved.
//

#import "NSObject+XYMultiDelegate.h"
#import <objc/objc-runtime.h>

//数组关联对象时用的key

NSString * const kMultiDelegateKey = @"MultiDelegateKey";


@implementation NSObject (XYMultiDelegate)


-(void)addDelegate:(id)delegate
{
    //设置代理数组为对象的关联对象
    
    NSMutableArray *delegateArray = objc_getAssociatedObject(self, (__bridge const void *)kMultiDelegateKey);
    
    //若当前对象没有关联的数组，创建并设置
    if (!delegateArray) {
        
        delegateArray = [NSMutableArray new];
        
        objc_setAssociatedObject(self, (__bridge const void *)kMultiDelegateKey,delegateArray,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
    }
    
    //将代理对象添加到数组里
    
    [delegateArray addObject:delegate];
    
    
}


//移除代理
-(void)removeDelegate:(id)delegate
{
    
    NSMutableArray *delegateArray = objc_getAssociatedObject(self, (__bridge const void *)kMultiDelegateKey);
    
    if (! delegateArray) {
        
        
        @throw [NSException exceptionWithName:@"Error" reason:@"数组是空" userInfo:nil];
        
        
    }
    [delegateArray removeObject:delegate];
    
    
}


//消息转发给代理数组中的元素

- (void)doNothing
{
    
}


//获取方法标识
-(NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    
    //获取存放代理的数组
    
    NSMutableArray *delegateArray = objc_getAssociatedObject(self, (__bridge  const void *)kMultiDelegateKey);
    
    //遍历数组
    
    for (id aDekegate in delegateArray) {
        
        
        //获取每个元素对应的方法标识
        
        NSMethodSignature *signature = [aDekegate methodSignatureForSelector:aSelector];
        
        //如果方法标识不为空 返回
        if (signature) {
            
            
            return signature;
        }
        
        
    }
    
    return [[self class]instanceMethodSignatureForSelector:@selector(doNothing)];
    
    
    
}


//消息转发给其他对象(多播委托)

-(void)forwardInvocation:(NSInvocation *)anInvocation
{
    
    //获取代理数组
    NSMutableArray *delegateArray = objc_getAssociatedObject(self, (__bridge  const void *)kMultiDelegateKey);
    
    for (id aDelegate in delegateArray) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
           
            //异步转发消息
            [anInvocation invokeWithTarget:aDelegate];
            
        });
        
    }

    
}
@end
