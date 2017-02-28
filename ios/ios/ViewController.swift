//
//  ViewController.swift
//  ios
//
//  Created by ywen on 2017/2/27.
//  Copyright © 2017年 ywen. All rights reserved.
//

import UIKit
import SocketIO
import UserNotifications

class ViewController: UIViewController {
    var textField: UITextField!
    var btn: UIButton!
    let socket = SocketIOClient(socketURL: URL(string: "http://localhost:3000")!, config: [.log(true), .forcePolling(true)])
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        socket.on("news") {data, ack in
            print("news:", data)
            if let dic = data[0] as? [String: AnyObject] {
                print("dic:", dic)
                let content: UNMutableNotificationContent = UNMutableNotificationContent();
                content.title = "hello"
                content.body = "推送内容：\(dic)"
                content.sound = UNNotificationSound.default()
                let trigger: UNTimeIntervalNotificationTrigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 0.5, repeats: false)
                let request: UNNotificationRequest = UNNotificationRequest.init(identifier: "test", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: { (err) in
                    if (err == nil) {
                        print("推送成功！");
                    } else {
                        print("推送失败\(err)")
                    }
                })
            }
        
        }
        
        
        socket.connect()
        
        if let app: AppDelegate = UIApplication.shared.delegate as? AppDelegate {
            app.socket = socket
        }
        
        
        // 视图
        
        self.createUI()
    }
    
    func createUI() {
        self.view.backgroundColor = UIColor.blue
        let screenSize: CGRect = UIScreen.main.bounds
        textField = UITextField.init(frame: CGRect(x: 30, y: 30, width: screenSize.width - 60, height: 50))
        textField.backgroundColor = UIColor.white
        textField.tintColor = UIColor.black
        self.view.addSubview(textField)
        
        btn = UIButton.init(frame: CGRect(x: (screenSize.width - 80) / 2, y: 180, width: 80, height: 35))
        btn.backgroundColor = UIColor.red
        btn.setTitleColor(UIColor.black, for: .highlighted)
        btn.setTitle("发送", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.addTarget(self, action: #selector(send), for: .touchUpInside)
        self.view.addSubview(btn)
    }
    
    func send() {
        print("click btn")
        let text = textField.text
        if (text?.lengthOfBytes(using: .utf8))! > 0 {
            socket.emit("msg", ["msg": text])
        } else {
            let alert = UIAlertController(title: "提示", message: "请填写内容", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
                //execute some code when this option is selected
                
            }))
            self.present(alert, animated: true, completion: nil)

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

