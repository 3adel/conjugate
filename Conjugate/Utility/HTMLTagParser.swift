//
//  HTMLTagParser.swift
//  Conjugate
//
//  Created by Halil Gursoy on 28.02.18.
//  Copyright © 2018 Adel  Shehadeh. All rights reserved.
//

import Foundation

enum HTMLTag {
    case bold
    
    var value: String {
        switch self {
        case .bold: return "b"
        }
    }
}

extension String {
    func attributedString(byReplacing htmlTag: HTMLTag, usingAttributes attributes: [NSAttributedStringKey: Any], defaultAttributes: [NSAttributedStringKey: Any] = [:]) -> NSAttributedString {
        let openTag = "<\(htmlTag.value)>"
        let closeTag = "</\(htmlTag.value)>"
        let resultingText = NSMutableAttributedString(string: self, attributes: defaultAttributes)
        while true {
            let plainString = resultingText.string as NSString
            let openTagRange = plainString.range(of: openTag)
            
            guard openTagRange.length != 0 else { break }
            
            let affectedLocation = openTagRange.location + openTagRange.length
            
            let searchRange = NSMakeRange(affectedLocation, plainString.length - affectedLocation)
            
            let closeTagRange = plainString.range(of: closeTag, options: [], range: searchRange)
            
            resultingText.setAttributes(attributes, range: NSMakeRange(affectedLocation, closeTagRange.location - affectedLocation))
            resultingText.deleteCharacters(in: closeTagRange)
            resultingText.deleteCharacters(in: openTagRange)
        }
        return resultingText as NSAttributedString
    }
}
