// ImageEditorViewController.swift
import UIKit
import Photos

class ImageEditorViewController: UIViewController {
    
    // MARK: - Properties
    internal var imageView: UIImageView!
    internal var containerView: UIView! // 用于限制图片移动范围
    internal var toolbarView: UIView!
    private var borderLayer: CAShapeLayer! // 添加这个属性

    // 将这些属性改为 internal
    internal var currentScale: CGFloat = 1.0
    internal var currentRotation: CGFloat = 0.0
    
    private lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("重置", for: .normal)
        button.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("保存", for: .normal)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var selectImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("选择图片", for: .normal)
        button.addTarget(self, action: #selector(selectImageButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
    }
}

// MARK: - UI Setup
extension ImageEditorViewController {
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 设置容器视图
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.clipsToBounds = true
        view.addSubview(containerView)
        
        // 在 viewDidLayoutSubviews 中更新边框路径
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            borderLayer.frame = self.containerView.bounds
            let path = UIBezierPath(rect: self.containerView.bounds)
            borderLayer.path = path.cgPath
        }
        
        // 设置图片视图
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageView)
        
        // 创建边框层
        borderLayer = CAShapeLayer()
        borderLayer.strokeColor = UIColor.systemBlue.cgColor // 或其他颜色
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = 2.0
        borderLayer.lineDashPattern = [6, 3]
        view.layer.addSublayer(borderLayer) // 添加到主视图的层上
        
        // 设置工具栏
        setupToolbar()
        
        // 设置约束
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
           
           // 更新边框层的路径
           let borderFrame = containerView.frame // 使用 frame 而不是 bounds
           borderLayer.frame = borderFrame
           let path = UIBezierPath(rect: borderFrame)
           borderLayer.path = path.cgPath
    }
    
    private func setupToolbar() {
        toolbarView = UIView()
        toolbarView.backgroundColor = .systemBackground
        toolbarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbarView)
        
        [resetButton, saveButton, selectImageButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            toolbarView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 容器视图约束
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // 图片视图约束
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor),
            
            // 工具栏约束
            toolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbarView.heightAnchor.constraint(equalToConstant: 60),
            containerView.bottomAnchor.constraint(equalTo: toolbarView.topAnchor),
            
            // 按钮约束
            resetButton.leadingAnchor.constraint(equalTo: toolbarView.leadingAnchor, constant: 20),
            resetButton.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            
            saveButton.trailingAnchor.constraint(equalTo: toolbarView.trailingAnchor, constant: -20),
            saveButton.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            
            selectImageButton.centerXAnchor.constraint(equalTo: toolbarView.centerXAnchor),
            selectImageButton.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
        ])
    }
}
