//
/*
 ********************************************************************************
 * File     : RewardAdWrapper.h
 *
 * Author   : chenqg
 *
 * History  : Created by chenqg on 2020/3/11.
 ********************************************************************************
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RewardAdState){
    RewardVideoAdLoadFailed = 1,//失败
    RewardVideoAdWillShow,//将要显示
    RewardVideoAdClosed,//关闭
    RewardVideoAdPlayFinished,//播放完毕
};

typedef void (^RewardAdBlock)(RewardAdState state);

@interface RewardAdWrapper : NSObject

- (void)preloadWithViewController:(UIViewController *)viewController configArray:(NSArray *)configArray;

- (void)showAdCallBack:(RewardAdBlock)callBack;

@end

