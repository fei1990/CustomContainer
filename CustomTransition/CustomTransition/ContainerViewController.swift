//
//  ContainerViewController.swift
//  CustomTransition
//
//  Created by wf on 2018/11/5.
//  Copyright © 2018 sohu. All rights reserved.
//

import UIKit
import ObjectiveC

let view_y: CGFloat = 100

let maskViewAlpha: CGFloat =  0.3

let animationDuration: TimeInterval = 0.3

fileprivate enum AnimateType {
    case push
    case present
}

fileprivate enum PanDirection {
    case none
    case horizontal
    case vertical
}

class ContainerViewController: UIViewController {
    deinit {
        print("ContainerViewController deinit......")
    }
    
    private var viewControllers: [UIViewController] = [UIViewController]()
    
    private var presentingVC: UIViewController! 
    
    @objc var navigation: UINavigationController?
    
    @objc var otherGestureEnabled: Bool = false  //解决手势冲突
    
    private var direction: PanDirection = .none
    weak private var rootVc: UIViewController!
    
    private var transformVc: UIViewController {
        if viewControllers.count <= 1 {
            return self
        }else {
            return viewControllers.last!
        }
    }
    
    private var transformView: UIView {
        if viewControllers.count <= 1 {
            return self.view
        }else {
            return (viewControllers.last?.view)!
        }
    }
    
    private var isRootVc: Bool {
        return viewControllers.count <= 1
    }
    
    //顶部的背景遮罩
    var topMaskView: UIControl = {
        let mView = UIControl.init(frame: CGRect.zero)
        mView.backgroundColor = UIColor.black
        mView.isOpaque = false  //是否透明
        mView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return mView
    }()
    
    private var maskView1: UIControl = {
        let mView = UIControl.init(frame: CGRect.zero)
        mView.backgroundColor = UIColor.black
        mView.isOpaque = false  //是否透明
        mView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return mView
    }()
    
    private lazy var subMaskView: UIControl = {
        let mView = UIControl.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - view_y))
        mView.backgroundColor = UIColor.black
        mView.isOpaque = false  //是否透明
        mView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return mView
    }()
    
    var panGesture: UIPanGestureRecognizer!
    
    //MARK: lifecycle
    init(rootVC: UIViewController, presentingVC: UIViewController) {
        
        super.init(nibName: nil, bundle: nil)
        self.presentingVC = presentingVC
        self.rootVc = rootVC
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRec(pan:)))
        panGesture.delegate = self
        self.view.addGestureRecognizer(panGesture!)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bezier = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.frame.height), byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 16, height: 16))

        let maskLayer = CAShapeLayer()
        maskLayer.path = bezier.cgPath
        rootVc.view.layer.mask = maskLayer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presentingVC.addChild(self)
        self.didMove(toParent: presentingVC)
        presentingVC.view.addSubview(view)
        
        self.view.frame = CGRect(x: 0, y: view_y, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - view_y)
        
        addMaskView()
        
//        makeCorner(with: self.view)
        
//        self.view.clipsToBounds = true
////
//        rootVc.view.clipsToBounds = true
        
//        self.view.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        
//        let shadowLayer = CALayer()
//        shadowLayer.backgroundColor = rootVc.view.backgroundColor!.cgColor
//        shadowLayer.cornerRadius = 17
//        shadowLayer.frame = self.view.bounds
//        shadowLayer.shadowOffset = CGSize(width: -3, height: -3)
//        shadowLayer.shadowColor = UIColor.black.cgColor
//        shadowLayer.shadowOpacity = 0.3
//        self.view.layer.addSublayer(shadowLayer)
        
        
        self.view.layer.shadowOffset = CGSize(width: -3, height: -3)
        self.view.layer.shadowColor = UIColor.black.cgColor
        self.view.layer.shadowOpacity = 0.3
        self.view.layer.shadowRadius = 3
        
    }
    
    //MARK: private method
    @objc func panGestureRec(pan: UIPanGestureRecognizer) {
        
        let point = pan.translation(in: transformView)
        
        switch pan.state {
        case .began:
            
            dragBegin()
            
        case .changed:
            
            direction = self.commitTranslation(point: point)
            dragging(transform: point)
            
        case .ended, .cancelled, .failed, .possible:
            
            dragEnd(transform: point)
            
        }
        
    }

    ///添加半透明遮罩
    private func addMaskView() {
        
        topMaskView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: view_y)
        
        presentingVC.navigationController?.view.addSubview(topMaskView)
        
        maskView1.frame = CGRect(x: 0, y: view_y, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - view_y)
        presentingVC.view.insertSubview(maskView1, belowSubview: self.view)
    
    }
    
    ///设置topleft topright Corner
    private func makeCorner(with view: UIView) {
        
        let bezier = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.frame.height), byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 16, height: 16))

        let maskLayer = CAShapeLayer()
        maskLayer.path = bezier.cgPath
        view.layer.mask = maskLayer

