//
//  HomeViewController.swift
//  ConexUp
//
//  Created by Mohammed Haque on 1/23/21.
//

import UIKit

class WalletViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource {
    
    @IBOutlet weak var logoutButton: UIButton!                  // Button to log user out to the login view.
    @IBOutlet weak var userNameField: UITextField!              // Text field for the user name.
    @IBOutlet weak var balanceLabel: UILabel!                   // Label that outputs user's total amount.
    @IBOutlet var tapGesture: UITapGestureRecognizer!           // The tap gesture recognizer for hiding the keyboard.
    @IBOutlet weak var transactionTable: UITableView!           // Table to hold all the transactions.
    
    let gradientView = CAGradientLayer()                        // Gradient layer for background of the view.
    let gradientBtn = CAGradientLayer()                         // Gradient layer for the verify button.
    let gradientTable = CAGradientLayer()                       // Gradient layer for the table view.
    
    var rawNum = ""                                             // The phone number that user inputted.
    var userName = ""                                           // The username that will be saved.
    var wallet = Wallet.init()                                  // Initialize wallet object.
    
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
        
        // Create horizontal gradient for the logout button.
        // Make the logout button corners curved.
        logoutButton.layer.cornerRadius = 16
        // Setup the gradient for the logout button.
        gradientBtn.frame = logoutButton.bounds
        gradientBtn.colors = [#colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1).cgColor, #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1).cgColor]
        gradientBtn.shouldRasterize = true
        // Start and end points make the gradient horizontal.
        gradientBtn.startPoint = CGPoint(x: 0, y: 0.5)
        gradientBtn.endPoint = CGPoint(x: 1, y: 0.5)
        // Make the gradient corners curved to fit button.
        gradientBtn.cornerRadius = 16
        logoutButton.layer.insertSublayer(gradientBtn, at: 0)
        
        // Tap gesture recognizer to hide keyboard.
        tapGesture.addTarget(self, action: #selector(hideKeyboard))
        
        // Recognize when user wants to change their username.
        userNameField.delegate = self
        
        // Setup transaction table data source.
        transactionTable.dataSource = self
        
        // Set placeholder of username textfield to their number and their text to their username or number.
        userNameField.placeholder = rawNum
        if userName != "" { userNameField.text = userName }
        else { userNameField.text = rawNum; Api.setName(name: rawNum) { (response, error) in } }
        
        // Set balance to total amount if saved and make the money portion green.
        let balanceStr = "Your total balance is $\(String(format: "%.2f", wallet.totalAmount))"
        let totalAmountStr = (balanceStr as NSString).range(of: "$\(String(format: "%.2f", wallet.totalAmount))")
        let balanceAttributedStr = NSMutableAttributedString.init(string: balanceStr)
        balanceAttributedStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.green, range: totalAmountStr)
        balanceLabel.attributedText = balanceAttributedStr
    }
    
    // Function to hide the keyboard that is called after a tap. #selector required function to be exposed to objc.
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    // Function to limit the username length to 12 characters.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let range = Range(range, in: currentText) else {
            assertionFailure("range not defined")
            return true
        }
        
        let newText = currentText.replacingCharacters(in: range, with: string)
        
        if newText.count < 13 {
            textField.text = newText
        }
        else {
            textField.text = currentText
        }
        
        return false
    }
    
    // Function to save the new username on the server or set it to their phone number if empty.
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != "" {
            let newUserName = textField.text ?? rawNum
            Api.setName(name: newUserName) { (response, error) in }
        }
        else {
            Api.setName(name: rawNum) { (response, error) in }
            textField.text = rawNum
        }
    }
    
    // Function to go back to the login view controller if logout button is pressed.
    @IBAction func logoutButtonPressed() {
        // Create storyboard variable to push the verify view controller onto the stack.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "loginViewController") as? LoginViewController  else { assertionFailure("Couldn't find login view controller."); return }
        // Set the stack so that it only contains home and animate it.
        let loginViewController = [vc]
        self.navigationController?.setViewControllers(loginViewController, animated: true)
    }
    
    // Function to set the section and rows of the tableview.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        assert(section == 0)
        return wallet.accounts.count
    }
    
    // Function to output the wallet content in each cell.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell") ?? UITableViewCell(style: .value1, reuseIdentifier: "transactionCell")
        
        let account = wallet.accounts[indexPath.row]
        Api.setAccounts(accounts: wallet.accounts) { (response, error) in }
        
        cell.textLabel?.text = "\(account.name)"
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.text = "$\(String(format: "%.2f", account.amount))"
        cell.detailTextLabel?.textColor = UIColor.green
        
        cell.backgroundColor = UIColor.clear
        
        cell.imageView?.image = UIImage(systemName: "dollarsign.circle.fill")
        cell.imageView?.tintColor = UIColor(cgColor: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1).cgColor)
        
        return cell
    }
}
