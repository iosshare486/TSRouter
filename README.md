# Router接口文档

## 接口说明

- ### 跳转时使用的接口
	1.class func openUrl(_ url: String) 跳转方法
> url定义：URLScheme://pageName/moduleName?key=value....#isNeedLogin
> 
> URLScheme: appScheme 主要作用外部连接打开客户端
> 
> pageName: 要去的页面名称 即url.host
> 
> moduleName: 模块名称 即url.path
> 
> key=value: 页面入参 可以添加多个，以&链接 即url.query
>	
> isNeedLogin: 是否需要登录支持 即url.fragment
> 

	2. public class func routerPresentVC(_ vc: UIViewController, _ animate: Bool = true, completion: (() -> Swift.Void)? = nil)

> 直接模态一个vc

	3. public class func routerPushVC(_ vc: UIViewController, _ animate: Bool = true)

> 直接 push 一个vc

	4. public class func continueRouter()

> 继续跳转 当跳转被打断后，调用该方法会继续上次的跳转

- ### 安装时使用的接口

	1. var transferOriginViewController: (()->UIViewController?)?
	
> 获取跳转页面时需要的nav或者vc,用于push或present 该方法需要各自实现

	2. var presentDestinationViewController: ((_ destination: UIViewController)->UIViewController)?
	
> 模态时，创建VC时需要特殊处理，如添加导航Nav时，需要使用者自定义

	3. public var transferTabbarViewController: (()->UITabBarController)?

> 获取tabbar，用于切换tabbarItem

	4.public var transferSpecialViewControllers: ((_ currentVC: UIViewController, _ path: String, _ parserDic: [String: String])->Void)?
	
> 实例化需要特殊处理，无法使用通用的init方法时，需要自定义跳转方法

	5. public var transferNeedRelySpecialStatus: ((_ currentVC: UIViewController)-> Bool)?

> 跳转页面如需依赖特殊状态（例如登录状态）, 该闭包返回true表示状态正确可以继续跳转，返回false表示状态不正确，打断当前跳转，如需继续跳转可调用public class func continueRouter() 

	6.func initWithRouter(routerData: [String: String])
> 协议方法，需要每个模块自己实现；每个支持Router跳转并需要参数的VC都需要实现该协议
	

### 使用说明

#### 1. 首先在AppDelegate的didFinishLaunchingWithOptions方法中分别实现如下接口
	1. var transferOriginViewController: (()->UIViewController?)?

```
例：
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
```

	2. var presentDestinationViewController: ((_ destination: UIViewController)->UIViewController)?

```
例：
	TSRouter.shared.presentDestinationViewController = { (viewController) in
            
            return UINavigationController(rootViewController: viewController)
        }	

```

	3. public var transferTabbarViewController: (()->UITabBarController)?

```
例：
	TSRouter.shared.transferTabbarViewController = {
            
            let currentAppDele = UIApplication.shared.delegate as! AppDelegate
            
            return (currentAppDele.window?.rootViewController)! as! UITabBarController
        }

```

	4. public var transferSpecialViewControllers: ((_ currentVC: UIViewController, _ path: String, _ parserDic: [String: String])->Void)?

```
例：
	TSRouter.shared.transferSpecialViewControllers = { (vc, parh, dic) in
            
            let vc1 = Tabbar1ViewController()
            vc.present(vc1, animated: true, completion: nil)
				
        }

```

#### 2. 需要跳转的VC 若需要入参 则需遵守 TSRouterProtocol 协议 并实现协议方法

```
例：
class ViewController: UIViewController, TSRouterProtocol {

    func initWithRouter(routerData: [String : String]) {
        
        //some code
        
    }
}

```

#### 3. 创建plist文件 命名以moduleName.plist, 字段分别是path为key，value是字典，字典中 transferStyle  className 表示跳转方式和对应类名

> tranferStyle包含：push,present,transferTab,specialTransfer
> 
> transferTab 表示tabbar切换
> 
> specialTransfer 表示vc需要特殊实例和跳转
> 

```

<key>vc</key>
	<dict>
		<key>transferStyle</key>
		<string>present</string>
		<key>className</key>
		<string>ViewController</string>
	</dict>
	

```

### 关于回调问题
	1.目前想法是：<暂未实现>
> AVC push BVC时，若AVC需要BVC的回调，则在AVC注册回调方法给Router，并将回调方法名以参数的形式传入给BVC，BVC收到方法名后在回调时用Router.openCallBack()
> 
> 
> 
> 
> 
> 
> 