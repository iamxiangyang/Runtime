//
//  NSObject+XYCoding.m
//  Runtime2
//
//  Created by 陈向阳 on 15/12/10.
//  Copyright © 2015年 陈向阳. All rights reserved.
//

#import "NSObject+XYCoding.h"
#import <objc/objc-runtime.h>

@implementation NSObject (XYCoding)

#pragma mark 遍历类中所有的实例变量，逐个进行归档、反归档


-(void)encodeWithCoder:(NSCoder *)aCoder
{
    
    //遍历实例变量
    unsigned int count = 0;
    
    
    Ivar *vars = class_copyIvarList(object_getClass(self), &count);
    
    for (int i = 0 ; i < count; i++) {
        
        Ivar var = vars[i];
        
        //获取实例变量名字
        
        NSString *varName = [NSString stringWithUTF8String:ivar_getName(var)];
        
        //KVC 取值
        
        id value = [self valueForKey:varName];
        
        //进行归档
        
        [aCoder encodeObject:value forKey:varName];
        
        
        
    }
    
          free(vars);

}


-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
        self = [self init];
        
        if (self) {
            
            //遍历实例变量链表，逐个反归档
            
            unsigned int count = 0;

            //获取属性列表数组
            Ivar *ivars = class_copyIvarList(object_getClass(self), &count);
            
            for (int i = 0; i < count; i ++) {
                
                Ivar ivar = ivars[i];
                
                NSString *varName = [NSString stringWithUTF8String:ivar_getName(ivar)];
                
                //反归档
               id value = [aDecoder decodeObjectForKey:varName];
                
                
                [self setValue:value forKey:varName];
                
            }
            
            free(ivars);
        }
    
    return self;
}


@end
