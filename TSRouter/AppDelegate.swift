//
//  AppDelegate.swift
//  TSRouter
//
//  Created by huangyuchen on 2018/6/6.
//  Copyright © 2018年 caiqr. All rights reserved.
//

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let tabbar = UITabBarController()
        
        let vc1 = MJNavController(rootViewController: Tabbar1ViewController())
        let awardItem = UITabBarItem(title: "预测", image: nil, selectedImage: nil)
        awardItem.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12)], for: .normal)
        awardItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)], for: .selected)
        vc1.tabBarItem = awardItem
        
        let vc2 = MJNavController(rootViewController: Tabbar2ViewController())
        let awardItem2 = UITabBarItem(title: "预测1", image: nil, selectedImage: nil)
        awardItem2.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12)], for: .normal)
        awardItem2.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)], for: .selected)
        vc2.tabBarItem = awardItem2
        
        let vc3 = MJNavController(rootViewController: Tabbar3ViewController())
        let awardItem3 = UITabBarItem(title: "预测2", image: nil, selectedImage: nil)
        awardItem3.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12)], for: .normal)
        awardItem3.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)], for: .selected)
        vc3.tabBarItem = awardItem3
        
        tabbar.viewControllers = [vc1, vc2, vc3]
        
        self.window?.rootViewController = tabbar
        self.window?.makeKeyAndVisible()
        
        TSRouter.shared.presentDestinationViewController = { (viewController) in
            
            return UINavigationController(rootViewController: viewController)
        }
        
        TSRouter.shared.transferOriginViewController = {
            
            let currentAppDele = UIApplication.shared.delegate as! AppDelegate
            
            if currentAppDele.window?.rootViewController == nil {
                debugPrint("TSRouter: window.rootViewController is not find")
                return nil
            }
            
            let rootVC: UIViewController = (currentAppDele.window?.rootViewController)!
            var topVC: UIViewController?
            if rootVC is UITabBarController {
                topVC = (rootVC as! UITabBarController).selectedViewController
            } else if rootVC is UINavigationController  {
                topVC = rootVC
            }
            
            while ((topVC?.presentedViewController) != nil) {
                topVC = (topVC?.presentedViewController)!
            }
            
            return topVC
            
        }
        
        TSRouter.shared.transferTabbarViewController = {
            
            let currentAppDele = UIApplication.shared.delegate as! AppDelegate
            
            return (currentAppDele.window?.rootViewController)! as! UITabBarController
        }
        
        TSRouter.shared.transferSpecialViewControllers = { (vc ,parh, dic) in
            
            let vc1 = Tabbar1ViewController()
            vc.present(vc1, animated: true, completion: nil)
        }
        
        return true
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

