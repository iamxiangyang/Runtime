//
//  NSObject+XYCoding.h
//  Runtime2
//
//  Created by 陈向阳 on 15/12/10.
//  Copyright © 2015年 陈向阳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (XYCoding)<NSCoding>

-(void)encodeWithCoder:(NSCoder *)aCoder;

-(instancetype)initWithCoder:(NSCoder *)aDecoder;



@end