//        let cornerLayer = CALayer()
//        cornerLayer.frame = view.bounds
//        cornerLayer.mask = maskLayer
//        view.layer.addSublayer(cornerLayer)
        
    }
    
    private func add(_ childVC: UIViewController) {
        
        if viewControllers.count == 0 {
            addChild(childVC)
            
            childVC.didMove(toParent: self)
            
            childVC.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.view.frame.height)
            
            self.view.addSubview(childVC.view)
        }else {
            rootVc.addChild(childVC)
            
            childVC.didMove(toParent: rootVc)
            
            childVC.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.view.frame.height)
            
            rootVc.view.addSubview(childVC.view)
        }
        
        
        
    }
    
    private func pushAnimate(in childView: UIView, completion: (() -> Void)?) {
        
        var presentView = childView
        
        if viewControllers.count == 0 {  //第一次呈现
            topMaskView.alpha = 0
            maskView1.alpha = 0
            
            UIView.animate(withDuration: animationDuration) {
                self.topMaskView.alpha = maskViewAlpha
                self.maskView1.alpha = maskViewAlpha
            }
            
            presentView = self.view
            
        }else {
            
            rootVc.view.insertSubview(subMaskView, belowSubview: childView)
            subMaskView.alpha = 0
            
            UIView.animate(withDuration: animationDuration, animations: {
                self.subMaskView.alpha = maskViewAlpha
            }) { (completed) in
                if self.subMaskView.superview != nil {
                    self.subMaskView.removeFromSuperview()
                }
            }
            
            presentView = childView
        }

        presentView.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)
        
        UIView.animate(withDuration: animationDuration, animations: {
            
            presentView.transform = CGAffineTransform(translationX: 0, y: 0)
            
        }) { (completed) in
            
            completion?()
        }
        
    }
    
    private func presentAnimate(in childView: UIView, completion: (() -> Void)?) {
        
        var presentView = childView
        
        if viewControllers.count == 0 {  //第一次呈现
            topMaskView.alpha = 0
            maskView1.alpha = 0
            UIView.animate(withDuration: animationDuration) {
                self.topMaskView.alpha = maskViewAlpha
                self.maskView1.alpha = maskViewAlpha
            }
            presentView = self.view
    
        }else {
            rootVc.view.insertSubview(subMaskView, belowSubview: childView)
            subMaskView.alpha = 0
            
            UIView.animate(withDuration: animationDuration, animations: {
                self.subMaskView.alpha = maskViewAlpha
            }) { (completed) in
                if self.subMaskView.superview != nil {
                    self.subMaskView.removeFromSuperview()
                }
            }
            presentView = childView
        }

        presentView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height - view_y)
        
        UIView.animate(withDuration: animationDuration, animations: {
            
            presentView.transform = CGAffineTransform(translationX: 0, y: 0)
            
        }) { (completed) in
            completion?()
        }
        
    }
    
    //MARK: 出场方法
    @objc func push(viewController: UIViewController, completion: (() -> Void)? = nil) {
        
        viewController.containerVC = self
        navigation = presentingVC.navigationController
        
        //1.add child vc
        add(viewController)
        
        //show
        pushAnimate(in: viewController.view, completion: completion)
        
        //
        viewControllers.append(viewController)
        
    }
    
    @objc func present(viewController: UIViewController, completion: (() -> Void)? = nil) {
        
        viewController.containerVC = self
        navigation = presentingVC.navigationController
        
        //1.add child vc
        add(viewController)
        
        //show
        presentAnimate(in: viewController.view, completion: completion)
        
        //
        viewControllers.append(viewController)
        
    }
    
}

extension ContainerViewController {
    
    private func commitTranslation(point: CGPoint) -> PanDirection {
        
        let absX = abs(point.x)
        let absY = abs(point.y)
        
        if absX - absY > 0 {  //水平滑动
            return .horizontal
        }else {           //垂直滑动
            return .vertical
        }
        
    }
    
    private func dragBegin() {
        
        guard viewControllers.count >= 2 else {
            return
        }
        
        self.otherGestureEnabled = false
        
        rootVc.view.insertSubview(subMaskView, belowSubview: transformView)
        makeCorner(with: transformView)
        
//        let v = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
//        transformView.layer.shadowOffset = CGSize(width: -30, height: -3)
//        transformView.layer.shadowColor = UIColor.black.cgColor
//        transformView.layer.shadowOpacity = 0.8
//        transformView.addSubview(v)
        
    }
    
