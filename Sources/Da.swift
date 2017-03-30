//
//  Da.swift
//  Da
//
//  Created by Leo on 03/03/2017.
//
//  Copyright (c) 2017 Leo <leodaxia@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import UIKit
import SnapKit

public typealias DaPresentHandler = ((_ da: Da) -> Void)?
public typealias DaClickedHandler = ((_ da: Da, _ buttonIndex: NSInteger) -> Void)?

open class Da: UIView {
    
    public static var hairColor: UIColor  = UIColor(daHexString: "#1EB8F3")
    public static var titleFont: UIFont   = UIFont.systemFont(ofSize: 20.0)
    public static var messageFont: UIFont = UIFont.systemFont(ofSize: 16.0)
    public static var buttonFont: UIFont  = UIFont.systemFont(ofSize: 18.0)
    
    private var hairColor: UIColor!
    
    public var cancelButtonIndex: Int {
        get {
            return self.buttonsCount <= 2 ? 0 : self.buttonsCount - 1
        }
    }
    
    public var keyWindow: UIWindow? = UIApplication.shared.keyWindow
    
    public var clickedHandle:      DaClickedHandler
    public var willPresentHanlder: DaPresentHandler
    public var didPresentHanlder:  DaPresentHandler
    public var willDismissHandler: DaClickedHandler
    public var didDismissHandler:  DaClickedHandler
    
    public var showing: Bool = false
    
    private var title:             String?
    private var message:           String?
    private var cancelButtonTitle: String!
    public var otherButtonTitles: [String] = []
    
    public var destructiveButtonColor: UIColor = UIColor(daHexString: "#FF0A0A") {
        didSet {
            self.updateDestructive()
        }
    }
    public var destructiveButtonIndexSet: Set<Int>? {
        didSet {
            self.updateDestructive()
        }
    }
    
    private var buttons: [UIButton] = []
    private var lines:   [UIView]   = []
    
    private var darkView:         UIView!
    private var hairView:         UIView!
    private var container:        UIView!
    private var titleLabel:       UILabel!
    private var messageLabel:     UILabel!
    private var buttonsContainer: UIView!
    
    private let containerW: CGFloat = UIScreen.main.bounds.size.width - 80.0
    private let titleTop: CGFloat   = 20.0
    private let buttonH: CGFloat    = 50.0
    private var contentW: CGFloat {
        get {
            return self.containerW - 30.0
        }
    }
    
    private var buttonsCount: Int {
        get {
            var buttonsCount = 1
            buttonsCount += self.otherButtonTitles.count
            return buttonsCount
        }
    }
    
