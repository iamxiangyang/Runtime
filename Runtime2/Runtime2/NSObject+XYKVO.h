//
//  NSObject+XYKVO.h
//  Runtime2
//
//  Created by 陈向阳 on 15/12/10.
//  Copyright © 2015年 陈向阳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (XYKVO)

- (void)xy_addObserver:(id)observer forKey:(NSString *)key withBlock:(void(^)(id,NSString *,id,id))block;


-(void)xy_removeObserver:(id)observer forKey:(NSString *)key;



@end
