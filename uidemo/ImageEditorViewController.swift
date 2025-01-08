// ImageEditorViewController.swift
import UIKit
import Photos

class ImageEditorViewController: UIViewController {
    private var isSquareMode = false
    private var containerWidthConstraint: NSLayoutConstraint?
    private var containerHeightConstraint: NSLayoutConstraint?
    private var containerAspectConstraint: NSLayoutConstraint?
    internal var imageView: UIImageView!
    internal var containerView: UIView!
    private var borderLayer: CAShapeLayer!
    
    internal var currentScale: CGFloat = 1.0
    internal var currentRotation: CGFloat = 0.0
    
    private enum Constants {
          static let cornerRadius: CGFloat = 8
          static let buttonHeight: CGFloat = 36
          static let margin: CGFloat = 16
          static let toolbarHeight: CGFloat = 44
          static let borderWidth: CGFloat = 2
      }
      
      private lazy var topBarView: UIView = {
          let view = UIView()
          view.backgroundColor = .systemBackground
          view.translatesAutoresizingMaskIntoConstraints = false
          return view
      }()
      
      private lazy var originalRatioButton: UIButton = {
          var configuration = UIButton.Configuration.filled()
          configuration.title = "原始比例"
          configuration.cornerStyle = .medium
          configuration.baseForegroundColor = .white
          configuration.baseBackgroundColor = .systemBlue
          
          let button = UIButton(configuration: configuration)
          button.translatesAutoresizingMaskIntoConstraints = false
          button.addTarget(self, action: #selector(originalRatioButtonTapped), for: .touchUpInside)
          return button
      }()
      
      private lazy var squareRatioButton: UIButton = {
          var configuration = UIButton.Configuration.plain()
          configuration.title = "正方形"
          configuration.cornerStyle = .medium
          configuration.baseForegroundColor = .systemBlue
          
          let button = UIButton(configuration: configuration)
          button.translatesAutoresizingMaskIntoConstraints = false
          button.addTarget(self, action: #selector(squareRatioButtonTapped), for: .touchUpInside)
          return button
      }()
    
    private lazy var toolbarView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var resetButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.title = "重置"
        configuration.image = UIImage(systemName: "arrow.counterclockwise")
        configuration.imagePlacement = .leading
        configuration.imagePadding = 8
        
        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "保存"
        configuration.cornerStyle = .medium
        
        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var selectImageButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.title = "选择图片"
        configuration.image = UIImage(systemName: "photo")
        configuration.imagePlacement = .leading
        configuration.imagePadding = 8
        
        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(selectImageButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
    }
}

extension ImageEditorViewController {
    
    @objc internal func originalRatioButtonTapped() {
        isSquareMode = false
        updateContainerAspectRatio()

        var originalConfig = UIButton.Configuration.filled()
        originalConfig.title = "原始比例"
        originalConfig.cornerStyle = .medium
        originalConfig.baseForegroundColor = .white
        originalConfig.baseBackgroundColor = .systemBlue
        originalRatioButton.configuration = originalConfig
        
        var squareConfig = UIButton.Configuration.plain()
        squareConfig.title = "正方形"
        squareConfig.cornerStyle = .medium
        squareConfig.baseForegroundColor = .systemBlue
        squareRatioButton.configuration = squareConfig
    }

    @objc internal func squareRatioButtonTapped() {
        isSquareMode = true
        updateContainerAspectRatio()

        var squareConfig = UIButton.Configuration.filled()
        squareConfig.title = "正方形"
        squareConfig.cornerStyle = .medium
        squareConfig.baseForegroundColor = .white
        squareConfig.baseBackgroundColor = .systemBlue
        squareRatioButton.configuration = squareConfig
        
        var originalConfig = UIButton.Configuration.plain()
        originalConfig.title = "原始比例"
        originalConfig.cornerStyle = .medium
        originalConfig.baseForegroundColor = .systemBlue
        originalRatioButton.configuration = originalConfig
    }
    
    func updateContainerAspectRatio() {
        containerAspectConstraint?.isActive = false
        containerAspectConstraint = nil
        
        let containerWidth = containerView.bounds.width
        
        if isSquareMode {
            // 正方形模式：添加1:1的宽高比约束
            containerAspectConstraint = containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 1.0)
        } else if let image = imageView.image {
            // 原始比例模式：使用图片的原始宽高比
            let aspectRatio = image.size.height / image.size.width
            containerAspectConstraint = containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: aspectRatio)
        }
        containerAspectConstraint?.isActive = true
        view.setNeedsLayout()
        view.layoutIfNeeded()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.updateImageViewConstraints()
        }
    }
    
    private func updateImageViewConstraints() {
         guard let image = imageView.image else { return }
         imageView.transform = .identity
         currentScale = 1.0
         currentRotation = 0
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
     }
    
    private func setupUI() {
        // 设置导航栏
        navigationItem.title = "图片编辑"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.backgroundColor = .systemBackground
        
        // 设置容器视图
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.clipsToBounds = true
        containerView.backgroundColor = .systemGray6
        containerView.layer.cornerRadius = Constants.cornerRadius
        view.addSubview(containerView)
        
        // 设置图片视图
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageView)
        
        setupTopBar()
        setupToolbar()
        setupConstraints()
    }
    
    private func setupTopBar() {
        view.addSubview(topBarView)
        topBarView.addSubview(originalRatioButton)
        topBarView.addSubview(squareRatioButton)
        
        NSLayoutConstraint.activate([
            topBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBarView.heightAnchor.constraint(equalToConstant: Constants.toolbarHeight),
            
            originalRatioButton.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor),
            originalRatioButton.leadingAnchor.constraint(equalTo: topBarView.leadingAnchor, constant: Constants.margin),
            originalRatioButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            
            squareRatioButton.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor),
            squareRatioButton.trailingAnchor.constraint(equalTo: topBarView.trailingAnchor, constant: -Constants.margin),
            squareRatioButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
        ])
    }
    
    private func setupToolbar() {
        toolbarView.backgroundColor = .systemBackground
        toolbarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbarView)
        
        [resetButton, saveButton, selectImageButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            toolbarView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        // 移除之前可能存在的约束
        containerWidthConstraint?.isActive = false
        containerHeightConstraint?.isActive = false
        containerAspectConstraint?.isActive = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topBarView.bottomAnchor, constant: Constants.margin),

            toolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbarView.heightAnchor.constraint(equalToConstant: 60),
                  
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.topAnchor.constraint(equalTo: topBarView.bottomAnchor, constant: Constants.margin),
            containerView.bottomAnchor.constraint(lessThanOrEqualTo: toolbarView.topAnchor, constant: -Constants.margin),
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: Constants.margin),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -Constants.margin),

            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            imageView.widthAnchor.constraint(lessThanOrEqualTo: containerView.widthAnchor),
            imageView.heightAnchor.constraint(lessThanOrEqualTo: containerView.heightAnchor),

            resetButton.leadingAnchor.constraint(equalTo: toolbarView.leadingAnchor, constant: 20),
            resetButton.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            
            saveButton.trailingAnchor.constraint(equalTo: toolbarView.trailingAnchor, constant: -20),
            saveButton.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            
            selectImageButton.centerXAnchor.constraint(equalTo: toolbarView.centerXAnchor),
            selectImageButton.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
        ])

        containerWidthConstraint = containerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -Constants.margin * 2)
        containerWidthConstraint?.isActive = true

        if let image = imageView.image {
            let aspectRatio = image.size.height / image.size.width
            containerAspectConstraint = containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: aspectRatio)
        } else {
            containerAspectConstraint = containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 1.0)
        }
        containerAspectConstraint?.isActive = true
    }
}
