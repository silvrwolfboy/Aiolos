//
//  ResizeHandle.swift
//  Aiolos
//
//  Created by Matthias Tretter on 18/07/2017.
//  Copyright © 2017 Matthias Tretter. All rights reserved.
//

import Foundation


/// View that is used to display the resize handle
final class ResizeHandle: UIView {

    private lazy var resizeHandle: CAShapeLayer = self.makeResizeHandle()

    // MARK: - Properties

    var handleColor: UIColor = .lightGray {
        didSet {
            self.updateResizeHandleColor()
        }
    }

    var bending: CGFloat = 0.0 { // [0..1]
        didSet {
            guard abs(oldValue - self.bending) > 0.0001 else { return }

            self.updateResizeHandlePath()
        }
    }

    var isResizing = false {
        didSet {
            guard oldValue != self.isResizing else { return }

            self.updateResizeHandlePath(animated: true)
            self.updateResizeHandleColor()
        }
    }

    // MARK: - Lifecycle

    init(configuration: Panel.Configuration) {
        super.init(frame: .zero)

        self.clipsToBounds = false
        self.isOpaque = false
        self.backgroundColor = .clear
        self.layer.addSublayer(self.resizeHandle)
        self.configure(with: configuration)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - ResizeHandle

    func configure(with configuration: Panel.Configuration) {
        self.handleColor = configuration.resizeHandleColor
    }
}

// MARK: - UIView

extension ResizeHandle {

    override func layoutSubviews() {
        super.layoutSubviews()

        self.resizeHandle.frame = self.bounds
        self.updateResizeHandlePath()
    }
}

// MARK: - Private

private extension ResizeHandle {

    func makeResizeHandle() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.contentsScale = UIScreen.main.scale
        layer.backgroundColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 4.0
        layer.lineCap = kCALineCapRound
        return layer
    }

    func updateResizeHandleColor() {
        let baseColor = self.handleColor
        self.resizeHandle.strokeColor = self.isResizing ? baseColor.darkened().cgColor : baseColor.cgColor
    }

    func updateResizeHandlePath(animated: Bool = false) {
        let bendingScale = max(0.0, min(self.bending, 1.0)) // limit bending between 0 and 1
        let maxBendingOffset: CGFloat = 5.0
        let path = UIBezierPath()

        let width: CGFloat
        if self.isResizing {
            width = 30.0
        } else {
            width = 20.0
        }

        let r = self.bounds.divided(atDistance: 6.0, from: .maxYEdge).slice
        let centerX = r.width / 2.0
        let y = r.minY + self.resizeHandle.lineWidth / 2.0

        path.move(to: CGPoint(x: centerX - width / 2.0, y: y))
        path.addLine(to: CGPoint(x: centerX, y: y + bendingScale * maxBendingOffset))
        path.addLine(to: CGPoint(x: centerX + width / 2.0, y: y))

        if animated {
            self.addAnimation(to: self.resizeHandle)
        }
        self.resizeHandle.path = path.cgPath
    }

    func addAnimation(to layer: CAShapeLayer) {
        let animationKey = "pathAnimation"
        let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)

        layer.removeAnimation(forKey: animationKey)
        layer.add(animation, forKey: animationKey)
    }
}

private extension UIColor {

    func darkened() -> UIColor {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0

        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        return UIColor(hue: hue, saturation: saturation, brightness: brightness - 0.2, alpha: alpha)
    }
}
