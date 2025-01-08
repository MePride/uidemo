// ImageEditorViewController+Actions.swift
import UIKit
import Photos

extension ImageEditorViewController {
    @objc func resetButtonTapped() {
        UIView.animate(withDuration: 0.3) {
        self.currentScale = 1.0
        self.currentRotation = 0
        self.imageView.transform = .identity
        let centerX = self.containerView.bounds.width / 2
        let centerY = self.containerView.bounds.height / 2
        self.imageView.center = CGPoint(x: centerX, y: centerY)
    }
}
    @objc func saveButtonTapped() {
        guard let image = imageView.image else {
            showAlert(message: "请先选择图片")
            return
        }
        let originalCornerRadius = containerView.layer.cornerRadius
        containerView.layer.cornerRadius = 0
        UIGraphicsBeginImageContextWithOptions(containerView.bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            containerView.layer.cornerRadius = originalCornerRadius
            return
        }
        containerView.drawHierarchy(in: containerView.bounds, afterScreenUpdates: true)
        if let editedImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIImageWriteToSavedPhotosAlbum(editedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        UIGraphicsEndImageContext()
        containerView.layer.cornerRadius = originalCornerRadius
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

extension ImageEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            updateContainerAspectRatio()
            let containerSize = containerView.bounds.size
            let imageSize = image.size
            
            let widthRatio = containerSize.width / imageSize.width
            let heightRatio = containerSize.height / imageSize.height
            let scale = min(widthRatio, heightRatio)
            imageView.removeConstraints(imageView.constraints)
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: imageSize.width * scale),
                imageView.heightAnchor.constraint(equalToConstant: imageSize.height * scale),
                imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
            ])
            self.currentScale = 1.0
            self.currentRotation = 0
            self.imageView.transform = .identity
        }
        picker.dismiss(animated: true)
    }
}
