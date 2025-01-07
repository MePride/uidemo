// ImageEditorViewController+Actions.swift
import UIKit
import Photos

extension ImageEditorViewController {
    @objc func resetButtonTapped() {
        UIView.animate(withDuration: 0.3) {
            self.currentScale = 1.0
            self.currentRotation = 0
            self.imageView.transform = .identity
            self.imageView.center = self.containerView.center
        }
    }
    
    @objc func saveButtonTapped() {
        guard let image = imageView.image else {
            showAlert(message: "请先选择图片")
            return
        }
        
        // 创建一个和容器视图大小相同的上下文
        UIGraphicsBeginImageContextWithOptions(containerView.bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 保存当前上下文状态
        context.saveGState()
        
        // 将绘制范围限制在容器视图的bounds内
        context.addRect(containerView.bounds)
        context.clip()
        
        // 将容器视图的内容渲染到上下文
        containerView.drawHierarchy(in: containerView.bounds, afterScreenUpdates: true)
        
        // 恢复上下文状态
        context.restoreGState()
        
        // 获取最终图片
        if let editedImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIImageWriteToSavedPhotosAlbum(editedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        
        UIGraphicsEndImageContext()
    }

    
    @objc func selectImageButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlert(message: "保存失败: \(error.localizedDescription)")
        } else {
            showAlert(message: "图片已保存到相册")
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ImageEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            
            // 计算图片在容器中的适当大小
            let containerSize = containerView.bounds.size
            let imageSize = image.size
            
            let widthRatio = containerSize.width / imageSize.width
            let heightRatio = containerSize.height / imageSize.height
            let scale = min(widthRatio, heightRatio)
            
            // 设置图片视图的大小约束
            imageView.removeConstraints(imageView.constraints)
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: imageSize.width * scale),
                imageView.heightAnchor.constraint(equalToConstant: imageSize.height * scale)
            ])
            
            resetButtonTapped()
        }
        picker.dismiss(animated: true)
    }
}
