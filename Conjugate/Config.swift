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
    
    static var `default`: LanguageConfig = LanguageConfig(selectedConjugationLanguage: .german,
                                                        selectedTranslationLanguage: .english,
                                                        availableConjugationLanguages: [
                                                            .dutch,
                                                            .english,
                                                            .french,
                                                            .german,
                                                            .italian,
                                                            .portuguese,
                                                            .spanish,
                                                            .swedish],
                                                        availableTranslationLanguages: [
                                                            .arabic,
                                                            .bengali,
                                                            .dutch,
                                                            .english,
                                                            .french,
                                                            .german,
                                                            .hindi,
                                                            .italian,
                                                            .japanese,
                                                            .korean,
                                                            .malay,
                                                            .mandarin,
                                                            .marathi,
                                                            .persian,
                                                            .portuguese,
                                                            .punjabi,
                                                            .russian,
                                                            .spanish,
                                                            .swahili,
                                                            .swedish,
                                                            .tamil,
                                                            .telugu,
                                                            .turkish,
                                                            .urdu,
                                                            .vietnamese])
    
    
    init(selectedConjugationLanguage: Language,
         selectedTranslationLanguage: Language,
         availableConjugationLanguages: [Language],
         availableTranslationLanguages: [Language]) {
        
        self.selectedConjugationLanguage = selectedConjugationLanguage
        self.selectedTranslationLanguage = selectedTranslationLanguage
        self.availableConjugationLanguages = availableConjugationLanguages
        self.availableTranslationLanguages = availableTranslationLanguages
        
        conjugationLookup = loadLookupTable(for: selectedConjugationLanguage) ?? [:]
        translationLookup = loadLookupTable(for: selectedTranslationLanguage) ?? [:]
    }
    
    init?(dictionary: JSONDictionary) {
        guard let conjugationLanguageIdentifier = dictionary[UserDefaultKey.conjugationLanguage.key] as? String,
            let conjugationLanguage = Language(localeIdentifier: conjugationLanguageIdentifier),
            
            let translationLanguageIdentifier = dictionary[UserDefaultKey.translationLanguage.key] as? String,
            let translationLanguage = Language(localeIdentifier: translationLanguageIdentifier)
        
            else { return nil}
        
         let availableConjugationLanguages = LanguageConfig.default.availableConjugationLanguages
         let availableTranslationLanguages = LanguageConfig.default.availableTranslationLanguages
        
        self.init(selectedConjugationLanguage: conjugationLanguage,
                  selectedTranslationLanguage: translationLanguage,
                  availableConjugationLanguages: availableConjugationLanguages,
                  availableTranslationLanguages: availableTranslationLanguages)
    }
    
    func dict() -> JSONDictionary {
        return [UserDefaultKey.conjugationLanguage.key: selectedConjugationLanguage.localeIdentifier,
                UserDefaultKey.translationLanguage.key: selectedTranslationLanguage.localeIdentifier
        ]
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
    
    func localizedString(withKey key: String, in language: Language) -> String {
        guard let lookupTable = loadLookupTable(for: language) else { return key }
        return lookupTable[key] ?? key
    }
    
    private func loadLookupTable(for language: Language) -> [String: String]? {
        let result = FileParser.dictWithBundle(Bundle.main,
                                               resource: "Language-"+language.languageCode,
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

