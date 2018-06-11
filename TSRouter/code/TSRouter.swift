//
//  TSRouter.swift
//  TSRouter
//
//  Created by huangyuchen on 2018/6/6.
//  Copyright © 2018年 caiqr. All rights reserved.
//

import UIKit

//plist文件中的字段名
private let kTSRouterClassName = "className"
private let kTSRouterTransferStyle = "transferStyle"


class TSRouter {
    
    static let shared: TSRouter = TSRouter()
    private init() {}
    
    //自定义页面跳转的源vc
    var transferOriginViewController: (()->UIViewController?)?
    
    //自定义 present 需要创建的vc是否需要添加nav，或者nav是自定义的
    var presentDestinationViewController: ((_ destination: UIViewController)->UIViewController)?
    
    //跳转⽅方法
    func openUrl(_ urlStr: String?) {
        
        //首先解析url
        if let tempStr = urlStr {
            
            if let url = URL(string: tempStr) {
                var parser = parserUrl(url: url)
                transferViewController(parser: &parser)
            }
        }
    }
    
}

// MARK: - 跳转相关
fileprivate extension TSRouter {
    
    //执行跳转
    func transferViewController(parser: inout TSParser) {
        
        //获取目标VC
        getActionTransferViewController(with: &parser)
        //获取源VC
        getOriginViewController(with: &parser)
        
        guard let destination = parser.destinationViewController else {
            
            debugPrint("TSRouter: destinationViewController is nil")
            return
        }
        
        guard let originViewController = parser.originViewController else {
            
            debugPrint("TSRouter: originViewController is nil")
            return
        }
        
        if parser.transferStyle == .push {
            
            guard originViewController.isKind(of: UINavigationController.self) else {
                
                debugPrint("TSRouter: transferStyle is push, but originViewController isnot UINavigationController")
                return
            }
            
            (originViewController as! UINavigationController).pushViewController(destination, animated: true)
        } else {
            
            if (self.presentDestinationViewController != nil) {
                
                originViewController.present(self.presentDestinationViewController!(destination), animated: true, completion: nil)
            }else {
                originViewController.present(destination, animated: true, completion: nil)
            }
        }
    }
    
    //根据parser获取对应的vc
    func getActionTransferViewController(with parser: inout TSParser) {
        
        let filepath = Bundle.main.path(forResource: parser.host, ofType: "plist")
        let dic = NSDictionary(contentsOfFile: filepath!)
        let rule = dic?.object(forKey: parser.path) as? NSDictionary
        
        if rule == nil {
            debugPrint("TSRouter: path is not find")
            return
        }
        
        let class_name = rule!.object(forKey: kTSRouterClassName) as! String
        let cls: AnyClass? = NSClassFromString(Bundle.main.tsrouter_nameSpace + "." + class_name)
        guard let clsType = cls as? UIViewController.Type else {
            debugPrint("TSRouter: get class is not viewController")
            return
        }
        
        let viewController = clsType.init()
        
        if viewController.conforms(to: TSRouterProtocol.self) {
            
            (viewController as! TSRouterProtocol).initWithRouter(routerData: parser.URLParser)
        }
        
        parser.destinationViewController = viewController
        if let modelStr = rule!.object(forKey: kTSRouterTransferStyle) {
            parser.transferStyle = TSRouterTransferStyle.init(rawValue: modelStr as! String) ?? .push
        }
    }
    
    //获取源vc
    func getOriginViewController(with parser: inout TSParser) {
        
        if (self.transferOriginViewController != nil) {

            parser.originViewController = self.transferOriginViewController?()
        }else {
         
            parser.originViewController = defaultGetOriginVC()
        }
    }
    //获取源VC需要使用者自定义，若不自定义则通用的获取方法
    func defaultGetOriginVC() -> UIViewController? {
        
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
        let path = url.path
        let startIndex = path.index(path.startIndex, offsetBy: 1)
        
        parser.path = String(path[startIndex..<path.endIndex])
        
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
    var destinationViewController: UIViewController?
    var originViewController: UIViewController?
    var transferStyle: TSRouterTransferStyle = .push //跳转方式 默认push
}

fileprivate enum TSRouterTransferStyle: String {
    
    case push = "push"
    case present = "present"
}


fileprivate extension Bundle {
    var tsrouter_nameSpace: String {
        return infoDictionary?["CFBundleName"] as? String ?? ""
    }
}
