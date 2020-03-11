//
/*
 ********************************************************************************
 * File     : ViewController.m
 *
 * Author   : chenqg
 *
 * History  : Created by chenqg on 2020/3/11.
 ********************************************************************************
 */

#import "ViewController.h"
#import "RewardAdWrapper.h"

@interface ViewController ()

@property (nonatomic, strong) RewardAdWrapper *rewardAd;
@property (nonatomic, strong) NSArray *adArr;
@property (nonatomic, strong) UIButton *rewardButton;

@end

@implementation ViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self preloadAd];
    [self.view addSubview:self.rewardButton];
}

#pragma mark - internal method

- (void)preloadAd{
    [self.rewardAd preloadWithViewController:self configArray:self.adArr];
}

- (void)playAdVideo{
    _rewardButton.backgroundColor = [UIColor blueColor];
    __weak typeof(self) weakself = self;
    [weakself.rewardAd showAdCallBack:^(RewardAdState state) {
        NSLog(@"state -- > %@",@(state));
    }];
}

#pragma mark - getter

- (UIButton *)rewardButton{
    if (!_rewardButton) {
        _rewardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rewardButton.frame = CGRectMake(0, 0, 200, 50);
        _rewardButton.center = self.view.center;
        _rewardButton.backgroundColor = [UIColor orangeColor];
        [_rewardButton setTitle:@"播放激励视频" forState:UIControlStateNormal];
        [_rewardButton addTarget:self action:@selector(playAdVideo) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rewardButton;
}

- (RewardAdWrapper *)rewardAd{
    if (!_rewardAd) {
        _rewardAd = [[RewardAdWrapper alloc] init];
    }
    return _rewardAd;
}

- (NSArray *)adArr{
    if (!_adArr) {
        _adArr =  @[@{@"ad_type":@"buAd",@"app_id":@"5000546",@"position_id":@"900546826",@"ad_weight":@"100"},@{@"ad_type":@"gdtAd",@"app_id":@"1105344611",@"position_id":@"80207442129364268020744212936426",@"ad_weight":@"100"}];
        
    }
    return _adArr;
}

@end
