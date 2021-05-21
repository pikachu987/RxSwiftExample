//
//  UIView+indicator.swift
//  Example
//
//  Created by corpdocfriends on 2021/05/21.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIView {
//    var circleIndicator = BehaviorRelay<Bool>(value: false)
    
    public func isRefreshing(_ color: UIColor, size: CGFloat = 44, isDispatch: Bool = true) -> Binder<Bool> {
        return Binder(self.base) { view, isIndicator in
            if isIndicator {
                view.addIndicator(color, size: size, isDispatch: isDispatch)
            } else {
                view.removeIndicators()
            }
        }
    }
}


// 뷰 + 인디게이터 뷰
extension UIView {

    // 인디게이트 체크
    var isIndicator: Bool {
        return !self.subviews.compactMap({ $0 as? IndicatorActivityView }).isEmpty
    }

    // 추가
    @discardableResult
    @objc func addIndicator(_ color: UIColor, size: CGFloat = 44, isDispatch: Bool = true) -> UIView {
        let indicatorView = IndicatorActivityView()
        if isDispatch {
            DispatchQueue.main.async {
                indicatorView.updateSize(size)
                self.addSubview(indicatorView)
                indicatorView.make { (make) in
                    make.center.equalToSuperview()
                }
                indicatorView.startAndShowAnimating(color, size: CGSize(width: size, height: size))
            }
        } else {
            indicatorView.updateSize(size)
            self.addSubview(indicatorView)
            indicatorView.make { (make) in
                make.center.equalToSuperview()
            }
            indicatorView.startAndShowAnimating(color, size: CGSize(width: size, height: size))
        }
        return indicatorView
    }

    // 설명
     func descriptionIndicator(_ description: String, textColor: UIColor = .white, isDispatch: Bool = true) {
        if isDispatch {
            DispatchQueue.main.async {
                self.subviews.compactMap({ $0 as? IndicatorActivityView }).forEach({
                    $0.description(description, textColor: textColor)
                })
            }
        } else {
            self.subviews.compactMap({ $0 as? IndicatorActivityView }).forEach({
                $0.description(description, textColor: textColor)
            })
        }
    }

    // 프로그래스
    func progressIndicator(_ progress: Double, decimalPlaces: Int = 1, textColor: UIColor = .white, isDispatch: Bool = true) {
        if isDispatch {
            DispatchQueue.main.async {
                self.subviews.compactMap({ $0 as? IndicatorActivityView }).forEach({
                    $0.progress(progress, decimalPlaces: decimalPlaces, textColor: textColor)
                })
            }
        } else {
            self.subviews.compactMap({ $0 as? IndicatorActivityView }).forEach({
                $0.progress(progress, decimalPlaces: decimalPlaces, textColor: textColor)
            })
        }
    }

    // 지우기
    func removeIndicators() {
        self.subviews.compactMap({ $0 as? IndicatorActivityView }).forEach({
            $0.stopAndHideAnimating()
            $0.removeFromSuperview()
        })
    }
}

// 인디게이트 뷰
private class IndicatorActivityView: UIView {
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = ""
        label.font = .systemFont(ofSize: 9)
        self.backgroundColor = UIColor(white: 255/255, alpha: 0.01)
        self.addSubview(label)
        label.make { (make) in
            make.leading.trailing.equalToSuperview()
            make.center.equalTo(self.activityView.snp.center)
        }
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = ""
        label.font = .systemFont(ofSize: 9)
        self.backgroundColor = UIColor(white: 255/255, alpha: 0.01)
        self.addSubview(label)
        self.constraints(labelType: .bottom).priority(700)
        self.constraints(labelType: .height).first?.constant = self.size + 24
        label.make { (make) in
            make.top.equalTo(self.activityView.snp.bottom).inset(-4)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        return label
    }()

    private let activityView: ActivityView
    private var size: CGFloat = 44

    init() {
        self.activityView = ActivityView()
        super.init(frame: .zero)
        self.addSubview(self.activityView)
        self.activityView.make { (make) in
            make.top.equalToSuperview().labeled(.top)
            make.leading.equalToSuperview().labeled(.leading)
            make.trailing.equalToSuperview().labeled(.trailing)
            make.bottom.equalToSuperview().priority(999).labeled(.bottom)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 프로그래스
    fileprivate func progress(_ progress: Double, decimalPlaces: Int, textColor: UIColor) {
        self.label.text = String(format: "%.\(decimalPlaces)f", progress).appending("%")
        self.label.textColor = textColor
    }

    // 설명
    fileprivate func description(_ description: String, textColor: UIColor) {
        self.descriptionLabel.text = description
        self.descriptionLabel.textColor = textColor
    }

    fileprivate func updateSize(_ size: CGFloat) {
        self.size = size
        self.activityView.make { (make) in
            make.width.equalTo(size)
            make.height.equalTo(size)
        }
        self.activityView.updateSize(size)
    }

    // 애니메이션 시작
    fileprivate func startAndShowAnimating(_ color: UIColor = .black, size: CGSize) {
        self.activityView.startAndShowAnimating(color, size: size)
    }

    // 애니메이션 중지
    fileprivate func stopAndHideAnimating() {
        self.activityView.stopAndHideAnimating()
    }
}

private class ActivityView: UIView {
    private var size: CGFloat = 44

    fileprivate func updateSize(_ size: CGFloat) {
        self.layer.cornerRadius = size/2
        self.size = size
    }

    // 애니메이션 시작
    fileprivate func startAndShowAnimating(_ color: UIColor = .black, size: CGSize) {
        self.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        let size = CGSize(width: self.size, height: self.size)
        let beginTime: Double = 0.5
        let strokeStartDuration: Double = 1.2
        let strokeEndDuration: Double = 0.7

        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.byValue = Float.pi * 2
        #if swift(>=4.2)
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        #else
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        #endif

        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.duration = strokeEndDuration
        strokeEndAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        strokeEndAnimation.fromValue = 0
        strokeEndAnimation.toValue = 1

        let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimation.duration = strokeStartDuration
        strokeStartAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        strokeStartAnimation.fromValue = 0
        strokeStartAnimation.toValue = 1
        strokeStartAnimation.beginTime = beginTime

        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [rotationAnimation, strokeEndAnimation, strokeStartAnimation]
        groupAnimation.duration = strokeStartDuration + beginTime
        groupAnimation.repeatCount = .infinity
        groupAnimation.isRemovedOnCompletion = false
        #if swift(>=4.2)
        groupAnimation.fillMode = .forwards
        #else
        groupAnimation.fillMode = kCAFillModeForwards
        #endif

        let shapeLayer: CAShapeLayer = CAShapeLayer()
        let path: UIBezierPath = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                    radius: size.width / 2,
                    startAngle: -(.pi / 2),
                    endAngle: .pi + .pi / 2,
                    clockwise: true)
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.backgroundColor = nil
        shapeLayer.path = path.cgPath
        shapeLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        let frame = CGRect(
            x: (self.layer.bounds.width - size.width) / 2,
            y: (self.layer.bounds.height - size.height) / 2,
            width: size.width,
            height: size.height
        )

        shapeLayer.frame = frame
        shapeLayer.add(groupAnimation, forKey: "animation")
        self.layer.addSublayer(shapeLayer)
    }

    // 애니메이션 중지
    fileprivate func stopAndHideAnimating() {
        self.layer.sublayers?.forEach({ $0.removeAllAnimations() })
        self.layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        self.layer.sublayers = nil
    }
}
