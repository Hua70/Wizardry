//
//  ViewController.swift
//  Wizardry
//
//  Created by YWH on 15/11/13.
//  Copyright © 2015年 YWH. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    @IBOutlet weak var backGroundImage: UIImageView!
    // MARK: -Lift Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSURL(string: "http://xiuxiu.sj.meitudata.com/weixin/54d31d9084b3a89.jpg")
        let imageData = NSData(contentsOfURL: url!)
        if imageData != nil{
            backGroundImage.image = UIImage(data: imageData!)
        }
     
        
    }
    required init?(coder aDecoder: NSCoder) {
        print("init ViewController")
        super.init(coder: aDecoder)
    }
    
    deinit {
        print("deinit ViewController")
    }
    @IBAction func backToHome(segue:UIStoryboardSegue)  {
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    //MARK:-Private Method
    
    //MARK:-Action
  
}

