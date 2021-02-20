//
//  ViewController.swift
//  ConexUp
//
//  Created by Mohammed Haque on 1/14/21.
//

import UIKit
import PhoneNumberKit

class LoginViewController: UIViewController {

    let phoneNumberKit = PhoneNumberKit()
    
    @IBOutlet weak var outputLabel: UILabel!                    // The label that will output the error or success statements.
    @IBOutlet weak var countryCode: PhoneNumberTextField!       // The uninteractable text field with the country code.
    @IBOutlet weak var numberField: PhoneNumberTextField!       // The interactable text field for user input of their number.
    @IBOutlet var tapGesture: UITapGestureRecognizer!           // The tap gesture recognizer for hiding the keyboard.
    @IBOutlet weak var verifyButton: UIButton!                  // The button that will be pressed to display the output label.    
    
    let gradientView = CAGradientLayer()                        // Gradient layer for background of the view.
    let gradientBtn = CAGradientLayer()                         // Gradient layer for the verify button.
    
    var rawNum = ""                                             // The phone number that user inputted.
    let animate = Animate()                                     // Animate class instantiated as a variable.
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Create vertical gradient for background.
        gradientView.frame = view.bounds
        gradientView.colors = [#colorLiteral(red: 0, green: 0.368627451, blue: 0.2509803922, alpha: 0.8470588235).cgColor, #colorLiteral(red: 0, green: 0.368627451, blue: 0.2509803922, alpha: 0.8470588235).cgColor, #colorLiteral(red: 0.9843137255, green: 0.7882352941, blue: 0.003921568627, alpha: 0.8470588235).cgColor]
        // Rasterize to improve app performance.
        gradientView.shouldRasterize = true
        // Apply gradient to first layer.
        view.layer.insertSublayer(gradientView, at: 0)
        
        // Create horizontal gradient for the verify button.
        // Make the verify button corners curved.
        verifyButton.layer.cornerRadius = 16
        // Setup the gradient for the verify button.
        gradientBtn.frame = verifyButton.bounds
        gradientBtn.colors = [#colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1).cgColor, #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1).cgColor]
        gradientBtn.shouldRasterize = true
        // Start and end points make the gradient horizontal.
        gradientBtn.startPoint = CGPoint(x: 0, y: 0.5)
        gradientBtn.endPoint = CGPoint(x: 1, y: 0.5)
        // Make the gradient corners curved to fit button.
        gradientBtn.cornerRadius = 16
        verifyButton.layer.insertSublayer(gradientBtn, at: 0)
        
        // Tap gesture recognizer to hide keyboard.
        tapGesture.addTarget(self, action: #selector(hideKeyboard))
        
        // Line to prevent snapshot view warning (doesn't work)
        view.snapshotView(afterScreenUpdates: true)
        
        // Set prefix, flag icon, and example placeholder for text fields.
        numberField.withPrefix = false
        numberField.withFlag = false
        numberField.withExamplePlaceholder = true
        
        countryCode.withFlag = true
        numberField.withPrefix = false
        
        // Allow user to clear while editing in numberField.
        numberField.clearButtonMode = .whileEditing
        
        // Hide navigation bar for this view.
        self.navigationController?.isNavigationBarHidden = true
        
        // Pre-fill phone number text field with user's.
        numberField.text = Storage.phoneNumberInE164
        checkInputNumber()
    }
    
    // Function to hide the keyboard that is called after a tap. #selector required function to be exposed to objc.
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    // Function to check numberField on change and highlight or unhighlight the verify button.
    @IBAction func checkInputNumber() {
        if numberField.isValidNumber {
            gradientBtn.colors = [#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1).cgColor, #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1).cgColor]
            verifyButton.setTitleColor(UIColor.white, for: .normal)
        }
        else {
            gradientBtn.colors = [#colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1).cgColor, #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1).cgColor]
            verifyButton.setTitleColor(UIColor.lightGray, for: .normal)
        }
    }
    
    // Function to check if number is valid after button press and output a response.
    @IBAction func verifyButtonPressed() {
        if numberField.isValidNumber {
            // Unwrap String optional in order to format to e164.
            guard let inputNum = numberField.phoneNumber else { return }
            rawNum = phoneNumberKit.format(inputNum, toType: .e164)
            // Hide output label if it is currently displayed.
            self.outputLabel.text = nil
            // Create storyboard variable to push the verify view controller onto the stack.
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            animate.animateViewAlphaOut(view, 0.2)
            
            Api.user { (response, error) in
                if let walletData = response {
                    // If user is previously logged in user, send them to wallet, else verify.
                    if Storage.authToken != nil, Storage.phoneNumberInE164 == self.rawNum {
                        guard let vc = storyboard.instantiateViewController(withIdentifier: "walletViewController") as? WalletViewController  else { assertionFailure("Couldn't find wallet view controller."); return }
                        // Send the phone number, username, and wallet to wallet view controller.
                        let savedUserName = response?["user"] as? [String:Any]
                        let wallet = Wallet.init(data: walletData, ifGenerateAccounts: false)
                        vc.rawNum = self.rawNum
                        vc.userName = savedUserName?["name"] as? String ?? ""
                        vc.wallet = wallet
                        // Set the stack so that it only contains home and animate it.
                        let walletViewController = [vc]
                        self.navigationController?.setViewControllers(walletViewController, animated: true)
                    }
                    else {
                        Api.sendVerificationCode(phoneNumber: self.rawNum) { (_ response : [String : Any]?, _ error : Api.ApiError?) in
                            // If sending code is successful, push the verify view controller onto the stack.
                            if response?["status"] != nil {
                                self.animate.animateViewAlphaIn(self.view, 0.2)
                                guard let verifyViewController = storyboard.instantiateViewController(withIdentifier: "verifyViewController") as? VerifyViewController  else { assertionFailure("Couldn't find verify view controller."); return }
                                // Set verify view controller's rawNum variable to the user's number and set username to phone number.
                                verifyViewController.rawNum = self.rawNum
                                self.navigationController?.isNavigationBarHidden = false
                                self.navigationController?.pushViewController(verifyViewController, animated: true)
                            }
                            // If sending code is unsuccessful, animate the output label with the verify button.
                            else if let e = error?.message {
                                self.outputLabel.textColor =  UIColor.red
                                self.outputLabel.text = e
                                
                                self.animate.animateViewAlphaIn(self.view, 0.2)
                                self.animate.animateButtonOut(self.verifyButton, 0.2)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                    self.animate.animateLabelInOut(self.outputLabel, 0.3, 0.3, 0.3, 1.2)
                                    self.animate.animateButtonIn(self.verifyButton, 0.3, 2.4)
                                }
                            }
                        }
                    }
                }
                else {
                    Api.sendVerificationCode(phoneNumber: self.rawNum) { (_ response : [String : Any]?, _ error : Api.ApiError?) in
                        // If sending code is successful, push the verify view controller onto the stack.
                        if response?["status"] != nil {
                            self.animate.animateViewAlphaIn(self.view, 0.2)
                            guard let verifyViewController = storyboard.instantiateViewController(withIdentifier: "verifyViewController") as? VerifyViewController  else { assertionFailure("Couldn't find verify view controller."); return }
                            // Set verify view controller's rawNum variable to the user's number and set username to phone number.
                            verifyViewController.rawNum = self.rawNum
                            self.navigationController?.isNavigationBarHidden = false
                            self.navigationController?.pushViewController(verifyViewController, animated: true)
                        }
                        // If sending code is unsuccessful, animate the output label with the verify button.
                        else if let e = error?.message {
                            self.outputLabel.textColor =  UIColor.red
                            self.outputLabel.text = e
                            
                            self.animate.animateViewAlphaIn(self.view, 0.2)
                            self.animate.animateButtonOut(self.verifyButton, 0.2)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                self.animate.animateLabelInOut(self.outputLabel, 0.3, 0.3, 0.3, 1.2)
                                self.animate.animateButtonIn(self.verifyButton, 0.3, 2.4)
                            }
                        }
                    }
                }
            }
        }
        else {
            outputLabel.textColor =  UIColor.red
            // Obtain the current number inputted to check if it's too long, too short, or a valid US number.
            let nationalNum = numberField.nationalNumber
            let region = numberField.currentRegion
            if nationalNum.count < 10 {
                outputLabel.text = "Number given is too short"
                animate.animateButtonOut(verifyButton, 0.2)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                    self.animate.animateLabelInOut(self.outputLabel, 0.3, 0.3, 0.3, 1.2)
                    self.animate.animateButtonIn(self.verifyButton, 0.3, 2.4)
                }
            }
            else if nationalNum.count > 10 {
                outputLabel.text = "Number given is too long"
                animate.animateButtonOut(verifyButton, 0.2)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                    self.animate.animateLabelInOut(self.outputLabel, 0.3, 0.3, 0.3, 1.2)
                    self.animate.animateButtonIn(self.verifyButton, 0.3, 2.4)
                }
            }
            else if region != "US" {
                outputLabel.text = "Enter a \(region) number"
                animate.animateButtonOut(verifyButton, 0.2)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                    self.animate.animateLabelInOut(self.outputLabel, 0.3, 0.3, 0.3, 1.2)
                    self.animate.animateButtonIn(self.verifyButton, 0.3, 2.4)
                }
            }
            else {
                outputLabel.text = "Enter a valid \(region) number"
                animate.animateButtonOut(verifyButton, 0.2)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                    self.animate.animateLabelInOut(self.outputLabel, 0.3, 0.3, 0.3, 1.2)
                    self.animate.animateButtonIn(self.verifyButton, 0.3, 2.4)
                }
            }
        }
    }
}

