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
    }
    
    lazy var table: CustomTableView = {
        let t = CustomTableView(frame: CGRect(x: 0, y: 40, width: self.view.bounds.width, height: self.view.bounds.height - 40), style: .plain)
        t.delegate = (self as UITableViewDelegate)
        t.dataSource = (self as UITableViewDataSource)
        t.bounces = false
        
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
        
//        self.view.addSubview(self.table)
       
//        self.table.panGestureRecognizer.delegate = (self as UIGestureRecognizerDelegate)
        self.containerVC.panGesture.require(toFail: self.table.panGestureRecognizer)
//        self.table.panGestureRecognizer.isEnabled = false
//        self.table.addObserver(self, forKeyPath: "panGestureRecognizer.state", options: .new, context: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notification), name: NSNotification.Name("otherGesture"), object: nil)
        self.table.contentOffset.y = 0.5
    }
    
    @objc func notification() {
        self.table.isScrollEnabled = true
        self.table.contentOffset.y = 0.1
    }

    @IBAction func btnAction(_ sender: Any) {
        
        let vc3 = ViewController3()
        self.containerVC.push(viewController: vc3)
//        self.containerVC.navigation?.pushViewController(vc3, animated: true)
//
//        let vc4 = ViewController4()
//
//        self.containerVC.push(viewController: vc4)
        
        
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.containerVC.topMaskView.isHidden = true
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        self.containerVC.topMaskView.isHidden = false
//    }

    
    
}

extension ViewController2: UIGestureRecognizerDelegate {
    
   
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
        
        
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y == 0 {
            scrollView.isScrollEnabled = false
        }else {
            scrollView.isScrollEnabled = true
        }
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesMoved(touches, with: event)
    }
}


class CustomTableView: UITableView {
    
//    weak var vc: ViewController2?
//
//    var isScroll: Bool = true
//
//    var offsetY: CGFloat?
//
//    var pan: UIPanGestureRecognizer!
//
//    override init(frame: CGRect, style: UITableView.Style) {
//        super.init(frame: frame, style: style)
//
//
//
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//
//
//
//        return isScrollEnabled
//    }
////
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//
//        print(gestureRecognizer.view as Any)
//
//        return true
//    }
//
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//
//        if otherGestureRecognizer.view is UIScrollView {
//            return true
//        }
//
//        return true
//    }
//
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//        return true
//    }
    
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//
//        if self.vc?.containerVC.otherGestureEnabled == false || isScroll {
//            return nil
//        }else {
//            return super.hitTest(point, with: event)
//        }
//
//    }
    
    
}
