//
//  ViewController4.m
//  CustomTransition
//
//  Created by wf on 2018/11/7.
//  Copyright © 2018 sohu. All rights reserved.
//

#import "ViewController4.h"
#import "ViewController5.h"
#import "CustomTransition-Swift.h"

@interface ViewController4 ()

@end

@implementation ViewController4

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"button" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(100, 100, 100, 40)];
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}

- (void)btnAction:(UIButton *)sender {
    ViewController5 *vc5 = [[ViewController5 alloc]init];
    [self.containerVC pushWithViewController:vc5 completion:nil];
}

@end
