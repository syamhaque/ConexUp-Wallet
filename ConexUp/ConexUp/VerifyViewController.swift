//
//  VerifyViewController.swift
//  ConexUp
//
//  Created by Mohammed Haque on 1/23/21.
//

import UIKit

class VerifyViewController: UIViewController, PinTexFieldDelegate {
    
    @IBOutlet var verifyVC: UIView!                             // Verify View Controller insantiated as a variable.
    @IBOutlet weak var errorLabel: UILabel!                     // Label to hold the error message.
    @IBOutlet var tapGesture: UITapGestureRecognizer!           // Gesture recognizer to hide keyboard.
    @IBOutlet weak var resendButton: UIButton!                  // Button used to resend verification code.
    @IBOutlet weak var enterLabel: UILabel!                     // Label that will tell the user to enter the code sent to their number.
    
    let gradientView = CAGradientLayer()                        // Gradient layer for background of the view.
    let gradientBtn = CAGradientLayer()                         // Gradient layer for the verify button.
    
    var rawNum = ""                                             // The phone number that user inputted.
    var fields : [PinTextField] = []                             // Array of text fields to hold the code's text fields.
    let animate = Animate()                                     // Animate class instantiated as a variable.
    
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
        
        // Create horizontal gradient for the resend button.
        // Make the resend button corners curved.
        resendButton.layer.cornerRadius = 16
        // Setup the gradient for the resend button.
        gradientBtn.frame = resendButton.bounds
        gradientBtn.colors = [#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1).cgColor, #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1).cgColor]
        gradientBtn.shouldRasterize = true
        // Start and end points make the gradient horizontal.
        gradientBtn.startPoint = CGPoint(x: 0, y: 0.5)
        gradientBtn.endPoint = CGPoint(x: 1, y: 0.5)
        // Make the gradient corners curved to fit button.
        gradientBtn.cornerRadius = 16
        resendButton.layer.insertSublayer(gradientBtn, at: 0)
        
        // Tap gesture recognizer to hide keyboard.
        tapGesture.addTarget(self, action: #selector(hideKeyboard))
        
        // Set the number in the text to user number.
        enterLabel.text = String("Enter the code sent to " + rawNum)
        
        // Get all text fields in Verify View Controller and store in fields.
        fields = verifyVC.subviews.compactMap{ $0 as? PinTextField }.filter{ $0.textContentType == .oneTimeCode }
        // Make sure the textfields are sorted from left to right.
        fields = fields.sorted(by: { s1, s2 in s1.placeholder ?? "-1" < s2.placeholder ?? "-1" })
        // Recognize when edited text field changed and set cursor to clear.
        fields.forEach{ $0.delegate = self; $0.tintColor = UIColor.clear }
        // Recognize when anything happens to text field to move cursor to end of document.
        fields.forEach{ $0.addTarget(self, action: #selector(cursorMoved(_:)), for: .allTouchEvents) }
        // Set first text field to be in editing state.
        fields[fields.startIndex].becomeFirstResponder()
        
        // Animate the resend button in after 3 seconds.
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
            self.animate.animateButtonIn(self.resendButton, 0.3)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // Function to hide the keyboard that is called after a tap. #selector required function to be exposed to objc.
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    // Function to force cursor to end of document and highlight current textfield.
    @objc func cursorMoved(_ textField : PinTextField) {
        let startPos = textField.beginningOfDocument
        let endPos = textField.endOfDocument
        if textField.selectedTextRange == textField.textRange(from: startPos, to: startPos) {
            textField.selectedTextRange = textField.textRange(from: endPos, to: endPos)
        }
    }
    
    // Functions to highlight current textfield user is on.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.cornerRadius = 5.0
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.masksToBounds = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.cornerRadius = 5.0
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.clear.cgColor
        textField.layer.masksToBounds = true
    }
    
    // Function to handle backspace.
    func didPressBackspace(textField: PinTextField) {
        let startPos = textField.beginningOfDocument
        if let textFieldNumber = Int(textField.placeholder ?? "-1") {
            // Only hack backspace work if user is on the right side of the number unless the text field is empty.
            if textField.selectedTextRange != textField.textRange(from: startPos, to: startPos) || textField.text?.count == 0 {
                // Sets next text field as the responder.
                if textFieldNumber > 1 { fields[textFieldNumber - 2].becomeFirstResponder() }
                // Does the required shifting of numbers in order to have no gaps.
                for i in textFieldNumber...fields.endIndex {
                    if i == fields.endIndex { break }
                    fields[i - 1].text = fields[i].text
                    if fields[i - 1].text == "" {
                        for j in i...fields.endIndex {
                            if j == fields.endIndex { break }
                            if fields[j].text != "" {
                                fields[i - 1].text = fields[j].text
                                fields[j].text = nil
                                break
                            }
                        }
                    }
                }
                // Set the 6th box to nil.
                fields[fields.endIndex - 1].text = nil
            }
        }
    }
    
    // Function to handle when new number inputted to text fields or backspace pressed.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Gets the current text before the new number inputted.
        let currentText = textField.text ?? ""
        guard let range = Range(range, in: currentText) else {
            assertionFailure("range not defined")
            return true
        }
        // Gets the new text that is inputted.
        let newText = currentText.replacingCharacters(in: range, with: string)
        let startPos = textField.beginningOfDocument
        // Handles moving the number to the next text field with the responder.
        if let textFieldNumber = Int(textField.placeholder ?? "-1") {
            // Handle if new text is inputted.
            if newText != "" {
                guard let textFieldContentSize = fields[textFieldNumber - 1].text?.count else { return false }
                // If textfield was empty then check that none others were empty before it and input number to the earliest empty textfield.
                if textFieldContentSize < 1 && newText.count < 2 {
                    for i in fields.startIndex...textFieldNumber - 1 {
                        if fields[i].text == "" {
                            fields[i].text = newText
                            if i < 5 { fields[i + 1].becomeFirstResponder() }
                            break
                        }
                    }
                    // If code is complete then check if valid.
                    let codeInputted = fields.reduce("") {
                        guard let num = $1.text else { return "error" }
                        return $0 + num
                    }
                    if codeInputted.count == fields.count { codeCompleted() }
                }
                // Else if textfield wasn't empty and code not pasted then input number to next text field and shift all others to the right by one.
                else if textFieldContentSize < 2 && newText.count < 3 {
                    // If there are any textfields that are empty then continue.
                    if fields.filter({ $0.text == "" }).count >= 1 {
                        if textFieldNumber < 6 {
                            // Only handle if the cursor is on the right of the number.
                            if textField.selectedTextRange != textField.textRange(from: startPos, to: startPos) {
                                for i in textFieldNumber + 1...fields.endIndex {
                                    if fields[i - 1].text == "" {
                                        for j in (textFieldNumber...i).reversed() {
                                            if j == textFieldNumber { break }
                                            fields[j - 1].text = fields[j - 2].text
                                        }
                                        fields[textFieldNumber].text = String(newText.dropFirst())
                                        fields[textFieldNumber].becomeFirstResponder()
                                        break
                                    }
                                }
                            }
                            // If code is complete then check if valid.
                            let codeInputted = fields.reduce("") {
                                guard let num = $1.text else { return "error" }
                                return $0 + num
                            }
                            if codeInputted.count == fields.count { codeCompleted() }
                        }
                    }
                }
                // Else code was pasted so distribute it to all textfields regardless of other fields being filled.
                else {
                    for (index, text) in newText.enumerated() {
                        fields[index].text = String(text)
                    }
                    if newText.count < 6 { fields[newText.count].becomeFirstResponder() }
                    else { fields[fields.endIndex - 1].becomeFirstResponder() }
                    // If code is complete then check if valid.
                    let codeInputted = fields.reduce("") {
                        guard let num = $1.text else { return "error" }
                        return $0 + num
                    }
                    if codeInputted.count == fields.count { codeCompleted() }
                }
            }
            // Else backspace was pressed.
            else {
                didPressBackspace(textField: fields[textFieldNumber - 1])
            }
        }
        
        return false
    }
    
    // Function triggered when all boxes filled to auto verify the code.
    func codeCompleted() {
        // Disable user interaction for 2.2 seconds.
        fields.forEach{ $0.isUserInteractionEnabled = false }
        // Get the inputted code from the text fields by reducing the fields array.
        let codeInputted = fields.reduce("") {
            guard let num = $1.text else { return "error" }
            return $0 + num
        }
        
        animate.animateViewAlphaOut(view, 0.2)
        
        Api.verifyCode(phoneNumber: rawNum, code: codeInputted) { (response, error) in
            // If code inputted is correct then move to home view controller.
            if let walletData = response  {
                // Save phone number and auth token for future logins.
                Storage.phoneNumberInE164 = self.rawNum
                Storage.authToken = response?["auth_token"] as? String
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let vc = storyboard.instantiateViewController(withIdentifier: "walletViewController") as? WalletViewController  else { assertionFailure("Couldn't find wallet view controller."); return }
                let savedUserName = response?["user"] as? [String:Any]
                let wallet = Wallet.init(data: walletData, ifGenerateAccounts: false)
                // Send the phone number, username, and wallet to wallet view controller.
                vc.rawNum = self.rawNum
                vc.userName = savedUserName?["name"] as? String ?? ""
                vc.wallet = wallet
                // Set the stack so that it only contains home and animate it.
                let walletViewController = [vc]
                self.navigationController?.setViewControllers(walletViewController, animated: true)
            }
            // If code inputed is incorrect then empty all text fields, animate the error message in, then move the cursor to the first text field.
            else if let e = error?.message {
                self.errorLabel.text = e
                
                self.animate.animateViewAlphaIn(self.view, 0.2)
                self.animate.animateButtonOut(self.resendButton, 0.2)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                    self.animate.animateLabelInOut(self.errorLabel, 0.3, 0.3, 0.3, 1.2)
                    self.animate.animateButtonIn(self.resendButton, 0.3, 2.5)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.1){
                    self.fields.forEach{ $0.isUserInteractionEnabled = true }
                    self.fields[self.fields.endIndex - 1].becomeFirstResponder()
                }
            }
        }
    }
    
    // Function triggered when resend button is pressed.
    @IBAction func resendButtonPressed() {
        // Empty all the text fields and disable user interaction for 2.2 seconds.
        fields.forEach{ $0.text = nil}
        
        Api.sendVerificationCode(phoneNumber: rawNum) { (_ response : [String : Any]?, _ error : Api.ApiError?) in
            // If resend was successful, set the cursor to the first text field and animate the resend button out for 3 seconds.
            if response?["status"] != nil {
                self.fields[self.fields.startIndex].becomeFirstResponder()
                self.animate.animateButtonOut(self.resendButton, 0.2)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                    self.animate.animateButtonIn(self.resendButton, 0.3, 3.3)
                }
            }
            // If resend was unsuccessful, animate the error message in, then move the cursor to the first text field.
            else if let e = error?.message {
                self.errorLabel.text = e
                self.fields.forEach{ $0.isUserInteractionEnabled = false }
                
                self.animate.animateButtonOut(self.resendButton, 0.2)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                    self.animate.animateLabelInOut(self.errorLabel, 0.3, 0.3, 0.3, 1.2)
                    self.animate.animateButtonIn(self.resendButton, 0.3, 2.5)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    self.fields.forEach{ $0.isUserInteractionEnabled = true }
                    self.fields[self.fields.startIndex].becomeFirstResponder()
                }
            }
        }
    }
}
