//
//  ViewController2.swift
//  CustomTransition
//
//  Created by wf on 2018/11/5.
//  Copyright © 2018 sohu. All rights reserved.
//

import UIKit

class ViewController2: UIViewController {

    deinit {
        print("ViewController2 deinit......")
        NotificationCenter.default.removeObserver(self)
    }
    
    lazy var table: CustomTableView = {
        let t = CustomTableView(frame: CGRect(x: 0, y: 40, width: self.view.bounds.width, height: self.view.bounds.height - 40), style: .plain)
        t.delegate = (self as UITableViewDelegate)
        t.dataSource = (self as UITableViewDataSource)
        return t
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.cyan
        
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 100, y: 100, width: 100, height: 40)
        btn.setTitle("button", for: .normal)
        btn.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
        self.view.addSubview(btn)
        self.view.addSubview(self.table)
        
    }
    
    @IBAction func btnAction(_ sender: Any) {
        
        let vc3 = ViewController3()
        self.containerVC.push(viewController: vc3)
        
    }
    
}

extension ViewController2: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        cell?.textLabel?.text = "\(indexPath.row)"
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc3 = ViewController3()
        self.containerVC.push(viewController: vc3)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if scrollView.contentOffset.y <= 0 {
            if scrollView.isDragging {
                scrollView.isScrollEnabled = false
            }else {
                scrollView.isScrollEnabled = true
            }

        }else {
            scrollView.isScrollEnabled = true
        }
   
    }

}


class CustomTableView: UITableView, UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        self.isScrollEnabled = true
        
        if self.contentOffset.y <= 0 {
            return true
        }
        return false
    }
 
}
