//
//  NSObject+XYKVO.m
//  Runtime2
//
//  Created by 陈向阳 on 15/12/10.
//  Copyright © 2015年 陈向阳. All rights reserved.
//

#import "NSObject+XYKVO.h"
#import <objc/objc-runtime.h>

NSString * const XYKVOCkassPrefix = @"XYKVOCkassPrefix";

NSString * const XYObserverAssociatedKey = @"XYObserverAssociatedKey";

typedef void (^ObserverBlock)(id observerObject,NSString *key, id oldValue, id newValue);



//创建一个用于存放观察者info的类
@interface XYObserverInfo : NSObject

//观察者属性
@property (nonatomic , weak) id observer;


//key属性

@property (nonatomic , copy)NSString * key;



//回调block


@property(nonatomic , copy)ObserverBlock  block;



@end

@implementation XYObserverInfo

-(instancetype)initWithObserver:(id)observer forkey:(NSString *)key withBlock:(ObserverBlock)block
{
    
    self = [super init];
    
    if (self) {
        
        _observer = observer;
        
        _key = key;
        
        _block = block;
    }
    
    return self;
}


@end

@implementation NSObject (XYKVO)


-(void)xy_addObserver:(id)observer forKey:(NSString *)key withBlock:(void (^)(id, NSString *, id, id))block
{
    // 获取 setterName
    
    NSString *setterNames = setterName(key);
    
    SEL setSelecter = NSSelectorFromString(setterNames);
    
    //通过SEL获取方法
    
    Method setMethod = class_getInstanceMethod(object_getClass(self), setSelecter);
    
    if (! setMethod) {
        @throw [NSException exceptionWithName:@"XYKVO" reason:@"若无setter方法，无法KVO" userInfo:nil];
        
        
    }
    
     //获得当前类
    
     //判断是否已经创建衍生类
    
    Class thisClass = object_getClass(self);
    
    NSString *thisClassName = NSStringFromClass(thisClass);
    
    if (![thisClassName hasPrefix:XYKVOCkassPrefix]) {
     
        
     thisClass  =  [self makeKVOClassWithOriginalClassName:thisClassName];
        
     //改变类的标识
        
        object_setClass(self, thisClass);
        
    }
    
     //判断衍生类中是否实现了setter方法
    
    if (! [self hasSelecter:setSelecter]) {
        
        const char *setType = method_getTypeEncoding(setMethod);
        
        class_addMethod(object_getClass(self), setSelecter, (IMP)xy_setter, setType);
        
    }
    
   //将observer 添加到观察者数组s
    NSMutableArray  *observers = objc_getAssociatedObject(self, (__bridge  const void *)(XYObserverAssociatedKey));
    
    if (!observers) {
        
        
        observers = [NSMutableArray new];
        
        objc_setAssociatedObject(self, (__bridge const void *)(XYObserverAssociatedKey),observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
  //创建观察者info类
    
    XYObserverInfo *observerInfo = [[XYObserverInfo alloc]initWithObserver:observer forkey:key withBlock:block];
    
    [observers addObject:observerInfo];
    
}

void xy_setter(id objc_self, SEL cmd_p, id oldValue, id newValue )
{
    
    //setterName转为name
    
    NSString *setName = NSStringFromSelector(cmd_p);
    
    NSString *key = nameWithSetName(setName);
    
    //通过KVC获取key对应的value
    
    id oldV =[objc_self valueForKey:key];
    
    //将set消息转发给父类
    struct objc_super selfSupper = {
      
        .receiver = objc_self,
        
        .super_class = class_getSuperclass(object_getClass(objc_self))
        
    };
    
    
    objc_msgSendSuper(&selfSupper,cmd_p,newValue);
    
    //调用blcok
    
    NSMutableArray *observers = objc_getAssociatedObject(objc_self, (__bridge const void *)XYObserverAssociatedKey);
    
    for (XYObserverInfo *info in observers) {
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
           
            
            
        });
        
    }
    
}

//从setterName转为name
NSString *nameWithSetName(NSString *setName)
{
    
    if (setName.length <= 4 || ![setName hasPrefix:@"set"] || ![setName hasSuffix:@":"]) {
        
        
        @throw [NSException exceptionWithName:@"XYKVO Error" reason:@"set方法不可用" userInfo:nil];
        
        
    }
    
    NSString *Name = [setName substringWithRange:NSMakeRange(3, setName.length - 4)];
    
    NSString *firstCharacter = [Name substringToIndex:1];
    
    return [[firstCharacter lowercaseString]stringByAppendingString:[Name substringFromIndex:1]];
    
}

//判断set方法是否存在
-(BOOL)hasSelecter:(SEL)aSelecter
{
    
    unsigned int mCount = 0;
    
    //获取所有方法
    Method *methods = class_copyMethodList(object_getClass(self), &mCount);
    
    for (int i = 0 ; i < mCount; i ++) {
        
        Method method = methods[i];
        
        SEL setSelecter = method_getName(method);
        
        if (setSelecter == aSelecter) {
            
            free(methods);;
            
            return YES;
        }
        
    }
    
    free(methods);
    
    return NO;
}


//通过runtime创建衍生类

-(Class)makeKVOClassWithOriginalClassName:(NSString *)
className
{
    NSString *kvoClassName = [XYKVOCkassPrefix stringByAppendingString:className];
    
    Class kvoClass =NSClassFromString(kvoClassName);
    
    if (kvoClass) {
        
        return kvoClass;
    }
    
    //objc_allocateClassPair创建类
    
    kvoClass = objc_allocateClassPair(object_getClass(self), kvoClassName.UTF8String, 0);
    
    objc_registerClassPair(kvoClass);
    
    
    return kvoClass;
    
}



// 通过key 获取对应的setterName
NSString *setterName(NSString * key)
{
    if (key.length == 0) {
        
        
        @throw [NSException exceptionWithName:@"XYKVO error" reason:@"没有对应的key" userInfo:nil];
        
        
    }
    
    
    NSString *firsCharacter = [key substringToIndex:1];
    
    //转换首字母为大写
    NSString *name = [[firsCharacter uppercaseString] stringByAppendingString:[key substringFromIndex:1]];
    
    
    return [NSString stringWithFormat:@"set%@:",name];
    
}



-(void)xy_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    
    //删除观察者
    
    XYObserverInfo * removeInfo = nil;
    
    NSMutableArray *observers = objc_getAssociatedObject(self, (__bridge const void *)(XYObserverAssociatedKey));
    
    for (XYObserverInfo *info in observers) {
        
        if (info.observer == observer && [info.key isEqualToString:keyPath]) {
            
            removeInfo = info;
        }
        
    }
    [observers removeObject:removeInfo];
    
    
}


@end
