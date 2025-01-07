// ImageEditorViewController+Gestures.swift
import UIKit

extension ImageEditorViewController {
    func setupGestures() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        
        imageView.addGestureRecognizer(pinchGesture)
        imageView.addGestureRecognizer(panGesture)
        imageView.addGestureRecognizer(rotationGesture)
        
        // 允许手势同时识别
        panGesture.delegate = self
        pinchGesture.delegate = self
        rotationGesture.delegate = self
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }
        
        if gesture.state == .began || gesture.state == .changed {
            currentScale *= gesture.scale
            // 限制缩放范围
            currentScale = min(max(currentScale, 0.5), 3.0)
            updateTransform()
            gesture.scale = 1.0
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        
        if gesture.state == .began || gesture.state == .changed {
            let translation = gesture.translation(in: view.superview)
            view.center = CGPoint(
                x: view.center.x + translation.x,
                y: view.center.y + translation.y
            )
            gesture.setTranslation(.zero, in: view.superview)
        }
    }
    
    @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        if gesture.state == .began || gesture.state == .changed {
            currentRotation += gesture.rotation
            updateTransform()
            gesture.rotation = 0
        }
    }
    
    private func updateTransform() {
        let transform = CGAffineTransform.identity
            .scaledBy(x: currentScale, y: currentScale)
            .rotated(by: currentRotation)
        imageView.transform = transform
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ImageEditorViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
