//
//  ViewController5.m
//  CustomTransition
//
//  Created by wf on 2018/11/7.
//  Copyright © 2018 sohu. All rights reserved.
//

#import "ViewController5.h"
#import "CustomTransition-Swift.h"

@interface ViewController5 ()

@end

@implementation ViewController5

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor orangeColor];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"ic_close_black_normal"] forState:UIControlStateNormal];
    [closeBtn setFrame:CGRectMake(20, 20, 32, 32)];
    [closeBtn addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
}

- (void)closeAction:(UIButton *)btn {
    [self.containerVC dismiss:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
