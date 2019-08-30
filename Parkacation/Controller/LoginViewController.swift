//
//  LoginViewController.swift
//  Parkacation
//
//  Created by Darin Williams on 8/28/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class LoginViewController: UIViewController, LoginButtonDelegate {
 

    
    @IBOutlet weak var emailAddress: UITextField!
    
    @IBOutlet weak var passWord: UITextField!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
   
        let fbLoginButton = FBLoginButton()
        
        view.addSubview(fbLoginButton)
        
        fbLoginButton.frame = CGRect(x: 20, y: 760, width: view.frame.width - 32, height: 40)
        
        fbLoginButton.delegate = self
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        
        guard let emailAddr = self.emailAddress else {
            return
        }
        
        
    }
    
    
    @IBAction func regisButton(_ sender: UIButton) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        if error != nil{
            debugPrint(error)
            return
        }else{
            debugPrint("Logged in Successfully with facebook")
            self.performSegue(withIdentifier: "goToHome", sender: self)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        debugPrint("Logged out of facebook")
    }
    

}
