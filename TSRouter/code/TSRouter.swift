//
//  TSRouter.swift
//  TSRouter
//
//  Created by huangyuchen on 2018/6/6.
//  Copyright © 2018年 caiqr. All rights reserved.
//

import UIKit

//plist文件中的字段名
fileprivate let kTSRouterClassName = "className"
fileprivate let kTSRouterTransferStyle = "transferStyle"


public class TSRouter {
    
    public static let shared: TSRouter = TSRouter()
    private init() {}
    private var blockedParser: TSParser?  //记录被打断的跳转数据，以备回调之后继续跳转（如未登录需要跳转登录时会被打断）
    
    /// 存储类名的plist文件名，如果配置了则以配置为准，否则以url.path为准
    public var moduleName: String?
    
    /// scheme (如果url.scheme不是配置的会直接使用UIApplication.shared.openUrl)
    public var scheme: String?
    
    /// 自定义跳转webView
    public var transferWebViewControllers: ((_ url: String)->Void)?
    
    // 自定义页面跳转的源vc
    public var transferOriginViewController: (()->UIViewController?)?
    
    // 自定义 present 需要创建的vc是否需要添加nav，或者nav是自定义的
    public var presentDestinationViewController: ((_ destination: UIViewController)->UIViewController)?
    
    // 获取tabbar，用于切换tabbarItem
    public var transferTabbarViewController: (()->UITabBarController?)?
    
    // 特殊controller跳转需要开发者自定义
    public var transferSpecialViewControllers: ((_ currentVC: UIViewController, _ path: String, _ parserDic: [String: String])->Void)?
    
    // 跳转页面如需依赖特殊状态（例如登录）
    public var transferNeedRelySpecialStatus: ((_ currentVC: UIViewController)-> Bool)?
    
    //通用跳转方法
    public class func openUrl(_ urlStr: String?) {
        
        TSRouter.shared.openUrl(urlStr)
    }
    
    //直接 push vc
    public class func routerPushVC(_ vc: UIViewController, _ animate: Bool = true) {
        
        TSRouter.shared.routerPushVC(vc, animate)
    }
    
    //直接 present vc
    public class func routerPresentVC(_ vc: UIViewController, _ animate: Bool = true, completion: (() -> Swift.Void)? = nil) {
        
        TSRouter.shared.routerPresentVC(vc, animate, completion: completion)
    }
    
    //pop
    public class func routerPop(animate: Bool = true) {
        
        TSRouter.shared.routerPop(animate: animate)
    }
    
    //dismiss
    public class func routerDismiss(animated: Bool, completion: (() -> Void)?) {
        
        TSRouter.shared.routerDismiss(animated: animated, completion: completion)
    }
    
    //继续跳转 当跳转被打断后，调用该方法会继续上次的跳转
    public class func continueRouter() {
        
        if let parser = TSRouter.shared.blockedParser {
            TSRouter.shared.transferViewController(with: parser)
        }
    }
}

fileprivate extension TSRouter {
    
    //跳转url
    func openUrl(_ urlStr: String?) {
        
        //首先解析url
        if let tempStr = urlStr {
            
            if tempStr.hasPrefix("http") {
                //跳转webView
                self.transferWebViewControllers?(tempStr)
            }else {
                
                if let url = URL(string: tempStr) {
                    if let schemeStr = self.scheme {
                        if tempStr.hasPrefix(schemeStr) {
                            var parser = parserUrl(url: url)
                            configDataForTransferViewController(parser: &parser)
                        }
                    }else {
                        if UIApplication.shared.canOpenURL(url) {
                            
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            } else {
                                UIApplication.shared.openURL(url)
                            }
                        }
                    }
                    
                }else {
                    debugPrint("TSRouter: urlStr isnot url")
                }
                
                
            }
        }else {
            
            debugPrint("TSRouter: url is nil")
        }
    }
    
    //直接push VC
    func routerPushVC(_ vc: UIViewController, _ animate: Bool = true) {
        
        if let originVC = self.transferOriginViewController?() {
            
            if originVC is UINavigationController {
                vc.hidesBottomBarWhenPushed = true
                (originVC as! UINavigationController).pushViewController(vc, animated: animate)
            }else {
                debugPrint("TSRouter: transferOriginViewController is not UINavigationController")
            }
        }else {
            debugPrint("TSRouter: transferOriginViewController is nil")
        }
    }
    
    //直接present VC
    func routerPresentVC(_ vc: UIViewController, _ animate: Bool = true, completion: (() -> Swift.Void)? = nil) {
        
        if let originVC = self.transferOriginViewController?() {
            
            originVC.present(vc, animated: animate, completion: completion)
        }else {
            debugPrint("TSRouter: transferOriginViewController is nil")
        }
    }
    
    //pop
    func routerPop(animate: Bool = true) {
        
        if let originVC = self.transferOriginViewController?() {
            
            if originVC is UINavigationController {
                
                (originVC as! UINavigationController).popViewController(animated: animate)
            }else {
                debugPrint("TSRouter: transferOriginViewController is not UINavigationController")
            }
        }else {
            debugPrint("TSRouter: transferOriginViewController is nil")
        }
    }
    
    //dismiss
    func routerDismiss(animated: Bool, completion: (() -> Void)?) {
        
        if let originVC = self.transferOriginViewController?() {
            
            originVC.dismiss(animated: animated, completion: completion)
        }else {
            debugPrint("TSRouter: transferOriginViewController is nil")
        }
    }
    
}

