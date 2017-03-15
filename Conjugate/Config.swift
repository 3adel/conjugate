//
//  Config.swift
//  Conjugate
//
//  Created by Halil Gursoy on 26/02/2017.
//  Copyright © 2017 Adel  Shehadeh. All rights reserved.
//

import Foundation
import Result

public enum LanguageType {
    case interfaceLanguage
    case conjugationLanguage
}

struct LanguageConfig {
    enum UserDefaultKey: String, DictionaryKey {
        case conjugationLanguage
        case translationLanguage
        case availableConjugationLanguages
        case availableTranslationLanguages
    }
    
    private var conjugationLookup: [String: String] = [:]
    private var translationLookup: [String: String] = [:]
    
    let selectedConjugationLanguage: Language
    let selectedTranslationLanguage: Language
    let availableConjugationLanguages: [Language]
    let availableTranslationLanguages: [Language]
    
    static var `default`: LanguageConfig = LanguageConfig(selectedConjugationLanguage: Language.german,
                                                        selectedTranslationLanguage: Language.english,
                                                        availableConjugationLanguages: [Language.german, Language.spanish],
                                                        availableTranslationLanguages: [Language.english])
    
    
    init(selectedConjugationLanguage: Language,
         selectedTranslationLanguage: Language,
         availableConjugationLanguages: [Language],
         availableTranslationLanguages: [Language]) {
        
        self.selectedConjugationLanguage = selectedConjugationLanguage
        self.selectedTranslationLanguage = selectedTranslationLanguage
        self.availableConjugationLanguages = availableConjugationLanguages
        self.availableTranslationLanguages = availableTranslationLanguages
        
        conjugationLookup = loadLookupTable(for: selectedConjugationLanguage.locale) ?? [:]
        translationLookup = loadLookupTable(for: selectedTranslationLanguage.locale) ?? [:]
    }
    
    init?(dictionary: JSONDictionary) {
        guard let conjugationLanguageIdentifier = dictionary[UserDefaultKey.conjugationLanguage.key] as? String,
            let conjugationLanguage = Language(localeIdentifier: conjugationLanguageIdentifier),
            
            let translationLanguageIdentifier = dictionary[UserDefaultKey.translationLanguage.key] as? String,
            let translationLanguage = Language(localeIdentifier: translationLanguageIdentifier),
            
            let availableConjugationLanguageIdentifiers = dictionary[UserDefaultKey.availableConjugationLanguages.key] as? [String],
            let availableTranslationLanguageIdentifiers = dictionary[UserDefaultKey.availableTranslationLanguages.key] as? [String]
        
            else { return nil}
        
         let availableConjugationLanguages = availableConjugationLanguageIdentifiers.flatMap(Language.makeLanguage)
         let availableTranslationLanguages = availableTranslationLanguageIdentifiers.flatMap(Language.makeLanguage)
        
        self.init(selectedConjugationLanguage: conjugationLanguage,
                  selectedTranslationLanguage: translationLanguage,
                  availableConjugationLanguages: availableConjugationLanguages,
                  availableTranslationLanguages: availableTranslationLanguages)
    }
    
    func dict() -> JSONDictionary {
        return [UserDefaultKey.conjugationLanguage.key: selectedConjugationLanguage.localeIdentifier,
                UserDefaultKey.translationLanguage.key: selectedTranslationLanguage.localeIdentifier,
                UserDefaultKey.availableConjugationLanguages.key: availableConjugationLanguages.map { language in return language.localeIdentifier},
                UserDefaultKey.availableTranslationLanguages.key: availableTranslationLanguages.map { language in return language.localeIdentifier}]
    }
    
    
    func byChangingConjugationLanguage(to language: Language) -> LanguageConfig {
        return LanguageConfig(selectedConjugationLanguage: language,
                              selectedTranslationLanguage: selectedTranslationLanguage,
                              availableConjugationLanguages: availableConjugationLanguages,
                              availableTranslationLanguages: availableTranslationLanguages)
    }
    
    func byChangingTranslationLanguage(to language: Language) -> LanguageConfig {
        return LanguageConfig(selectedConjugationLanguage: selectedConjugationLanguage,
                              selectedTranslationLanguage: language,
                              availableConjugationLanguages: availableConjugationLanguages,
                              availableTranslationLanguages: availableTranslationLanguages)
    }
    
    func localizedString(withKey key: String, languageType: LanguageType) -> String {
        switch languageType {
        case .conjugationLanguage:
            return conjugationLookup[key] ?? key
        case .interfaceLanguage:
            return translationLookup[key] ?? key
        }
    }
    
    private func loadLookupTable(for locale: Locale) -> [String: String]? {
        let result = FileParser.dictWithBundle(Bundle.main,
                                               resource: "Language-"+locale.languageCode!,
                                               withExtension: "strings",
                                               subdirectory: ""
        )
        
        return result.value
    }
}

/**
 FileParser utility should be used to read a file and extract Result<[String: String]> instance from content of the file.
 */
struct FileParser {
    
    enum FileParserError: Error {
        case loadError(message: String)
        case badURL(message: String)
    }
    
    static func dictWithBundle(_ bundle: Bundle, resource: String?, withExtension ext: String?, subdirectory: String?) -> Result<[String: String], FileParserError> {
        let urlResult = URL(bundle, resource: resource, withExtension: ext, subdirectory: subdirectory)
        return urlResult.flatMap(loadFileAtURL)
    }
    
    static func URL(_ bundle: Bundle, resource: String?, withExtension ext: String?, subdirectory: String?) -> Result<Foundation.URL, FileParserError> {
        
        guard let url = bundle.url(forResource: resource, withExtension: ext, subdirectory: subdirectory) else {
            return .failure(FileParserError.badURL(message: "Could't create url"))
        }
        
        return Result(url)
    }
    
    static func loadFileAtURL(_ URL: Foundation.URL) -> Result<[String: String], FileParserError> {
        
        guard let dict = NSDictionary(contentsOf: URL) as? [String: String] else {
            return .failure(FileParserError.loadError(message: "Couldn't load URL \(URL.absoluteString)"))
        }
        
        return Result(dict)
    }
}

