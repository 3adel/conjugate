//
//  Config.swift
//  Conjugate
//
//  Created by Halil Gursoy on 26/02/2017.
//  Copyright © 2017 Adel  Shehadeh. All rights reserved.
//

import Foundation

struct LanguageConfig {
    let selectedConjugationLanguage: Language
    let selectedTranslationLanguage: Language
    let availableConjugationLanguages: [Language]
    let availableTranslationLanguages: [Language]
    
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
}

