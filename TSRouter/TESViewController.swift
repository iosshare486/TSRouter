//
//  TSTestViewController.swift
//  TSRouter
//
//  Created by huangyuchen on 2018/6/7.
//  Copyright © 2018年 caiqr. All rights reserved.
//
import UIKit

class MJNavController: UINavigationController {
    
    
    
}

class TSTestViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .blue
        
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(buttonOnClick), for: UIControl.Event.touchUpInside)
        view.addSubview(button)
        // Do any additional setup after loading the view.
    }
    
    @objc func buttonOnClick() {
        
        TSRouter.openUrl("mjlottery://vc/Home")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