// MARK: - 普通跳转相关
fileprivate extension TSRouter {
    
    //执行跳转前的数据处理
    func configDataForTransferViewController(parser: inout TSParser) {
        
        //获取目标VC
        getActionTransferViewController(with: &parser)
        //获取源VC
        getOriginViewController(with: &parser)
        
        guard let originViewController = parser.originViewController else {
            
            debugPrint("TSRouter: originViewController is nil")
            return
        }
        
        if parser.fragment == "1" {
            //表示跳转页面需要依赖某些状态，例如登录
            if self.transferNeedRelySpecialStatus != nil {
                
                let result = self.transferNeedRelySpecialStatus!(originViewController)
                
                if result == false {
                    //如果返回结果为false表示打断当前的跳转
                    debugPrint("TSRouter: 当前跳转被打断")
                    self.blockedParser = parser
                    return
                }
            }
        }
        
        transferViewController(with: parser)
    }
    
    //执行跳转
    func transferViewController(with parser: TSParser) {
        
        if parser.transferStyle == .tabTransfer {
            
            self.transferTabbarSelectVC(with: parser)
            
        }
        
        guard let originViewController = parser.originViewController else {
            
            debugPrint("TSRouter: originViewController is nil")
            return
        }
        
        if parser.transferStyle == .specialTransfer {
            
            if self.transferSpecialViewControllers != nil {
                
                self.transferSpecialViewControllers!(originViewController, parser.host, parser.URLParser)
            }else {
                debugPrint("TSRouter: transferSpecialViewControllers is nil")
            }
        }
        
        guard let destination = parser.destinationViewController else {
            
            debugPrint("TSRouter: destinationViewController is nil")
            return
        }
        
        
        if parser.transferStyle == .push {
            
            guard originViewController.isKind(of: UINavigationController.self) else {
                
                debugPrint("TSRouter: transferStyle is push, but originViewController isnot UINavigationController")
                return
            }
            
            (originViewController as! UINavigationController).pushViewController(destination, animated: true)
        } else if parser.transferStyle == .present {
            
            if (self.presentDestinationViewController != nil) {
                
                originViewController.present(self.presentDestinationViewController!(destination), animated: true, completion: nil)
            }else {
                if self.presentDestinationViewController != nil {
                    
                    originViewController.present(self.presentDestinationViewController!(destination), animated: true, completion: nil)
                }else {
                    originViewController.present(destination, animated: true, completion: nil)
                }
                
            }
        }else {
            debugPrint("TSRouter: transferStyle is nil")
        }
        
    }
    
    //根据parser获取对应的vc
    func getActionTransferViewController(with parser: inout TSParser) {
        
        let filepath = Bundle.main.path(forResource: parser.path, ofType: "plist")
        let dic = NSDictionary(contentsOfFile: filepath!)
        let rule = dic?.object(forKey: parser.host) as? NSDictionary
        if rule == nil {
            debugPrint("TSRouter: path is not find")
            return
        }
        if let modelStr: String = rule!.object(forKey: kTSRouterTransferStyle) as? String {
            parser.transferStyle = TSRouterTransferStyle.init(rawValue: modelStr )
        }else {
            debugPrint("TSRouter: plist not have transferStyle")
        }
        
        guard let class_name: String = rule!.object(forKey: kTSRouterClassName) as? String else {
            
            debugPrint("TSRouter: plist not have className")
            return
        }
        
        let cls: AnyClass? = NSClassFromString(Bundle.main.tsrouter_nameSpace + "." + class_name)
        guard let clsType = cls as? UIViewController.Type else {
            debugPrint("TSRouter: get class is not viewController")
            return
        }
        
        let viewController = clsType.init()
        viewController.hidesBottomBarWhenPushed = true
        if viewController.conforms(to: TSRouterProtocol.self) {
            
            (viewController as! TSRouterProtocol).initWithRouter(routerData: parser.URLParser)
        }
        
        parser.destinationViewControllerName = class_name
        
        parser.destinationViewController = viewController
        
    }
    
    //获取源vc
    func getOriginViewController(with parser: inout TSParser) {
        
        if (self.transferOriginViewController != nil) {
            
            parser.originViewController = self.transferOriginViewController?()
        }else {
            
            debugPrint("TSRouter: transferOriginViewController is nil")
        }
    }
}

