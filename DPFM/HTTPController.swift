//
//  HTTPController.swift
//  DPFM
//
//  Created by ZLMac on 15/5/5.
//  Copyright (c) 2015年 lgwh. All rights reserved.
//

import UIKit
class HTTPController:NSObject {
    //定义代理
    var delegate:HttpProtocol?
    //接收网址，回调代理的方法返回数据
    func onSearch(url:String){
        Alamofire.manager.request(Method.GET,url).responseJSON(options:NSJSONReadingOptions.MutableContainers ) { (_, _, data, error) -> Void in
         self.delegate?.didRecieveResults(data!)
        }
    }
}
//定义协议
protocol HttpProtocol {
    //定义一个方法，接收参数：AnyObject
    func didRecieveResults(result:AnyObject)
}
