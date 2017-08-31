//
//  ZbRouterNoneStatusViewController.m
//  Pods
//
//  Created by Prewindemon on 2017/4/24.
//
//

#import "ZbRouterNoneStatusViewController.h"

@interface ZbRouterNoneStatusViewController ()

@property(nonatomic, strong)NSString *errorMsg;

@end

@implementation ZbRouterNoneStatusViewController

- (instancetype)initWithErrorMsg: (NSString *)errorMsg;{
    self = [super init];
    if (self) {
        self.errorMsg = errorMsg;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *showLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 300.f, 77.f)];
    if ([self.errorMsg length]) {
        showLabel.text = self.errorMsg;
    }else{
        showLabel.text = @"未传入指定Controller名称";
    }
    showLabel.font = [UIFont boldSystemFontOfSize: 20.f];
    showLabel.textColor = [UIColor grayColor];
    showLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview: showLabel];
    showLabel.center = self.view.center;
    
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"111");
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
