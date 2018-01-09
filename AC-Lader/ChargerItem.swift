//
//  ChargerItem.swift
//  AC-Lader
//
//  Created by Bart van Kuik on 06/01/2018.
//  Copyright © 2018 DutchVirtual. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {
    func setFontFace(font: UIFont, color: UIColor? = nil) {
        beginEditing()
        self.enumerateAttribute(.font, in: NSRange(location: 0, length: self.length)) { (value, range, stop) in
            if let f = value as? UIFont, let newFontDescriptor = f.fontDescriptor.withFamily(font.familyName).withSymbolicTraits(f.fontDescriptor.symbolicTraits) {
                let newFont = UIFont(descriptor: newFontDescriptor, size: font.pointSize)
                removeAttribute(.font, range: range)
                addAttribute(.font, value: newFont, range: range)
                if let color = color {
                    removeAttribute(.foregroundColor, range: range)
                    addAttribute(.foregroundColor, value: color, range: range)
                }
            }
        }
        endEditing()
    }
}

class ChargerItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String
    var type: ChargerType
    var htmlSnippet: String?
    var snippet: String? {
        return self.sanitizedSnippet()
    }
    var attributedSnippet: NSAttributedString? {
        return self.convertedSnippet()
    }
    
    private func sanitizedSnippet() -> String? {
        guard let htmlSnippet = self.htmlSnippet else {
            return nil
        }
        
        var sanitizedString = htmlSnippet
        sanitizedString = sanitizedString.replacingOccurrences(of: "<br>", with: "\n")
        sanitizedString = sanitizedString.replacingOccurrences(of: "&amp;", with: "&")
        sanitizedString = sanitizedString.replacingOccurrences(of: "<[^>]+>", with: "")
        return sanitizedString
    }
    
    private func convertedSnippet() -> NSAttributedString? {
        guard let htmlData = self.htmlSnippet?.data(using: .unicode, allowLossyConversion: true) else {
            return nil
        }

        let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [
            NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.html,
            NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue
        ]
        let attributedString = try? NSMutableAttributedString(data: htmlData, options: options, documentAttributes: nil)
        attributedString?.setFontFace(font: .systemFont(ofSize: UIFont.systemFontSize), color: UIColor.black)
        return attributedString
    }
    
    init(position: CLLocationCoordinate2D, name: String, type: ChargerType) {
        self.position = position
        self.name = name
        self.type = type
    }
}
