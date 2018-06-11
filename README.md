#Router接口定义
###使用说明
	1.func openUrl(_ url: String) 跳转方法
> url定义：URLScheme://moduleName.transitionStyle/pageName?key=value....#isNeedLogin
> 
> URLScheme: appScheme 主要作用外部连接打开客户端
> 
> moduleName: 模块名称 即url.host
> 
> pageName: 要去的页面名称 即url.path
> 
> transitionStyle: 转场动画的模式 push present
> 
> key=value: 页面入参 可以添加多个，以&链接 即url.query
>	
> isNeedLogin: 是否需要登录支持 即url.fragment
	
		
###安装说明
	
	1.var transferOriginViewController: (()->UIViewController?)?
> 获取跳转页面时需要的nav或者vc,用于push或present 该方法需要各自实现

	2.var presentDestinationViewController: ((_ destination: UIViewController)->UIViewController)?
> //自定义 present 需要创建的vc是否需要添加nav，或者nav是自定义的

	3.func initWithRouter(routerData: [String: String])
> 协议方法，需要每个模块自己实现；每个支持Router跳转并需要参数的VC都需要实现该协议


###关于回调问题
	1.目前想法是：<暂未实现>
> AVC push BVC时，若AVC需要BVC的回调，则在AVC注册回调方法给Router，并将回调方法名以参数的形式传入给BVC，BVC收到方法名后在回调时用Router.openCallBack()