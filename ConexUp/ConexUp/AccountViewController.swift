//
//  AccountViewController.swift
//  ConexUp
//
//  Created by Mohammed Haque on 2/10/21.
//

import Foundation
import UIKit

class AccountViewController: UIViewController {
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    let gradientView = CAGradientLayer()                        // Gradient layer for background of the view.
    let gradientBtn = CAGradientLayer()                         // Gradient layer for the verify button.
    
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
        
        // Create horizontal gradient for the verify button.
        // Make the verify button corners curved.
        doneButton.layer.cornerRadius = 16
        // Setup the gradient for the verify button.
        gradientBtn.frame = doneButton.bounds
        gradientBtn.colors = [#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1).cgColor, #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1).cgColor]
        gradientBtn.shouldRasterize = true
        // Start and end points make the gradient horizontal.
        gradientBtn.startPoint = CGPoint(x: 0, y: 0.5)
        gradientBtn.endPoint = CGPoint(x: 1, y: 0.5)
        // Make the gradient corners curved to fit button.
        gradientBtn.cornerRadius = 16
        doneButton.layer.insertSublayer(gradientBtn, at: 0)
        
        // Tap gesture recognizer to hide keyboard.
        tapGesture.addTarget(self, action: #selector(hideKeyboard))
        
        // Line to prevent snapshot view warning (doesn't work)
        view.snapshotView(afterScreenUpdates: true)
        
        // Hide navigation bar for this view.
        self.navigationController?.isNavigationBarHidden = true
    }

    // Function to hide the keyboard that is called after a tap. #selector required function to be exposed to objc.
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}
