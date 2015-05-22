//
//  ChannelController.swift
//  DPFM
//
//  Created by ZLMac on 15/5/5.
//  Copyright (c) 2015年 lgwh. All rights reserved.
//

import UIKit
protocol ChannelProtocol{
    func onChangeChannel(channel_id:String)
}
class ChannelController: UIViewController,UITableViewDataSource,UITableViewDelegate{

    @IBOutlet weak var channelTV: UITableView!
    var delegate:ChannelProtocol?
    var channelData:[JSON] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        view.alpha = 0.8
        
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelData.count;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let  cell = channelTV.dequeueReusableCellWithIdentifier("channel") as! UITableViewCell
        
        let rowData:JSON = self.channelData[indexPath.row] as JSON
        cell.textLabel?.text = rowData["name"].string
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let rowData:JSON = self.channelData[indexPath.row] as JSON
        
        let channel_id:String = rowData["channel_id"].stringValue
        delegate?.onChangeChannel(channel_id)
        dismissViewControllerAnimated(true, completion: nil)
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //设置cell的显示动画为3d播放，xy方向的播放动画，初始值为0.1，结束值为1
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }
    

}
