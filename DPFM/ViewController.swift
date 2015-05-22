//
//  ViewController.swift
//  DPFM
//
//  Created by ZLMac on 15/5/5.
//  Copyright (c) 2015年 lgwh. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,HttpProtocol,ChannelProtocol {
    // 歌曲封面
    @IBOutlet weak var iv: ZLImage!
    //歌曲列表
    @IBOutlet weak var tv: UITableView!
    //歌曲背景
    @IBOutlet weak var bg: UIImageView!
    
    //网络操作类的实例
    var zlHttp:HTTPController = HTTPController()
    
    //定义一个变量，接收频道的歌曲数据
    var tableData:[JSON] = []
    
    //频道数据
    var channelData:[JSON] = []
    
    //缓存图片
    
    var imageCache = Dictionary<String,UIImage>()
    
    //定义播放实例
    
    var audioPlayer:MPMoviePlayerController = MPMoviePlayerController()
    
    //申明计时器
    
    var timer:NSTimer?
    
    
    @IBOutlet weak var playTime: UILabel!
    @IBOutlet weak var progress: UIImageView!
    
    
    @IBOutlet weak var btnPre: UIButton!
    @IBOutlet weak var btnPlay: ZLButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnOrder: OrderButton!
    
    
    var currentIndex:Int = 0
    
    var isAutoFinish:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        iv.onRotation()
        //设置背景模糊
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame.size = CGSize(width: view.frame.size.width, height: view.frame.size.height)
        bg.addSubview(blurView)
        //设置tableView的数据源和代理
        tv.delegate = self
        tv.dataSource = self
        
        //设置网络操作类的代理
         zlHttp.delegate = self
         zlHttp.onSearch("http://www.douban.com/j/app/radio/channels")
         zlHttp.onSearch("http://douban.fm/j/mine/playlist?type=n&channel=0&from=mainsite")
        
        //背景透明
        self.tv.backgroundColor = UIColor .clearColor()
        self.tv.tableFooterView = UIView()
        
        btnNext.addTarget(self, action: "onClick:", forControlEvents: UIControlEvents.TouchUpInside)
        btnPlay.addTarget(self, action: "onPlay:", forControlEvents: UIControlEvents.TouchUpInside)
        btnPre.addTarget(self, action: "onClick:", forControlEvents: UIControlEvents.TouchUpInside)
        btnOrder.addTarget(self, action: "onOrder:", forControlEvents: UIControlEvents.TouchUpInside)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"playFinish", name: MPMoviePlayerPlaybackDidFinishNotification,object:audioPlayer)
    }
    
    func playFinish(){
        if isAutoFinish {
        switch(btnOrder.order){
            case 1:
                currentIndex++
                if currentIndex > self.tableData.count - 1{
                    currentIndex = 0
            }
            OnSelectRow(currentIndex)
            case 2:
             currentIndex = random() % tableData.count
            OnSelectRow(currentIndex)
            case 3:
            OnSelectRow(currentIndex)
        default:
            ""
        }
        }else {
            isAutoFinish = true
        }
    }
    func onClick(btn:UIButton) {
        
        isAutoFinish = false
        if btn == btnNext  {
            currentIndex++
            if currentIndex > self.tableData.count - 1{
                currentIndex = 0
            }
            
        }else {
            currentIndex--
            if currentIndex < 0{
                currentIndex = self.tableData.count - 1
            }
            
        }
        OnSelectRow(currentIndex)
    }
    func onPlay(btn:ZLButton) {
       if btn.isPlay {
            audioPlayer.play()
       }else {
            audioPlayer.pause()
        }
    }
    func onOrder(btn:OrderButton){
        var message:String = ""
        switch(btn.order){
            case 1:
            message = "顺序播放"
            case 2:
            message = "随机播放"
            case 3:
            message = "单曲循环"
            default:
            message = ""
            
        }
        self.view.makeToast(message: message, duration: 0.5, position: "center")
    }
    func  tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let  cell = tv.dequeueReusableCellWithIdentifier("doupan") as! UITableViewCell
        cell.backgroundColor = UIColor.clearColor()
        //获取每一行是数据
        let rowData:JSON = tableData[indexPath.row];
        cell.textLabel?.text = rowData["title"].string
        cell.detailTextLabel?.text = rowData["artist"].string
        cell.imageView?.image = UIImage(named: "thumb")
        
        let url = rowData["picture"].string
        onGetCacheImage(url!, imgView: cell.imageView!)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        isAutoFinish = false
        OnSelectRow(indexPath.row)
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //设置cell的显示动画为3d播放，xy方向的播放动画，初始值为0.1，结束值为1
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }
    func didRecieveResults(result: AnyObject) {
        let json = JSON(result)
        println("\(json)")
        //判断数据
        
        if let channels = json["channels"].array{
            self.channelData = channels
        }else if let song = json["song"].array{
            isAutoFinish = false
            self.tableData = song
            self.tv.reloadData()
            OnSelectRow(0)
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var channelVC:ChannelController = segue.destinationViewController as! ChannelController
        channelVC.delegate = self
        channelVC.channelData = self.channelData
    }
    //频道列表协议的回调方法
    func onChangeChannel(channel_id: String) {
        
        let urlString = "http://douban.fm/j/mine/playlist?type=n&channel=\(channel_id)&from=mainsite"
        zlHttp.onSearch(urlString)
    }
    
    func OnSelectRow(index:Int){
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        tv.selectRowAtIndexPath(indexPath!, animated: false, scrollPosition: UITableViewScrollPosition.Top)
        
        var rowData:JSON = self.tableData[index] as JSON
        let imgUrl = rowData["picture"].string
         onSetImage(imgUrl!)
        
        //获取音乐的文件地址
        var urlString = rowData["url"].string!
        //播放音乐
        onSetAudio(urlString)
        
    }
    func onSetImage(url:String) {
        onGetCacheImage(url,imgView:self.iv)
        onGetCacheImage(url,imgView:self.bg)
        
    }
    func onGetCacheImage(url:String,imgView:UIImageView) {
        
        let image = self.imageCache[url] as UIImage?
        if image == nil {
            Alamofire.manager.request(Method.GET,url).response({ (_, _, data, error) -> Void in
                let img = UIImage(data: data! as! NSData)
                imgView.image = img
                self.imageCache[url] = img
            })

        }else {
            imgView.image = image!
        }
        
    }
    
    //播放歌曲
    func onSetAudio(url:String){
        
        self.audioPlayer.stop()
        self.audioPlayer.contentURL = NSURL(string: url)
        self.audioPlayer.play()
        
        timer?.invalidate()
        playTime.text = "00:00"
        timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "onUpdate", userInfo: nil, repeats: true)
        isAutoFinish = false
    }
    func onUpdate(){
        let c = audioPlayer.currentPlaybackTime
        if c>0.0{
            
            //歌曲总时间
            let t = audioPlayer.duration
            let pro:CGFloat = CGFloat(c/t)
            progress.frame.size.width = view.frame.size.width * pro
            let all:Int = Int(c)
            let m:Int = all%60
            let f:Int = Int(all/60)
            var time:String = ""
            if f<10{
                time = "0\(f):"
            }else {
                time = "\(f):"
            }
            if m<10{
                time+="0\(m)"
            }else {
                time+="\(m)"
            }
             playTime.text = time
        }
       
    }

}

