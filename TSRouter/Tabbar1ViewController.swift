
//
//  Tabbar1ViewController.swift
//  TSRouter
//
//  Created by huangyuchen on 2018/6/12.
//  Copyright © 2018年 caiqr. All rights reserved.
//

import UIKit

class Tabbar1ViewController: UIViewController, TSRouterProtocol {

    func initWithRouter(routerData: [String : String]) {
        
        //some code
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(buttonOnClick), for: UIControlEvents.touchUpInside)
        view.addSubview(button)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func buttonOnClick() {
        
        
        TSRouter.openUrl("mjlottery://test/Home")
    }

}
