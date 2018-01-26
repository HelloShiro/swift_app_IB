//
//  ViewController.swift
//  uber
//
//  Created by SnoopyKing on 2017/11/7.
//  Copyright © 2017年 SnoopyKing. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseAuth
class ViewController: UIViewController {
    
    
    @IBOutlet weak var userModeSwitch: UISwitch!
    
    @IBOutlet weak var loginView: UIView!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBAction func tfUsernameEndEdit(_ sender: UITextField) {
    }
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var buttonOutlet: UIButton!
    
    @IBAction func signInButton(_ sender: UIButton) {
        
        if usernameTextField.text != "" && passwordTextField.text != ""{
            
            authService(email: usernameTextField.text!, password: passwordTextField.text!)
            
        }else{
            displayAlert(title: "Sign In Error", message: "Please enter your email and password.")
        }
    }
    
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    var paused: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoginView()
        setupBackgroundVideo()
    }
    @objc func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: kCMTimeZero)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        avPlayer.play()
        paused = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        avPlayer.pause()
        paused = true
    }
    
    func setupBackgroundVideo(){
        let theURL = Bundle.main.url(forResource:"defaultVideo", withExtension: "mp4")
        
        avPlayer = AVPlayer(url: theURL!)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avPlayer.volume = 0
        avPlayer.actionAtItemEnd = .none
        
        avPlayerLayer.frame = view.layer.bounds
        view.backgroundColor = .clear
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        NotificationCenter.default.addObserver(self,selector: #selector(playerItemDidReachEnd(notification:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,object: avPlayer.currentItem)
    }
    
    func authService(email:String,password:String){
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil{
//                print(error)
                let errorString = String(describing: (error! as NSError).userInfo["error_name"]!)
//                print(errorString)
                if errorString == "ERROR_USER_NOT_FOUND"{
                    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil{
                            self.displayAlert(title: "Create Account Error", message: error!.localizedDescription)
                        }else{
                            //創建用戶
                            if self.userModeSwitch.isOn{
                                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                changeRequest?.displayName = "Passenger"
                                changeRequest?.commitChanges(completion: nil)
                                self.performSegue(withIdentifier: "passengerSegue", sender: self)
                            }else{
                                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                changeRequest?.displayName = "Driver"
                                changeRequest?.commitChanges(completion: nil)
                                self.performSegue(withIdentifier: "driverSegue", sender: self)
                            }
                        }
                    })
                } else {
                self.displayAlert(title: "Sign In Error", message: error!.localizedDescription)
                }
            }else{
                //成功登入
                if user?.displayName == "Passenger"{
                    self.performSegue(withIdentifier: "passengerSegue", sender: self)
                }else{
                    self.performSegue(withIdentifier: "driverSegue", sender: self)
                }
            }
        }
    }
    
    func displayAlert(title:String,message:String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setupLoginView(){
        setCorner(customView: loginView, radius: 10)
        setCorner(customView: buttonOutlet, radius: 10)
    }
    
    func setCorner(customView:UIView, radius:CGFloat){
        customView.layer.cornerRadius = radius
        customView.clipsToBounds = true
        setTextField(customTextField: usernameTextField, iconName: "UserIcon")
        setTextField(customTextField: passwordTextField, iconName: "PasswordIcon")
    }
    func setTextField(customTextField: UITextField, iconName: String){
        customTextField.leftViewMode = UITextFieldViewMode.always
        customTextField.textColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        var iconView = UIImageView()
        iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        iconView.contentMode = UIViewContentMode.scaleAspectFit
        iconView.image = UIImage(named: iconName)
        customTextField.leftView = iconView
        customTextField.borderStyle = UITextBorderStyle.line
        customTextField.layer.borderWidth = 1
        customTextField.layer.borderColor = #colorLiteral(red: 0.7793677137, green: 0.7793677137, blue: 0.7793677137, alpha: 1)
    }
}

