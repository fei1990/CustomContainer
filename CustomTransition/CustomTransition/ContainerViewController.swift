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

let radius: CGFloat = 16

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
    
    /// 每一个child view 的背景遮罩
    private lazy var subMaskView: UIControl = {
        let mView = UIControl.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - view_y))
        mView.backgroundColor = UIColor.black
        mView.isOpaque = false  //是否透明
        mView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return mView
    }()
    
    /// 开始退场view 左边阴影
    lazy var shadowView: UIView = {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - view_y))
        v.layer.shadowOffset = CGSize(width: -3, height: 0)
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.3
        let bezier = UIBezierPath()
        bezier.move(to: CGPoint(x: UIScreen.main.bounds.width, y: 0))
        bezier.addLine(to: CGPoint(x: UIScreen.main.bounds.width, y: UIScreen.main.bounds.height - view_y))
        bezier.addLine(to: CGPoint(x: 0, y: UIScreen.main.bounds.height - view_y))
        bezier.addLine(to: CGPoint(x: 0, y: radius))
        bezier.addArc(withCenter: CGPoint(x: radius, y: radius), radius: radius, startAngle: .pi / 2, endAngle: 0, clockwise: true)
        bezier.close()
        v.layer.shadowPath = bezier.cgPath
        return v
    }()
    
    ///该容器的投影
    lazy var contaiverShadowView: UIView = {
        let v = UIView(frame: CGRect(x: 0, y: view_y, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - view_y))
        v.layer.shadowOffset = CGSize(width: -3, height: -3)
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.3
        let bezier = UIBezierPath()
        bezier.move(to: CGPoint(x: UIScreen.main.bounds.width - radius, y: 0))
        bezier.addArc(withCenter: CGPoint(x: UIScreen.main.bounds.width - radius, y: radius), radius: radius, startAngle: .pi / 2, endAngle: 0, clockwise: true)
        bezier.addLine(to: CGPoint(x: UIScreen.main.bounds.width, y: UIScreen.main.bounds.height - view_y))
        bezier.addLine(to: CGPoint(x: 0, y: UIScreen.main.bounds.height - view_y))
        bezier.addLine(to: CGPoint(x: 0, y: radius))
        bezier.addArc(withCenter: CGPoint(x: radius, y: radius), radius: radius, startAngle: -.pi, endAngle: .pi * 1.5, clockwise: true)
        bezier.close()
        v.layer.shadowPath = bezier.cgPath
        return v
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presentingVC.addChild(self)
        self.didMove(toParent: presentingVC)
        presentingVC.view.addSubview(view)
        
        self.view.frame = CGRect(x: 0, y: view_y, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - view_y)
        
        //添加遮罩
        addMaskView()
        
        //添加圆角
        makeSubViewCorner(view: self.view)
        
    }
    
    //MARK: private method
    @objc func panGestureRec(pan: UIPanGestureRecognizer) {
        
        let point = pan.translation(in: transformView)
        
        switch pan.state {
        case .began:
            direction = self.commitTranslation(point: point)
            dragBegin()
            
        case .changed:
            
            dragging(transform: point)
            
        case .ended, .cancelled, .failed, .possible:
            
            dragEnd(transform: point)
            
        }
        
    }

    ///添加半透明遮罩
    private func addMaskView() {
        
        topMaskView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: view_y)
        
        if  let na = presentingVC.navigationController {
            na.view.addSubview(topMaskView)
        }else {
            presentingVC.view.addSubview(topMaskView)
        }

        maskView1.frame = CGRect(x: 0, y: view_y, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - view_y)
        presentingVC.view.insertSubview(maskView1, belowSubview: self.view)
        
    }
    
    ///设置topleft topright Corner（转场控制器view）
    private func makeSubViewCorner(view: UIView) {

        let bezier = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.frame.height), byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: radius, height: radius))

        let maskLayer = CAShapeLayer()
        maskLayer.path = bezier.cgPath
        view.layer.mask = maskLayer

    }
    
    private func add(_ childVC: UIViewController) {
        
        addChild(childVC)
        
        childVC.didMove(toParent: self)
        
        childVC.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.view.frame.height)
        
        view.addSubview(childVC.view)

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
            
            //添加投影
            presentingVC.view.insertSubview(contaiverShadowView, aboveSubview: maskView1)
            contaiverShadowView.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: view_y)
            
        }else {
            
            view.insertSubview(subMaskView, belowSubview: childView)
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
            
            if self.viewControllers.count == 0 {
                self.contaiverShadowView.transform = CGAffineTransform(translationX: 0, y: view_y)
            }
            
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
            
            //添加投影
            presentingVC.view.insertSubview(contaiverShadowView, aboveSubview: maskView1)
            contaiverShadowView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height - view_y)
    
        }else {
            view.insertSubview(subMaskView, belowSubview: childView)
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
            if self.viewControllers.count == 0 {
                self.contaiverShadowView.transform = CGAffineTransform(translationX: 0, y: 0)
            }
            
        }) { (completed) in
            completion?()
        }
        
    }
    
    private func popAnimation(_ completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: animationDuration, animations: {
            
            self.transformView.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
            self.changeMaskViewAlpha(alpha: 0)
            
            if self.isRootVc {
                self.contaiverShadowView.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
            }else {
                self.shadowView.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
            }
            
        }) { (completed) in
            
            self.removeMaskView()
            self.removeCurrentVc()
            self.changeMaskViewAlpha(alpha: maskViewAlpha)
            if let _ = self.shadowView.superview {
                self.shadowView.transform = CGAffineTransform.identity
                self.shadowView.removeFromSuperview()
            }
            
            if self.viewControllers.count == 0, let _ = self.contaiverShadowView.superview {
                self.contaiverShadowView.removeFromSuperview()
            }
            
            completion?()
            
        }
    }
    
    private func dismissAnimation(_ completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: animationDuration, animations: {
            
            self.view.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
            
            self.contaiverShadowView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
            
            self.topMaskView.alpha = 0
            self.maskView1.alpha = 0
            
        }) { (completed) in
            
            self.removeAll()
            if let _ = self.contaiverShadowView.superview {
                self.contaiverShadowView.removeFromSuperview()
            }
            
            completion?()
        }
    }
    
    //MARK: 进场方法
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
    
    ///MARK: 出场方法
    @objc func pop(_ completion: (() -> Void)? = nil) {
        
        dragBeginSettings()
        popAnimation(completion)
    }
    
    @objc func dismiss(_ completion: (() -> Void)? = nil) {
        dismissAnimation(completion)
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
    
    /// 拖动开始前的设置
    private func dragBeginSettings() {
        if !isRootVc {
            //添加即将出场view 背景遮罩
            view.insertSubview(subMaskView, belowSubview: transformView)
            //设置即将退场view Corner
            makeSubViewCorner(view: transformView)
            //设置即将退场 view 阴影
            view.insertSubview(shadowView, belowSubview: transformView)
        }
    }
    
    private func dragBegin() {

        guard isRootVc == false else {  //跟控制器直接dismiss
            return
        }
        
        guard direction == .horizontal else {
            return
        }
        
        dragBeginSettings()
        
    }
    
    private func dragging(transform point: CGPoint) {
        
        switch direction {
        case .horizontal:
            
            // 得到手指拖动的位移
            let offsetX = point.x
            
            let currentScaleX = offsetX / self.view.frame.width
            
            if offsetX > 0 {  //让这个view都跟着动
                transformView.transform = CGAffineTransform(translationX: offsetX, y: 0)
                shadowView.transform = CGAffineTransform(translationX: offsetX, y: 0)
                if isRootVc {
                    contaiverShadowView.transform = CGAffineTransform(translationX: offsetX, y: 0)
                }
            }else {
                transformView.transform = CGAffineTransform.identity
                shadowView.transform = CGAffineTransform.identity
                if isRootVc {
                    contaiverShadowView.transform = CGAffineTransform.identity
                }
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
                contaiverShadowView.transform = CGAffineTransform(translationX: 0, y: offsetY)
            }else {
                self.view.transform = CGAffineTransform.identity
                contaiverShadowView.transform = CGAffineTransform.identity
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
                    self.shadowView.transform = CGAffineTransform.identity
                    //遮罩alpha也要归位
                    self.changeMaskViewAlpha(alpha: maskViewAlpha)
                    
                    if self.isRootVc {
                        self.contaiverShadowView.transform = CGAffineTransform.identity
                    }
                    
                }) { (complete) in

                    guard self.isRootVc == false else {
                        return
                    }

                    self.subMaskView.removeFromSuperview()
                    
                    if let _ = self.transformView.layer.mask {
                        self.transformView.layer.mask = nil
                    }
                    
                    if let _ = self.shadowView.superview {
                        self.shadowView.removeFromSuperview()
                    }
                }
                
            }else {
                popAnimation()
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
                    
                    self.contaiverShadowView.transform = CGAffineTransform.identity
                    
                }) { (complete) in

                }
                
            }else {
                dismissAnimation()
            }
            
        case .none:
            self.transformView.transform = CGAffineTransform.identity
            self.view.transform = CGAffineTransform.identity
            self.contaiverShadowView.transform = CGAffineTransform.identity
        }
        
    }
    
    //MARK: 修改遮罩alpha
    private func changeMaskViewAlpha(alpha: CGFloat) {
        
        if isRootVc {
            
            self.topMaskView.alpha = abs(alpha)
            self.maskView1.alpha = abs(alpha)
            
        }else {
            guard let _ = self.subMaskView.superview else {
                return
            }
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
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
}
