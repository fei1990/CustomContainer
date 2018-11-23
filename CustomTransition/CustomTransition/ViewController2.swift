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
        self.table.vc = self
        self.containerVC.panGesture.require(toFail: self.table.panGestureRecognizer)
    }
    
    @IBAction func btnAction(_ sender: Any) {
        
        let vc3 = ViewController3()
        self.containerVC.push(viewController: vc3)
        
    }
    
    
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

    
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        print(scrollView.contentOffset.y)
//        if scrollView.contentOffset.y <= 0 {
//            scrollView.isScrollEnabled = false
//            self.containerVC.panGesture.require(toFail: self.table.panGestureRecognizer)
//        }else {
//            scrollView.isScrollEnabled = true
////            self.table.panGestureRecognizer.require(toFail: self.containerVC.panGesture)
//        }
//    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollView.isScrollEnabled = true
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesMoved(touches, with: event)
    }
}


class CustomTableView: UITableView, UIGestureRecognizerDelegate {
    
    weak var vc: ViewController2?
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
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {

            let point = pan.translation(in: self)

            if abs(point.x) > abs(point.y) {   //水平滑

                return false
            }else {  //垂直滑

                return true
            }

        }
        
        return true
    }
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
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        print("gestureRecognizer : \(gestureRecognizer)")
//        print("otherGestureRecognizer : \(otherGestureRecognizer)")
//        if otherGestureRecognizer == vc?.containerVC.panGesture {
//            return true
//        }
//        return false
//    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        if let pan = otherGestureRecognizer as? UIPanGestureRecognizer {

            let point = pan.translation(in: self)

            if abs(point.x) >= abs(point.y) { //水平滑
                return true
            }

//            if abs(point.x) < abs(point.y) {
//                return false
//            }

        }

        if let _ = otherGestureRecognizer.view as? UIWindow {
            return true
        }


        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        print("gestureRecognizer : \(gestureRecognizer)")
//        print("otherGestureRecognizer : \(otherGestureRecognizer)")
//        if let pan = otherGestureRecognizer as? UIPanGestureRecognizer {
//            let point = pan.translation(in: self)
//
//            if abs(point.x) > abs(point.y) {   //水平滑
//                pan.require(toFail: self.panGestureRecognizer)
//                return true
//            }else {  //垂直滑
//                pan.require(toFail: self.panGestureRecognizer)
//                return false
//            }
//
//            print(point)
//        }
        return true
    }
 
}
