//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation

// MARK: - Localize

public func LocalizedString(_ key: String, languageType: LanguageType? = nil, args: String...) -> String {
    let prefix = "mobile.ios.conjugate"
    
    var finalKey = key
    if !key.contains(prefix) {
        finalKey = prefix+"."+key
    }
    
    let str: String
    
    if let languageType = languageType {
        str = AppDependencyManager.shared.languageConfig.localizedString(withKey: finalKey, languageType: languageType)
    } else {
        str = NSLocalizedString(finalKey, comment: "")
    }
    return replacePlaceholders(str, args: args)
}

public func LocalizedUppercaseString(_ string:String, args: String...) -> String {
    let str = LocalizedString(string).uppercased(with: Locale.current)
    return replacePlaceholders(str, args: args)
}

public func replacePlaceholders(_ placeholderString: String, args: [String]) -> String {
    var str = placeholderString
    var finalStr = str
    let openingToken:Character = "<"
    let closingToken:Character = ">"
    for arg in args {
        guard let openingIndex = str.characters.index(of: openingToken) as String.Index?,
            let closingIndex = str.characters.index(of: closingToken) as String.Index? else { return placeholderString }
        
        let range = openingIndex ..< str.index(after: closingIndex)
        let replacedString = str.substring(with: range)
        finalStr = finalStr.replacingOccurrences(of: replacedString, with: arg, options: [], range: nil)
        str = str.replacingCharacters(in: range, with: "")
    }
    return finalStr
}

enum Language: String {
    case german, english, spanish
    
    
    var name: String {
        get {
            return rawValue.capitalized
        }
    }
    
    var localeIdentifier: String {
        get {
            switch self {
            case .german:
                return "de_DE"
            case .english:
                return "en_GB"
            case .spanish:
                return "es_ES"
            }
        }
    }
    
    var languageCode: String {
        get {
            return self.locale.languageCode!
        }
    }
    
    var isoCode: String {
        get {
            switch(self) {
            case .english:
                return "eng"
            case .german:
                return "deu"
            case .spanish:
                return "spa"
            }
        }
    }
    
    var countryCode: String {
        get {
            return self.locale.regionCode!
        }
    }
    
    var locale: Locale {
        get {
            return Locale(identifier: localeIdentifier)
        }
    }
}
