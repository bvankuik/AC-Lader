//
//  ChargerDetailsViewController.swift
//  AC-Lader
//
//  Created by Bart van Kuik on 08/01/2018.
//  Copyright © 2018 DutchVirtual. All rights reserved.
//

import UIKit

class ChargerDetailsViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var routeGoogleButton: UIButton!
    @IBOutlet weak var routeAppleButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    var chargerItem: ChargerItem?
    
    // MARK: - Actions
    
    @IBAction func routeGoogleButtonAction(_ sender: UIButton) {
        let urlString = "comgooglemaps://?saddr=&daddr=" + destination()
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func routeAppleButtonAction(_ sender: UIButton) {
        let urlString = "http://maps.apple.com/?saddrCurrent%20Location=&daddr=" + destination()
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - Private functions
    
    private func destination() -> String {
        guard let position = self.chargerItem?.position else {
            return ""
        }
        
        return "\(position.latitude),\(position.longitude)"
    }
    
    // MARK: - View cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.numberOfLines = 0
        self.routeGoogleButton.isHidden = true
        if let url = URL(string: "comgooglemaps:") {
            if UIApplication.shared.canOpenURL(url) {
                self.routeGoogleButton.isHidden = false
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Charger details"
        self.titleLabel.text = self.chargerItem?.name
        if let attributedString = self.chargerItem?.attributedSnippet {
            self.textView.attributedText = attributedString
        } else {
            self.textView.text = self.chargerItem?.snippet
        }
    }
}
