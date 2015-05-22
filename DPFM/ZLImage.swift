//
//  ZLImage.swift
//  DPFM
//
//  Created by ZLMac on 15/5/5.
//  Copyright (c) 2015年 lgwh. All rights reserved.
//

import UIKit

class ZLImage: UIImageView {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //设置圆角
        
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.size.width/2
        
        //边框
        self.layer.borderWidth = 4;
        self.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7).CGColor
        
        
    }
    //旋转
    func onRotation(){
        //动画关键字
        var animation = CABasicAnimation(keyPath: "transform.rotation")
        //初始值
        animation.fromValue = 0.0
        //结束值
        animation.toValue = M_PI*2.0
        //动画执行时间
        animation.duration = 20;
        //动画重复次数
        animation.repeatCount = 100000
        self.layer.addAnimation(animation, forKey: nil)
    }


}
