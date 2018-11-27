//
//  ViewController3.swift
//  CustomTransition
//
//  Created by wf on 2018/11/7.
//  Copyright © 2018 sohu. All rights reserved.
//

import UIKit

class ViewController3: UIViewController {

    deinit {
        print("ViewController3 deinit......")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 100, y: 100, width: 100, height: 40)
        btn.setTitle("button", for: .normal)
        btn.setTitleColor(UIColor.red, for: .normal)
        btn.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
        self.view.addSubview(btn)
        
        
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 20, y: 20, width: 32, height: 32)
        backBtn.setBackgroundImage(UIImage(named: "ic_back_black_normal"), for: .normal)
        backBtn.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        self.view.addSubview(backBtn)
    }
    
    @IBAction func btnAction(_ sender: Any) {
        let vc = ViewController4()
        self.containerVC.push(viewController: vc, completion: nil)
    }

    @objc func backAction(_ sender: Any) {
        
        self.containerVC.pop()
        
    }

}
