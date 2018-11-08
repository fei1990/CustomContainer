//
//  ViewController.swift
//  CustomTransition
//
//  Created by wf on 2018/11/5.
//  Copyright © 2018 sohu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func btnAction(_ sender: Any) {
        
        let vc1 = ViewController1()

        let na = ContainerViewController(rootVC: vc1, presentingVC: self)

        na.present(viewController: vc1, completion: nil)
//        na.push(viewController: vc1)
        
        
        
//        let vc2 = ViewController2()
//        self.navigationController?.pushViewController(vc2, animated: true)
        
    }
    
    
    
}
