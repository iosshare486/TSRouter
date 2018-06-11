//
//  TSRouterProtocol.swift
//  TSRouter
//
//  Created by huangyuchen on 2018/6/6.
//  Copyright © 2018年 caiqr. All rights reserved.
//
import UIKit
public @objc protocol TSRouterProtocol {
    
    //协议方法 需要使用者在支持router的vc中遵守此协议
    func initWithRouter(routerData: [String: String])
    
}



