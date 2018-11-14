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
    }
    
    @IBAction func btnAction(_ sender: Any) {
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
