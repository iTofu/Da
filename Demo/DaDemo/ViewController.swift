//
//  ViewController.swift
//  DaDemo
//
//  Created by Leo on 03/03/2017.
//  Copyright © 2017 Leo. All rights reserved.
//

import UIKit
import Da

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func onAlert1Button() {
        Da.showAlert(title: "温馨提示",
                     message: "您的账号已在其他设备登录，请您注意账号安全。",
                     cancelButtonTitle: "退出",
                     otherButtonTitles: nil)
    }
    
    @IBAction func onAlert2Buttons() {
        let da = Da.showAlert(title: "温馨提示",
                              message: "您的账号已在其他设备登录，请您注意账号安全。",
                              cancelButtonTitle: "退出",
                              otherButtonTitles: "重新登录")
        da.destructiveButtonIndexSet = Set(arrayLiteral: 0)
        da.clickedHandle = { da, buttonIndex in
            print("clickedHandle: \(buttonIndex), \(da.cancelButtonIndex)")
        }
        da.willDismissHandler = { da, buttonIndex in
            print("willDismissHandler: \(buttonIndex), \(da.cancelButtonIndex)")
        }
        da.didDismissHandler = { da, buttonIndex in
            print("didDismissHandler: \(buttonIndex), \(da.cancelButtonIndex)")
        }
    }
    
    @IBAction func onAlert3Buttons() {
        Da.hairColor = UIColor.orange
        let da = Da(title: "温馨提示",
                    message: "您的账号已在其他设备登录，请您注意账号安全。",
                    cancelButtonTitle: "退出",
                    otherButtonTitles: "重新登录", "修改密码")
        da.destructiveButtonIndexSet = Set(arrayLiteral: 0)
        da.destructiveButtonColor = UIColor.orange
        da.clickedHandle = { da, buttonIndex in
            print("clickedHandle: \(buttonIndex), \(da.cancelButtonIndex)")
        }
        da.willPresentHanlder = { da in
            print("willPresentHanlder, \(da.cancelButtonIndex)")
        }
        da.didPresentHanlder = { da in
            print("didPresentHanlder, \(da.cancelButtonIndex)")
        }
        da.willDismissHandler = { da, buttonIndex in
            print("willDismissHandler: \(buttonIndex), \(da.cancelButtonIndex)")
        }
        da.didDismissHandler = { da, buttonIndex in
            print("didDismissHandler: \(buttonIndex), \(da.cancelButtonIndex)")
        }
        da.show()
    }

}

