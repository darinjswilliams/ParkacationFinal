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
import SystemConfiguration

class LoginViewController: UIViewController, LoginButtonDelegate {
 

    
    @IBOutlet weak var emailAddress: UITextField!
    
    @IBOutlet weak var passWord: UITextField!
    

    @IBOutlet weak var signInSelector: UISegmentedControl!
    
    
    @IBOutlet weak var signInLabel: UILabel!
    
    var isSignIn: Bool = true
    
    
    @IBOutlet weak var signInRegisterButton: UIButton!
    
    @IBOutlet weak var signInActivityInd: UIActivityIndicatorView!
    
    

   private let reachability = SCNetworkReachabilityCreateWithName(nil , "www.udacity.com")
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkReachable()
        
        let fbLoginButton = FBLoginButton()
        
        
        view.addSubview(fbLoginButton)
        
        fbLoginButton.frame = CGRect(x: 20, y: 760, width: view.frame.width - 32, height: 40)
        
        fbLoginButton.delegate = self
    }
    
    
    private func checkReachable(){
        
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(self.reachability!, &flags)
        
        if(isNetworkReachable(with: flags)){
            
            debugPrint(flags)
            
            if(flags.contains(.isWWAN)){
                
                debugPrint("Reachable isWWAN")
                
            }
        } else if(!isNetworkReachable(with:flags)){
            self.showInfo(withMessage: "No Internet Connection")
            return
        }
        
        
    }
    
    
    private func isNetworkReachable(with flags: SCNetworkReachabilityFlags) -> Bool {
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
          let canConnectionWithoutUserInteraction = canConnectAutomatically && !flags.contains(.interventionRequired)
        return isReachable && (!needsConnection || canConnectionWithoutUserInteraction)
    }
    
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        
     signInActivityInd.startAnimating()
        
    checkReachable()
    
        
    if Reachability.isInternetAvailable() == true {
        
  
        
        
        if let emailAddr = self.emailAddress.text, let passWrd = self.passWord.text{
            
            //Check if it is sign in or register
            if isSignIn{
                //Sign in user with Firebase
                
                Auth.auth().signIn(withEmail: emailAddr, password: passWrd, completion: { (user, error) in
                    
                    //Check to see if user is not nil
                    if let u = user {
                        // User is found go to home screen
                        
                        
                        //SAVED TO USER DEFAULTS
                        UserDefaults.standard.setValue(true, forKey: "userIsLoggedIn")
                        
                        //save to device
                        UserDefaults.standard.synchronize()
                        
                        debugPrint("Successful Login \(u)")
                        self.performSegue(withIdentifier: "goToTabs", sender: self)
               
                        
                    }else{
                        //Error occurred Check Error and show message
                        self.showInfo(withMessage: "Check Credentials")
                        debugPrint("loginController: Could not Sigin User:  \(String(describing: user))")
                        
                    }
                    
                })
                
            }else{
                //Register the User with Firebase
                       
                Auth.auth().createUser(withEmail: emailAddr, password: passWrd, completion: { (user, error) in
                    
                    //Check to see if user is not nil
                    if user != nil{
                    
                        
                        //MARK SAVED  KETY TO USER DEFAULTS
                        UserDefaults.standard.setValue(true, forKey: "userIsLoggedIn")
                        
                        //Syncrhronize to write key to device
                        UserDefaults.standard.synchronize()
                        self.performSegue(withIdentifier: "goToTabs", sender: self)
               
                        
                    }else{
                        //Error occurred Check Error and show message
                        self.showInfo(withMessage: "Check Credentials")
                        debugPrint("loginController: Could not Create User:  \(String(describing: user))")
                        
                    }
                    
                })
   
            }
            
            
        }
    } else {
        
        signInActivityInd.startAnimating()
        
        self.showInfo(withMessage: "No Internet Connection")
        
        }
        

    }
    
    
   //MARK CHECK UserDefaults for Previous Login
 @objc func userIsLoggedIn() -> Bool {
     
       return  UserDefaults.standard.bool(forKey: "userIsLoggedIn")
    }
    
    
    @IBAction func signInSelectorChange(_ sender: UISegmentedControl) {
        
        isSignIn = !isSignIn
        
        //check boolean value and set the button and label
        if isSignIn{
            signInLabel.text = "Sign In"
            
            //Change title on Button to Sign in
            signInRegisterButton.setTitle("Sign In", for: .normal)
            
        }else{
  
            signInLabel.text="Register"
            signInRegisterButton.setTitle("Register", for: .normal)
        }
        
    }
    
   //MARK FACEBOOK FUNCTIONS
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
         signInActivityInd.startAnimating()
        
         checkReachable()
        
        if Reachability.isInternetAvailable() == true {
            
        
        if error != nil{
            debugPrint(error)
            return
        }else{

            debugPrint("Logged in Successfully with facebook")
            let parkController = storyboard?.instantiateViewController(withIdentifier: "TabViewController") as! UITabBarController
            
             UserDefaults.standard.setValue(true, forKey: "userIsLoggedIn")
            
            
            present(parkController, animated: false, completion: nil)
  
   
        }
            
        } else {
            
            self.showInfo(withMessage: "No internet Connection, Please try later")
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        debugPrint("Logged out of facebook")
        performUIUpdatesOnMain {
            
            let fbLoginManager : LoginManager = LoginManager()
            fbLoginManager.logOut()
            self.dismiss(animated: true, completion: nil)
        }
    }
    

}
