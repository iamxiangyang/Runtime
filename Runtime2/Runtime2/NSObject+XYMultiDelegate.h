//
//  NSObject+XYMultiDelegate.h
//  Runtime2
//
//  Created by 陈向阳 on 15/12/10.
//  Copyright © 2015年 陈向阳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (XYMultiDelegate)


//添加代理
- (void) addDelegate:(id)delegate;

//移除代理
- (void) removeDelegate:(id)delegate;




@end
