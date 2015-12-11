//
//  ViewController.m
//  Runtime2
//
//  Created by 陈向阳 on 15/12/10.
//  Copyright © 2015年 陈向阳. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "NSObject+XYMultiDelegate.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    Person *p = [[Person alloc]init];
    
    [p addDelegate:self];
    
    [p performSelector:@selector(sayHello) withObject:nil];
    

}

-(void)sayHello
{
    NSLog(@"大家好");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];


}

@end