    private func dragging(transform point: CGPoint) {
        
        switch direction {
        case .horizontal:
            
            // 得到手指拖动的位移
            let offsetX = point.x
            
            let currentScaleX = offsetX / self.view.frame.width
            
            if offsetX > 0 {  //让这个view都跟着动
                transformView.transform = CGAffineTransform(translationX: offsetX, y: 0)
                panGesture.setTranslation(CGPoint(x: offsetX, y: 0), in: transformView)
            }else {
                transformView.transform = CGAffineTransform.identity
            }
            
            // 让遮盖透明度改变,直到减为0,让遮罩完全透明,默认值-当前滑动比例*默认值
            if currentScaleX > 0 {
                changeMaskViewAlpha(alpha: maskViewAlpha - currentScaleX * maskViewAlpha)
            }
            
        case .vertical:
            
            // 得到手指拖动的位移
            let offsetY = point.y
            
            let currentScaleY = offsetY / self.view.frame.height
            
            if offsetY > 0 {
                self.view.transform = CGAffineTransform(translationX: 0, y: offsetY)
                panGesture.setTranslation(CGPoint(x: 0, y: offsetY), in: self.view)
            }else {
                self.view.transform = CGAffineTransform.identity
            }
            
            if currentScaleY > 0 {
                topMaskView.alpha = maskViewAlpha - currentScaleY * maskViewAlpha
                maskView1.alpha = maskViewAlpha - currentScaleY * maskViewAlpha
            }
            
        case .none:
            break
        }
        
    }
    
    private func dragEnd(transform point: CGPoint) {
        
        switch direction {
        case .horizontal:
            
            //取出挪动的距离
            let transformX = transformView.transform.tx
            
            if transformX < 80 {  //往左边弹回  归位
                
                UIView.animate(withDuration: animationDuration, animations: {
                    
                    self.transformView.transform = CGAffineTransform.identity
                    
                    //遮罩alpha也要归位
                    self.changeMaskViewAlpha(alpha: maskViewAlpha)
                    
                }) { (complete) in
                    self.otherGestureEnabled = true
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "otherGesture"), object: nil)
                }
                
            }else {
                UIView.animate(withDuration: animationDuration, animations: {
                    
                    self.transformView.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
                    
                    self.changeMaskViewAlpha(alpha: 0)
                    
                }) { (completion) in
                    
                    self.removeMaskView()
                    self.removeCurrentVc()
                    self.changeMaskViewAlpha(alpha: maskViewAlpha)
                    
                }
            }
            
        case .vertical:
            
            //取出挪动的距离
            let transformY = self.view.transform.ty
            
            if transformY < 80 {  //往左边弹回  归位
                
                UIView.animate(withDuration: animationDuration, animations: {
                    
                    self.view.transform = CGAffineTransform.identity
                    self.transformView.transform = CGAffineTransform.identity
                    
                    //遮罩alpha也要归位
                    self.topMaskView.alpha = maskViewAlpha
                    self.maskView1.alpha = maskViewAlpha
                    
                }) { (complete) in
                    self.otherGestureEnabled = true
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "otherGesture"), object: nil)
                }
                
            }else {
                UIView.animate(withDuration: animationDuration, animations: {
                    
                    self.view.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
                    
                    self.topMaskView.alpha = 0
                    self.maskView1.alpha = 0
                    
                }) { (completion) in
                    
                    self.removeAll()
                    
                }
            }
            
        case .none:
            self.transformView.transform = CGAffineTransform.identity
            self.view.transform = CGAffineTransform.identity
        }
        
    }
    
    //MARK: 修改遮罩alpha
    private func changeMaskViewAlpha(alpha: CGFloat) {
        
        if isRootVc {
            
            self.topMaskView.alpha = abs(alpha)
            self.maskView1.alpha = abs(alpha)
            
        }else {
            self.subMaskView.alpha = abs(alpha)
        }
        
    }
    
    private func removeMaskView() {
        if isRootVc {
            self.topMaskView.removeFromSuperview()
            self.maskView1.removeFromSuperview()
        }else {
            self.subMaskView.removeFromSuperview()
        }
    }
    //MARK: 保证每一个控制器释放
    private func removeCurrentVc() {
        
        self.transformView.removeFromSuperview()
        self.transformVc.didMove(toParent: nil)
        self.transformVc.removeFromParent()
        
        if isRootVc {
            let rootVc = viewControllers.last
            rootVc?.view.removeFromSuperview()
            rootVc?.removeFromParent()
            rootVc?.didMove(toParent: nil)
            viewControllers.removeAll()
        }else {
            viewControllers.removeLast()
        }
        
    }
    
    private func removeAll() {
        
        for vc in viewControllers {
            vc.view.removeFromSuperview()
            vc.didMove(toParent: nil)
            vc.removeFromParent()
        }
        
        self.view.removeFromSuperview()
        self.didMove(toParent: nil)
        self.removeFromParent()
        
        viewControllers.removeAll()
        topMaskView.removeFromSuperview()
        maskView1.removeFromSuperview()
        
    }
    
}

extension UIViewController {
    
    private struct AssociatedKey {
        static var containerExtension = "containerExtension"
    }
    
    @objc var containerVC: ContainerViewController {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.containerExtension) as! ContainerViewController
        }
        set(value) {
            
            objc_setAssociatedObject(self, &AssociatedKey.containerExtension, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
        }
    }
    
}

extension ContainerViewController: UIGestureRecognizerDelegate {
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//
//        if (gestureRecognizer === self.panGesture) {
//            return true
//        }else if gestureRecognizer.view is UIScrollView {
//            return true
//        }
//        return false
//    }
    
//    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
    
//    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
    
}
