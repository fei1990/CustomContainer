//
//  ViewController1.swift
//  CustomTransition
//
//  Created by wf on 2018/11/5.
//  Copyright © 2018 sohu. All rights reserved.
//

import UIKit

class ViewController1: UIViewController {

    deinit {
        print("ViewController1 deinit......")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.red
        
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 100, y: 100, width: 100, height: 40)
        btn.setTitle("button", for: .normal)
        btn.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
        self.view.addSubview(btn)
        
        
        let shadowView = UIView(frame: CGRect(x: 200, y: 10, width: 150, height: 150))
//        shadowView.backgroundColor = UIColor.blue
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: -3, height: -3)
        shadowView.layer.shadowOpacity = 0.6
        shadowView.layer.shadowPath = UIBezierPath(rect: shadowView.bounds).cgPath
//        shadowView.layer.shadowRadius = 8
        
        let v = UIView(frame: CGRect(x: 200, y: 10, width: 150, height: 150))
        v.backgroundColor = UIColor.blue
        
        self.view.addSubview(shadowView)
        self.view.addSubview(v)
        
        
        let closeBtn = UIButton(type: .custom)
        closeBtn.frame = CGRect(x: 20, y: 20, width: 32, height: 32)
        closeBtn.setBackgroundImage(UIImage(named: "ic_close_black_normal"), for: .normal)
        closeBtn.addTarget(self, action: #selector(closeAction(_:)), for: .touchUpInside)
        self.view.addSubview(closeBtn)
    }
    

    @IBAction func btnAction(_ sender: Any) {
        
        let vc2 = ViewController2()
        
        self.containerVC.push(viewController: vc2)
        
    }
    
    @objc func closeAction(_ sender: Any) {
        self.containerVC.dismiss {
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        
    }
}