    private var hasTitle: Bool {
        get {
            return self.title != nil && !self.title!.isEmpty
        }
    }
    private var hasMessage: Bool {
        get {
            return self.message != nil && !self.message!.isEmpty
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private convenience init(title: String?,
                             message: String?,
                             hairColor: UIColor! = Da.hairColor,
                             cancelButtonTitle: String!,
                             clickedHandler: DaClickedHandler = nil,
                             willPresentHanlder: DaPresentHandler = nil,
                             didPresentHanlder: DaPresentHandler = nil,
                             willDismissHandler: DaClickedHandler = nil,
                             didDismissHandler: DaClickedHandler = nil,
                             otherButtonTitles firstButtonTitle: String?, _ moreButtonTitles: [String]?) {
        self.init(frame: CGRect.zero)
        
        self.title               = title
        self.message             = message
        self.hairColor           = hairColor
        self.cancelButtonTitle   = cancelButtonTitle
        if let firstButtonTitle = firstButtonTitle {
            self.otherButtonTitles.append(firstButtonTitle)
        }
        if let moreButtonTitles = moreButtonTitles {
            self.otherButtonTitles.append(contentsOf: moreButtonTitles)
        }
        
        self.clickedHandle      = clickedHandler
        self.willPresentHanlder = willPresentHanlder
        self.didPresentHanlder  = didPresentHanlder
        self.willDismissHandler = willDismissHandler
        self.didDismissHandler  = didDismissHandler
    }
    
    private func setupMainView() {
        guard !self.showing else {
            print("Error: This Da instance is showing now!")
            return
        }
        guard let keyWindow = self.keyWindow else { return }
        
        self.showing = true
        
        keyWindow.addSubview(self)
        self.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        
        self.darkView = UIView()
        self.darkView.backgroundColor = UIColor.black
        self.addSubview(self.darkView)
        self.darkView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.container = UIView()
        self.container.backgroundColor = UIColor.white
        self.container.layer.cornerRadius  = 4.0
        self.container.layer.masksToBounds = true
        self.addSubview(self.container)
        self.container.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(self.containerW)
            make.height.equalTo(100.0)
        }
        
        self.hairView = UIView()
        self.hairView.backgroundColor = self.hairColor
        container.addSubview(self.hairView)
        self.hairView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(4.0)
        }
        
        self.titleLabel = UILabel()
        self.titleLabel.font = Da.titleFont
        self.titleLabel.text = self.title
        self.titleLabel.textColor = UIColor(daHexString: "#333333")
        self.titleLabel.textAlignment = .center
        self.titleLabel.numberOfLines = 0
        container.addSubview(self.titleLabel)
        var titleH: CGFloat = 0
        var msgTop: CGFloat = self.titleTop
        if self.hasTitle {
            let titleSize = NSString(string: self.title!).boundingRect(with: CGSize(width: containerW - 30.0, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSFontAttributeName: self.titleLabel.font], context: nil)
            titleH = titleSize.height + 2.0
            msgTop += titleH + 20.0
        }
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15.0)
            make.right.equalToSuperview().offset(-15.0)
            make.top.equalToSuperview().offset(self.titleTop)
            make.height.equalTo(titleH)
        }
        
        self.messageLabel = UILabel()
        self.messageLabel.font = Da.messageFont
        self.messageLabel.text = self.message
        self.messageLabel.textColor = UIColor(daHexString: "#333333")
        self.messageLabel.textAlignment = .center
        self.messageLabel.numberOfLines = 0
        container.addSubview(self.messageLabel)
        var msgH: CGFloat = 0
        if self.hasMessage {
            let titleSize = NSString(string: self.message!).boundingRect(with: CGSize(width: containerW - 30.0, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSFontAttributeName: self.messageLabel.font], context: nil)
            msgH = titleSize.height + 2.0
        }
        self.messageLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15.0)
            make.right.equalToSuperview().offset(-15.0)
            make.top.equalToSuperview().offset(msgTop)
            make.height.equalTo(msgH)
        }
        
        self.buttonsContainer = UIView()
        container.addSubview(self.buttonsContainer)
        var buttonsContainerH: CGFloat = self.buttonH * CGFloat(self.buttonsCount)
        if self.buttonsCount == 2 {
            buttonsContainerH = self.buttonH
        }
        self.buttonsContainer.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(buttonsContainerH)
        }
        
        self.buttons.removeAll()
        
        let cancelButton = self.generateButton(
            title: self.cancelButtonTitle,
            tag: self.buttonsCount <= 2 ? 0 : self.buttonsCount - 1
        )
        self.buttons.append(cancelButton)
        self.buttonsContainer.addSubview(cancelButton)
        
        for (index, buttonTitle) in self.otherButtonTitles.enumerated() {
            let button = self.generateButton(
                title: buttonTitle,
                tag: self.buttonsCount <= 2 ? index + 1 : index
            )
            self.buttons.append(button)
            self.buttonsContainer.addSubview(button)
        }
        
        self.updateFrames()
        
        self.darkView.alpha = 0
        self.container.alpha = 0.5
        self.container.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
        self.willPresentHanlder?(self)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .allowUserInteraction, animations: {
            self.darkView.alpha      = 0.4
            self.container.alpha     = 1.0
            self.container.transform = CGAffineTransform.identity
        }) { (finish) in
            self.didPresentHanlder?(self)
        }
    }
    
    private func generateButton(title: String?, tag: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.tag = tag
        button.titleLabel?.font = Da.buttonFont
        button.setTitle(title, for: .normal)
        button.setBackgroundImage(UIImage(daColor: UIColor(daHexString: "#EAEAEA")), for: .highlighted)
        button.addTarget(self, action: #selector(self.onButtonClicked), for: .touchUpInside)
        if let destructiveButtonIndexSet = self.destructiveButtonIndexSet {
            button.setTitleColor(destructiveButtonIndexSet.contains(tag) ? self.destructiveButtonColor : UIColor(daHexString: "#333333"), for: .normal)
        } else {
            button.setTitleColor(UIColor(daHexString: "#333333"), for: .normal)
        }
        return button
    }
    
    private func generateLine() -> UIView {
        let line = UIView()
        line.backgroundColor = UIColor(daHexString: "#EAEAEA")
        return line
    }
    
    @objc
    private func onButtonClicked(button: UIButton) {
        self.clickedHandle?(self, button.tag)
        
        self.hide(buttonIndex: button.tag)
    }
    
    private func updateFrames() {
        // Title
        var titleH: CGFloat = 0
        var msgTop: CGFloat = self.titleTop
        if self.hasTitle {
            let titleSize = NSString(string: self.title!).boundingRect(with: CGSize(width: containerW - 30.0, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSFontAttributeName: self.titleLabel.font], context: nil)
            titleH = titleSize.height + 2.0
            msgTop += titleH + 17.0
        }
        self.titleLabel.snp.updateConstraints { (make) in
            make.height.equalTo(titleH)
        }
        
        // Msg
        var msgH: CGFloat = 0
        if self.hasMessage {
            let titleSize = NSString(string: self.message!).boundingRect(with: CGSize(width: containerW - 30.0, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSFontAttributeName: self.messageLabel.font], context: nil)
            msgH = titleSize.height + 2.0
        }
        self.messageLabel.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(msgTop)
            make.height.equalTo(msgH)
        }
        
        // Buttons & Lines
        // In fact, this three line doesn't matter...
        if self.buttonsCount > 2 {
            let cancelButton = self.buttons.removeFirst()
            self.buttons.append(cancelButton)
        }
        
        self.lines.removeAll()
        
        for (_, button) in self.buttons.enumerated() {
            let line = self.generateLine()
            self.lines.append(line)
            self.buttonsContainer.addSubview(line)
            
            if self.buttonsCount <= 2 {
                
                button.snp.makeConstraints({ (make) in
                    make.bottom.equalToSuperview()
                    make.size.equalTo(CGSize(width: self.containerW * (self.buttonsCount == 1 ? 1.0 : 0.5),
                                             height: self.buttonH))
                    make.left.equalToSuperview().offset(self.containerW * 0.5 * CGFloat(button.tag))
                })
                
                if button.tag == 0 {
                    line.snp.makeConstraints({ (make) in
                        make.left.right.equalToSuperview()
                        make.height.equalTo(0.5)
                        make.top.equalTo(button)
                    })
                } else {
                    line.snp.makeConstraints({ (make) in
                        make.top.bottom.equalToSuperview()
                        make.width.equalTo(0.5)
                        make.left.equalTo(button)
                    })
                }
                
            } else {
                
                button.snp.makeConstraints({ (make) in
                    make.centerX.equalToSuperview()
                    make.size.equalTo(CGSize(width: self.containerW, height: self.buttonH))
                    make.top.equalToSuperview().offset(self.buttonH * CGFloat(button.tag))
                })
                
                line.snp.makeConstraints({ (make) in
                    make.left.right.equalToSuperview()
                    make.height.equalTo(0.5)
                    make.top.equalTo(button)
                })
            }
        }
        
        // Container
        let containerH: CGFloat = (self.hasTitle || self.hasMessage ? msgTop : 4.0) + msgH + (self.hasMessage ? 20.0 : 0) + (self.buttonsCount > 2 ? self.buttonH * CGFloat(self.buttonsCount) : self.buttonH)
        self.container.snp.updateConstraints { (make) in
            make.height.equalTo(containerH)
        }
    }
    
    private func updateDestructive() {
        guard let destructiveButtonIndexSet = destructiveButtonIndexSet else {
            return
        }
        for button in self.buttons {
            button.setTitleColor(destructiveButtonIndexSet.contains(button.tag) ? self.destructiveButtonColor : UIColor(daHexString: "#333333"), for: .normal)
        }
    }
    
    private func hide(buttonIndex: Int) {
        self.willDismissHandler?(self, buttonIndex)
        UIView.animate(withDuration: 0.3, animations: {
            self.darkView.alpha      = 0
            self.container.alpha     = 0
            self.container.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: { (finish) in
            self.showing = false
            self.removeFromSuperview()
            self.didDismissHandler?(self, buttonIndex)
        })
    }
    
    // MARK: - Public Func
    
    public convenience init(title: String?,
                            message: String?,
                            hairColor: UIColor! = Da.hairColor,
                            cancelButtonTitle: String!,
                            clickedHandler: DaClickedHandler = nil,
                            willPresentHanlder: DaPresentHandler = nil,
                            didPresentHanlder: DaPresentHandler = nil,
                            willDismissHandler: DaClickedHandler = nil,
                            didDismissHandler: DaClickedHandler = nil,
                            otherButtonTitles firstButtonTitle: String?, _ moreButtonTitles: String...) {
        self.init(title: title,
                  message: message,
                  hairColor: hairColor,
                  cancelButtonTitle: cancelButtonTitle,
                  clickedHandler: clickedHandler,
                  willPresentHanlder: willPresentHanlder,
                  didPresentHanlder: didPresentHanlder,
                  willDismissHandler: willDismissHandler,
                  didDismissHandler: didDismissHandler,
                  otherButtonTitles: firstButtonTitle, moreButtonTitles)
    }
    
    @discardableResult
    public static func showAlert(title: String?,
                                 message: String?,
                                 hairColor: UIColor! = Da.hairColor,
                                 cancelButtonTitle: String!,
                                 clickedHandler: DaClickedHandler = nil,
                                 willPresentHanlder: DaPresentHandler = nil,
                                 didPresentHanlder: DaPresentHandler = nil,
                                 willDismissHandler: DaClickedHandler = nil,
                                 didDismissHandler: DaClickedHandler = nil,
                                 otherButtonTitles firstButtonTitle: String?, _ moreButtonTitles: String...) -> Da {
        
        return Da(title: title,
                  message: message,
                  hairColor: hairColor,
                  cancelButtonTitle: cancelButtonTitle,
                  clickedHandler: clickedHandler,
                  willPresentHanlder: willPresentHanlder,
                  didPresentHanlder: didPresentHanlder,
                  willDismissHandler: willDismissHandler,
                  didDismissHandler: didDismissHandler,
                  otherButtonTitles: firstButtonTitle, moreButtonTitles).show()
    }
    
    @discardableResult
    public func showAlert(title: String?,
                          message: String?,
                          hairColor: UIColor! = Da.hairColor,
                          cancelButtonTitle: String!,
                          clickedHandler: DaClickedHandler = nil,
                          willPresentHanlder: DaPresentHandler = nil,
                          didPresentHanlder: DaPresentHandler = nil,
                          willDismissHandler: DaClickedHandler = nil,
                          didDismissHandler: DaClickedHandler = nil,
                          otherButtonTitles firstButtonTitle: String?, _ moreButtonTitles: String...) -> Da {
        
        return Da(title: title,
                  message: message,
                  hairColor: hairColor,
                  cancelButtonTitle: cancelButtonTitle,
                  clickedHandler: clickedHandler,
                  willPresentHanlder: willPresentHanlder,
                  didPresentHanlder: didPresentHanlder,
                  willDismissHandler: willDismissHandler,
                  didDismissHandler: didDismissHandler,
                  otherButtonTitles: firstButtonTitle, moreButtonTitles).show()
    }
    
    @discardableResult
    public func show() -> Da! {
        self.setupMainView()
        
        return self
    }
}

public extension UIColor {
    public convenience init(daHexString: String, alpha: CGFloat = 1.0) {
        let hex = daHexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255.0,
                  green: CGFloat(g) / 255.0,
                  blue: CGFloat(b) / 255.0,
                  alpha: CGFloat(alpha * 255.0) / 255.0)
    }
}

public extension UIImage {
    public convenience init?(daColor: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        daColor.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