// MARK: - tabbar的切换
fileprivate extension TSRouter {
    
    func transferTabbarSelectVC(with parser: TSParser) {
        
        if let tabbar = self.transferTabbarViewController?(), let viewcontrollers = tabbar.viewControllers, let className = parser.destinationViewControllerName, let vcclass = NSClassFromString(Bundle.main.tsrouter_nameSpace + "." + className) {
            
            if let currentSelect = tabbar.selectedViewController {
                
                if currentSelect.presentedViewController != nil {
                    currentSelect.presentedViewController?.dismiss(animated: false, completion: nil)
                }
                
                if currentSelect is UINavigationController {
                    
                    (currentSelect as! UINavigationController).popToRootViewController(animated: false)
                }
                
                for (i, subVC) in viewcontrollers.enumerated() {
                    
                    if subVC is UINavigationController {
                        
                        if let vc = (subVC as! UINavigationController).viewControllers.last {
                            
                            if vc.isKind(of: vcclass) {
                                
                                tabbar.selectedIndex = i
                                return
                            }
                        }
                        
                    }else {
                        
                        if subVC.isKind(of: vcclass) {
                            
                            tabbar.selectedIndex = i
                            return
                        }
                    }
                    
                }
                
                
            }else {
                
                debugPrint("TSRouter: tabbarViewController selectedViewController is nil")
            }
            
        }else {
            
            debugPrint("TSRouter: tabbar is nil")
        }
        
    }
}

// MARK: - 解析Url 相关
fileprivate extension TSRouter {
    
    //解析URl
    //url定义：URLScheme://moduleName/pageName?transferStyle&key=value....#isNeedLogin
    func parserUrl(url: URL) -> TSParser {
        
        let parser = TSParser()
        parser.originURL = url
        //scheme
        if let scheme = url.scheme {
            parser.URLScheme = scheme
        }
        if let fragment = url.fragment {
            parser.fragment = fragment
        }
        //host
        if let host = url.host {
            parser.host = host
        }
        //path
        if self.moduleName != nil {
            parser.path = self.moduleName!
        }else {
            
            let path = url.path
            if path.count > 0 {
                
                let startIndex = path.index(path.startIndex, offsetBy: 1)
                
                parser.path = String(path[startIndex..<path.endIndex])
            }else {
                debugPrint("TSRouter: path is nil")
            }
        }
        
        //query -> Dictionary
        if let query = url.query {
            if query.contains("&") {
                for item in query.components(separatedBy: "&") {
                    let realItem: NSString = item as NSString
                    let location = realItem.range(of: "=").location
                    if  location != NSNotFound {
                        let key = item[item.startIndex..<item.index(item.startIndex, offsetBy: location)]
                        let value = item[item.index(item.startIndex, offsetBy: location + 1)..<item.endIndex]
                        parser.URLParser.updateValue(String(value), forKey: String(key))
                    }
                    
                }
            } else if query.contains("=") {
                
                
                let item = query
                let realItem: NSString = query as NSString
                let location = realItem.range(of: "=").location
                if  location != NSNotFound {
                    let key = item[item.startIndex..<item.index(item.startIndex, offsetBy: location)]
                    let value = item[item.index(item.startIndex, offsetBy: location + 1)..<item.endIndex]
                    parser.URLParser.updateValue(String(value), forKey: String(key))
                }
            }
        }
        
        return parser
    }
    
}


/// url解析后的模型
fileprivate class TSParser {
    
    var originURL: URL! //原始url
    var URLScheme: String = ""
    var host : String = ""
    var path : String = ""
    var fragment: String = ""
    var URLParser = [String: String]()
    var destinationViewControllerName: String?
    var destinationViewController: UIViewController?
    var originViewController: UIViewController?
    var transferStyle: TSRouterTransferStyle? //跳转方式
}

public enum TSRouterTransferStyle: String {
    
    case push = "push"
    case present = "present"
    case tabTransfer = "transferTab" //tabbar 切换
    case specialTransfer = "specialTransfer" //特殊跳转
    
}


fileprivate extension Bundle {
    var tsrouter_nameSpace: String {
        return infoDictionary?["CFBundleName"] as? String ?? ""
    }
}
