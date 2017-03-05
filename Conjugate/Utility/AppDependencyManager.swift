//
//  AppDependencyManager.swift
//  Conjugate
//
//  Created by Halil Gursoy on 26/02/2017.
//  Copyright © 2017 Adel  Shehadeh. All rights reserved.
//

import Foundation


class AppDependencyManager {
    var languageConfig: LanguageConfig
    
    init(languageConfig: LanguageConfig) {
        self.languageConfig = languageConfig
    }
    
    static func configuringDefault() -> AppDependencyManager {
        let languageConfig = LanguageConfig(selectedConjugationLanguage: Language.german,
                                            selectedTranslationLanguage: Language.english,
                                            availableConjugationLanguages: [Language.german, Language.spanish],
                                            availableTranslationLanguages: [Language.english])
        
        return AppDependencyManager(languageConfig: languageConfig)
    }
}
