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
    var isIndicator: Binder<Bool> {
        return isIndicator()
    }

    func isIndicator(_ color: UIColor = UIColor(light: .black, dark: .white), size: CGFloat = 44) -> Binder<Bool> {
        return Binder(base) { view, isIndicator in
            if isIndicator {
                view.addIndicator(color, size: size)
            } else {
                view.removeIndicators()
            }
        }
    }
}

// 뷰 + 인디게이터 뷰
extension UIView {
    var isIndicator: Bool {
        return !subviews.compactMap({ $0 as? IndicatorActivityView }).isEmpty
    }

    // 추가
    @discardableResult
    @objc func addIndicator(_ color: UIColor, size: CGFloat = 44) -> UIView {
        let indicatorView = IndicatorActivityView()
        indicatorView.updateSize(size)
        self.addSubview(indicatorView)
        NSLayoutConstraint.activate([
            self.centerYAnchor.constraint(equalTo: indicatorView.centerYAnchor),
            self.centerXAnchor.constraint(equalTo: indicatorView.centerXAnchor)
        ])
        indicatorView.startAndShowAnimating(color, size: CGSize(width: size, height: size))
        return indicatorView
    }

     func descriptionIndicator(_ description: String, textColor: UIColor = .white) {
        subviews.compactMap({ $0 as? IndicatorActivityView }).forEach({
            $0.description(description, textColor: textColor)
        })
    }

    func progressIndicator(_ progress: Double, decimalPlaces: Int = 1, textColor: UIColor = .white) {
        subviews.compactMap({ $0 as? IndicatorActivityView }).forEach({
            $0.progress(progress, decimalPlaces: decimalPlaces, textColor: textColor)
        })
    }

    func removeIndicators() {
        subviews.compactMap({ $0 as? IndicatorActivityView }).forEach({
            $0.stopAndHideAnimating()
            $0.removeFromSuperview()
        })
    }
}

private class IndicatorActivityView: UIView {
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = ""
        label.font = .systemFont(ofSize: 9)
        backgroundColor = UIColor(white: 255/255, alpha: 0.01)
        addSubview(label)
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: label.leadingAnchor),
            trailingAnchor.constraint(equalTo: label.trailingAnchor),
            centerYAnchor.constraint(equalTo: label.centerYAnchor),
            centerXAnchor.constraint(equalTo: label.centerXAnchor)
        ])
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = ""
        label.font = .systemFont(ofSize: 9)
        backgroundColor = UIColor(white: 255/255, alpha: 0.01)
        addSubview(label)
        constraints.filter({ $0.identifier == "bottom" }).first?.priority(700)
        let top = activityView.bottomAnchor.constraint(equalTo: label.topAnchor)
        top.constant = 4
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: label.leadingAnchor),
            trailingAnchor.constraint(equalTo: label.trailingAnchor),
            bottomAnchor.constraint(equalTo: label.bottomAnchor),
            top
        ])
        return label
    }()

    private let activityView: ActivityView
    private var size: CGFloat = 44

    init() {
        self.activityView = ActivityView()
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        activityView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityView)
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: activityView.leadingAnchor),
            trailingAnchor.constraint(equalTo: activityView.trailingAnchor),
            topAnchor.constraint(equalTo: activityView.topAnchor),
            bottomAnchor.constraint(equalTo: activityView.bottomAnchor).priority(999).identifier("bottom")
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func progress(_ progress: Double, decimalPlaces: Int, textColor: UIColor) {
        label.text = String(format: "%.\(decimalPlaces)f", progress).appending("%")
        label.textColor = textColor
    }

    // 설명
    fileprivate func description(_ description: String, textColor: UIColor) {
        descriptionLabel.text = description
        descriptionLabel.textColor = textColor
    }

    fileprivate func updateSize(_ size: CGFloat) {
        self.size = size
        NSLayoutConstraint.activate([
            activityView.widthAnchor.constraint(equalToConstant: size),
            activityView.heightAnchor.constraint(equalToConstant: size)
        ])
        activityView.updateSize(size)
    }

    fileprivate func startAndShowAnimating(_ color: UIColor = .black, size: CGSize) {
        activityView.startAndShowAnimating(color, frameSize: size)
    }

    fileprivate func stopAndHideAnimating() {
        activityView.stopAndHideAnimating()
    }
}

private class ActivityView: UIView {
    private var size: CGFloat = 44

    fileprivate func updateSize(_ updateSize: CGFloat) {
        layer.cornerRadius = updateSize/2
        size = updateSize
    }

    fileprivate func startAndShowAnimating(_ color: UIColor = .black, frameSize: CGSize) {
        frame = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)

        let indicatorSize = CGSize(width: size, height: size)
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
        path.addArc(withCenter: CGPoint(x: indicatorSize.width / 2, y: indicatorSize.height / 2),
                    radius: indicatorSize.width / 2,
                    startAngle: -(.pi / 2),
                    endAngle: .pi + .pi / 2,
                    clockwise: true)
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.backgroundColor = nil
        shapeLayer.path = path.cgPath
        shapeLayer.frame = CGRect(x: 0, y: 0, width: indicatorSize.width, height: indicatorSize.height)

        let frame = CGRect(
            x: (layer.bounds.width - indicatorSize.width) / 2,
            y: (layer.bounds.height - indicatorSize.height) / 2,
            width: indicatorSize.width,
            height: indicatorSize.height
        )

        shapeLayer.frame = frame
        shapeLayer.add(groupAnimation, forKey: "animation")
        layer.addSublayer(shapeLayer)
    }

    fileprivate func stopAndHideAnimating() {
        layer.sublayers?.forEach({ $0.removeAllAnimations() })
        layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        layer.sublayers = nil
    }
}
