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
    case
    german,
    english,
    spanish,
    french,
    mandarin,
    hindi,
    portuguese,
    arabic,
    bengali,
    russian,
    punjabi,
    japanese,
    telugu,
    malay,
    korean,
    tamil,
    marathi,
    turkish,
    vietnamese,
    urdu,
    italian,
    persian,
    swahili
    
    static var localeIdentifiers: [Language: String] {
        get {
            return [
                .german: "de_DE",
                .english: "en_GB",
                .spanish: "es_ES",
                .french: "fr_FR",
                .mandarin: "zh_Hans_CN",
                .hindi: "hi_IN",
                .portuguese: "pt_PT",
                .arabic: "ar_SA",
                .bengali: "bn_BD",
                .russian: "ru_RU",
                .punjabi: "pa_Arab_PK",
                .japanese: "ja_JP",
                .telugu: "te_IN",
                .malay: "ms_MY",
                .korean: "ko_KR",
                .tamil: "ta_LK",
                .marathi: "mr_IN",
                .turkish: "tr_TR",
                .vietnamese: "vi_VN",
                .urdu: "ur_PK",
                .italian: "it_IT",
                .persian: "fa_IR",
                .swahili: "sw_TZ"
            ]
        }
    }
    
    init?(localeIdentifier: String) {
        guard let locale = Language.localeIdentifiers.filter ({ $0.value == localeIdentifier }).first
        else { return nil }
        
        self = locale.key
    }
    
    init?(languageCode: String) {
        guard let locale = Language.localeIdentifiers.filter({ keyValue in
            let didFindLanguage = (keyValue.value.components(separatedBy: "_").first ?? "") == languageCode
            return didFindLanguage
        }).first
        else { return nil }
        
        self = locale.key
    }
    
    static func makeLanguage(withLocaleIdentifier localeIdentifier: String) -> Language? {
        return Language(localeIdentifier: localeIdentifier)
    }
    
    var name: String {
        get {
            return rawValue.capitalized
        }
    }
    
    var localeIdentifier: String {
        get {
            return Language.localeIdentifiers[self]!
        }
    }
    
    var languageCode: String {
        get {
            switch self {
            case .mandarin:
                return "cmn"
            case .punjabi:
                return "pa"
            default:
                return self.locale.languageCode!
            }
        }
    }
    
    //Special case for Mandarin
    var displayLanguageCode: String {
        get {
            switch self {
            case .mandarin:
                return "zh"
            default:
                return self.languageCode
            }
        }
    }
    
    //Special case for Mandarin
    var minWordCharacterCount: Int {
        get {
            switch self {
            case .mandarin:
                return 1
            default:
                return 2
            }
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
            case .french:
                return "fra"
            case .italian:
                return "ita"
            default:
                return ""
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
    
    var flagImageName: String {
        get {
            return countryCode.lowercased() + "_flag"
        }
    }
    
    var tenseGroups: [TenseGroup] {
        switch self {
        case .german:
            return [
                .indicative,
                .imperative,
                .subjunctive
            ]
        default:
            return [
                .indicative,
                .imperative,
                .conditional,
                .subjunctive
            ]
        }
    }
    
    var tintColor: (CGFloat, CGFloat, CGFloat) {
        switch self {
        case .german:
            return (245, 166, 35)
        case .english:
            return (0, 36, 125)
        case .spanish:
            return (204, 30, 26)
        default:
            return (0, 35, 149)
        }
    }
}
