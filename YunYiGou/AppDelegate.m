//
//  AppDelegate.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "AppDelegate.h"

#import "DataCenter.h"
#import "NetworkModel.h"

#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"

#import "HomeViewController_iph.h"
#import "CategoryViewController_iph.h"
#import "CartViewController_iph.h"
#import "MineViewController_iph.h"

#import "HomeViewController_ipa.h"
#import "CategoryViewController_ipa.h"
#import "CartViewController_ipa.h"
#import "MineViewController_ipa.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (void)startIphoneAPP:(UIWindow*)window
{
    HomeViewController_iph*     pControllerHome     = [[HomeViewController_iph alloc] init];
    CateViewController_iph*     pControllerCate     = [[CateViewController_iph alloc] init];
    CartViewController_iph*     pControllerCart     = [[CartViewController_iph alloc] init];
    MineViewController_iph*     pControllerMine     = [[MineViewController_iph alloc] init];
    
    UINavigationController* pNavContrHome = [[UINavigationController alloc] initWithRootViewController:pControllerHome];
    UINavigationController* pNavContrCate = [[UINavigationController alloc] initWithRootViewController:pControllerCate];
    UINavigationController* pNavContrCart = [[UINavigationController alloc] initWithRootViewController:pControllerCart];
    UINavigationController* pNavContrMine = [[UINavigationController alloc] initWithRootViewController:pControllerMine];
    
    [pNavContrHome setNavigationBarHidden:YES animated:YES];
    [pNavContrCate setNavigationBarHidden:YES animated:YES];
    [pNavContrCart setNavigationBarHidden:YES animated:YES];
    [pNavContrMine setNavigationBarHidden:YES animated:YES];
    
    RDVTabBarController *tabBarController = [[RDVTabBarController alloc] init];
    [tabBarController setViewControllers:@[pNavContrHome, pNavContrCate, pNavContrCart, pNavContrMine]];
    
    //self.viewController = tabBarController;
    
    NSArray *tabBarItemImagesNor = @[@"bottom_home_nor", @"bottom_cate_nor", @"bottom_cart_nor",@"bottom_mine_nor"];
    NSArray *tabBarItemImagesSel = @[@"bottom_home_sel", @"bottom_cate_sel", @"bottom_cart_sel",@"bottom_mine_sel"];
    
    NSInteger index = 0;
    for ( RDVTabBarItem *item in [[tabBarController tabBar] items] )
    {
        UIImage *imgNor = [UIImage imageNamed:[tabBarItemImagesNor objectAtIndex:index]];
        UIImage *imgSel = [UIImage imageNamed:[tabBarItemImagesSel objectAtIndex:index]];
        
        [item setFinishedSelectedImage:imgSel withFinishedUnselectedImage:imgNor];
        
        [item setBackgroundColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1]];
        index++;
    }
    
    [window setRootViewController:tabBarController];
    
    [pNavContrHome release];
    [pNavContrCate release];
    [pNavContrCart release];
    [pNavContrMine release];
    
    [pControllerHome release];
    [pControllerCate release];
    [pControllerCart release];
    [pControllerMine release];
    
    // 闪屏特效
    UIImageView *splashImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"splash"]];
    [splashImageView setFrame:window.frame];
    splashImageView.alpha = 1;
    [window addSubview:splashImageView];
    [splashImageView release];
    
    [UIView animateWithDuration:2 animations:^{
        splashImageView.alpha = 0;
    } completion:^(BOOL finished) {
        [splashImageView removeFromSuperview];
    }];
    
}
- (void)startIpadAPP:(UIWindow*)window
{
    HomeViewController_ipa*     pControllerHome     = [[HomeViewController_ipa alloc] init];
    CateViewController_ipa*     pControllerCate     = [[CateViewController_ipa alloc] init];
    CartViewController_ipa*     pControllerCart     = [[CartViewController_ipa alloc] init];
    MineViewController_ipa*     pControllerMine     = [[MineViewController_ipa alloc] init];
    
    UINavigationController* pNavContrHome = [[UINavigationController alloc] initWithRootViewController:pControllerHome];
    UINavigationController* pNavContrCate = [[UINavigationController alloc] initWithRootViewController:pControllerCate];
    UINavigationController* pNavContrCart = [[UINavigationController alloc] initWithRootViewController:pControllerCart];
    UINavigationController* pNavContrMine = [[UINavigationController alloc] initWithRootViewController:pControllerMine];
    
    [pNavContrHome setNavigationBarHidden:YES animated:YES];
    [pNavContrCate setNavigationBarHidden:YES animated:YES];
    [pNavContrCart setNavigationBarHidden:YES animated:YES];
    [pNavContrMine setNavigationBarHidden:YES animated:YES];
    
    RDVTabBarController *tabBarController = [[RDVTabBarController alloc] init];
    [tabBarController setViewControllers:@[pNavContrHome, pNavContrCate, pNavContrCart, pNavContrMine]];
    
    //self.viewController = tabBarController;
    
    NSArray *tabBarItemImagesNor = @[@"bottom_home_nor", @"bottom_cate_nor", @"bottom_cart_nor",@"bottom_mine_nor"];
    NSArray *tabBarItemImagesSel = @[@"bottom_home_sel", @"bottom_cate_sel", @"bottom_cart_sel",@"bottom_mine_sel"];
    
    NSInteger index = 0;
    for ( RDVTabBarItem *item in [[tabBarController tabBar] items] )
    {
        UIImage *imgNor = [UIImage imageNamed:[tabBarItemImagesNor objectAtIndex:index]];
        UIImage *imgSel = [UIImage imageNamed:[tabBarItemImagesSel objectAtIndex:index]];
        
        [item setFinishedSelectedImage:imgSel withFinishedUnselectedImage:imgNor];
        
        [item setBackgroundColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1]];
        index++;
    }
    
    [window setRootViewController:tabBarController];
    
    [pNavContrHome release];
    [pNavContrCate release];
    [pNavContrCart release];
    [pNavContrMine release];
    
    [pControllerHome release];
    [pControllerCate release];
    [pControllerCart release];
    [pControllerMine release];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [self startIphoneAPP:self.window];
    }
    else
    {
        [self startIpadAPP:self.window];
    }
    
    
    [[DataCenter sharedDataCenter] initLoginInfo];
    [[NetworkModel sharedNetworkModel] request_Session_Verify_Datasuc];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
