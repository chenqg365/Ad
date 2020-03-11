//
/*
 ********************************************************************************
 * File     : RewardAdWrapper.m
 *
 * Author   : chenqg
 *
 * History  : Created by chenqg on 2020/3/11.
 ********************************************************************************
 */

#import "RewardAdWrapper.h"
#import <BUAdSDK/BURewardedVideoModel.h>
#import <BUAdSDK/BURewardedVideoAd.h>
#import <GDTAd/GDTRewardVideoAd.h>

@interface RewardAdWrapper ()<GDTRewardedVideoAdDelegate, BURewardedVideoAdDelegate>

@property (nonatomic, strong) GDTRewardVideoAd *gdtAd;
@property (nonatomic, strong) BURewardedVideoAd *buAd;
@property (nonatomic, strong) NSArray *adConfigArray;
@property (nonatomic, strong) NSDictionary *gdtConfigDic;
@property (nonatomic, strong) NSDictionary *buConfigDic;
@property (nonatomic, assign) BOOL retry;
@property (nonatomic, assign) BOOL autoPlay;
@property (nonatomic, copy) RewardAdBlock callBlock;
@property (nonatomic, strong) UIViewController *viewController;


@end

@implementation RewardAdWrapper

#pragma mark - public method

- (void)preloadWithViewController:(UIViewController *)viewController configArray:(NSArray *)configArray {

    self.viewController = viewController;
    self.adConfigArray = configArray;
    
    CGFloat weight = 0.0;
    NSInteger randomValue = 0;
    NSInteger adIndex = 999;
    NSInteger allRandomValue = 0;
    for (NSInteger index = 0; index < self.adConfigArray.count; index++) {
        NSDictionary *adDic = [self.adConfigArray objectAtIndex:index];
        CGFloat adWeight = [[adDic objectForKey:@"ad_weight"] floatValue];
        allRandomValue += adWeight;
    }
    randomValue = ((arc4random() % allRandomValue)+1);

    for (NSInteger index = 0; index < self.adConfigArray.count; index++) {
        NSDictionary *adDic = [self.adConfigArray objectAtIndex:index];
        CGFloat currentWeight = [[adDic objectForKey:@"ad_weight"] floatValue];
        if ((randomValue < currentWeight) || (randomValue < (weight + currentWeight))) {
            adIndex = index;
            break;
        }else{
            weight += currentWeight;
        }
    }
    
    if (adIndex == 999) {
        return;
    }
    
    NSString *adType = [[self.adConfigArray objectAtIndex:adIndex] objectForKey:@"ad_type"];
    
    if ([adType isEqualToString:@"buAd"]) {
        self.gdtConfigDic = self.adConfigArray[adIndex];
        [self requestAdWithConfig:self.gdtConfigDic];
    }else{
        self.buConfigDic = self.adConfigArray[adIndex];
        [self requestAdWithConfig:self.buConfigDic];
    }
}

- (void)showAdCallBack:(RewardAdBlock)callBack {
    self.retry = NO;
    self.autoPlay = NO;
    self.callBlock = callBack;
    
    if (self.gdtAd.isAdValid) {
        BOOL result = [self.gdtAd showAdFromRootViewController:self.viewController];
        if (!result) {
            self.autoPlay = YES;
            [self requestAdWithConfig:self.gdtConfigDic];
        }
    } else if (self.buAd.isAdValid) {
        BOOL result = [self.buAd showAdFromRootViewController:self.viewController];
        if (!result) {
            self.autoPlay = YES;
            [self requestAdWithConfig:self.buConfigDic];
        }
    } else {
        self.autoPlay = YES;
        [self preloadWithViewController:self.viewController configArray:self.adConfigArray];
    }
}

#pragma mark - GDTRewardedVideoAdDelegate

- (void)gdt_rewardVideoAdDidLoad:(GDTRewardVideoAd *)rewardedVideoAd{
    if (self.autoPlay) {
        self.autoPlay = NO;
        [rewardedVideoAd showAdFromRootViewController:self.viewController];
    }
}

- (void)gdt_rewardVideoAd:(GDTRewardVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error{
    if (!self.retry) {
        self.retry = YES;
        [self requestAdWithConfig:self.buConfigDic];
    } else {
        if (self.callBlock) {
            self.callBlock(RewardVideoAdLoadFailed);
        }
    }
}

- (void)gdt_rewardVideoAdWillVisible:(GDTRewardVideoAd *)rewardedVideoAd{
    if (self.callBlock) {
        self.callBlock(RewardVideoAdWillShow);
    }
}

- (void)gdt_rewardVideoAdDidClose:(GDTRewardVideoAd *)rewardedVideoAd{
    if (self.callBlock) {
        self.callBlock(RewardVideoAdClosed);
    }
    [self preloadWithViewController:self.viewController configArray:self.adConfigArray];
}

#pragma mark - BURewardedVideoAdDelegate

- (void)rewardedVideoAdDidLoad:(BURewardedVideoAd *)rewardedVideoAd{
    if (self.autoPlay) {
        self.autoPlay = NO;
        [rewardedVideoAd showAdFromRootViewController:self.viewController];
    }
}

- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    if (!self.retry) {
        self.retry = YES;
        [self requestAdWithConfig:self.gdtConfigDic];
    } else {
        if (self.callBlock) {
            self.callBlock(RewardVideoAdLoadFailed);
        }
    }
}

- (void)rewardedVideoAdWillVisible:(BURewardedVideoAd *)rewardedVideoAd {
    if (self.callBlock) {
        self.callBlock(RewardVideoAdWillShow);
    }
}

- (void)rewardedVideoAdDidClose:(BURewardedVideoAd *)rewardedVideoAd {
    if (self.callBlock) {
        self.callBlock(RewardVideoAdClosed);
    }
    [self preloadWithViewController:self.viewController configArray:self.adConfigArray];
}


#pragma mark - internal method

- (void)requestAdWithConfig:(NSDictionary *)adConfig {
    NSString *appId = [adConfig objectForKey:@"app_id"];
    NSString *positionId = [adConfig objectForKey:@"position_id"];
    NSString *adType = [adConfig objectForKey:@"ad_type"];
    if (!appId || !positionId || !adType) {
        return ;
    }
    
    if ([adType isEqualToString:@"buAd"]) {
        BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
        self.buAd = [[BURewardedVideoAd alloc] initWithSlotID:positionId
                                                                                              rewardedVideoModel:model];
        self.buAd.delegate = self;
        [self.buAd loadAdData];
    } else if ([adType isEqualToString:@"gdtAd"]) {
        self.gdtAd = [[GDTRewardVideoAd alloc] initWithAppId:appId placementId:positionId];
        self.gdtAd.delegate = self;
        [self.gdtAd loadAd];
    }
}

@end
