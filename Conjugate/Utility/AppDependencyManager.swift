//
//  AppDependencyManager.swift
//  Conjugate
//
//  Created by Halil Gursoy on 26/02/2017.
//  Copyright © 2017 Adel  Shehadeh. All rights reserved.
//

import Foundation


class AppDependencyManager {
    enum Notification: String, NotificationName {
        case conjugationLanguageDidChange
        case translationLanguageDidChange
    }
    
    enum NotificationKey: String, DictionaryKey {
        case language
    }
    
    static let shared: AppDependencyManager = AppDependencyManager(
        languageConfig: LanguageConfig(selectedConjugationLanguage: Language.german,
                                       selectedTranslationLanguage: Language.english,
                                       availableConjugationLanguages: [Language.german, Language.spanish],
                                       availableTranslationLanguages: [Language.english])
    )
    
    var languageConfig: LanguageConfig
    
    init(languageConfig: LanguageConfig) {
        self.languageConfig = languageConfig
    }
}
