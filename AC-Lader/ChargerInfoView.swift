//
//  ChargerInfoView.swift
//  AC-Lader
//
//  Created by Bart van Kuik on 13/01/2018.
//  Copyright © 2018 DutchVirtual. All rights reserved.
//

import UIKit

class ChargerInfoView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var fadeView: UIView!
    
    public var chargerItem: ChargerItem? {
        didSet {
            self.refreshView()
        }
    }
    
    override func layoutSubviews() {
        let gradient = CAGradientLayer()
        gradient.frame = self.fadeView.bounds
        gradient.colors = [UIColor(white: 1, alpha: 0).cgColor, UIColor.white.cgColor]
        self.fadeView.layer.insertSublayer(gradient, at: 0)
    }
    
    // MARK: - Private functions
    
    private func refreshView() {
        self.titleLabel.text = self.chargerItem?.name
        self.descriptionTextView.text = self.chargerItem?.snippet
    }
    
    // MARK: - Life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        dlog("frame=\(frame)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 2.0
        self.layer.cornerRadius = 5.0

    }
}
