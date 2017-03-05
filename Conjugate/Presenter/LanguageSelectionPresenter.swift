//
//  LanguageSelectionPresenter.swift
//  Conjugate
//
//  Created by Halil Gursoy on 26/02/2017.
//  Copyright © 2017 Adel  Shehadeh. All rights reserved.
//

import Foundation

class LanguageSelectionPresenter: LanguageSelectionPresenterType {
    
    unowned let view: LanguageSelectionView
    let languages: [Language]
    let languageType: LanguageType
    let appDependencyManager: AppDependencyManager
    
    var selectedLanguage: Language
    var viewModel = LanguageSelectionViewModel.empty
    
    init(view: LanguageSelectionView, appDependencyManager: AppDependencyManager, languages: [Language], selectedLanguage: Language, languageType: LanguageType) {
        self.view = view
        self.appDependencyManager = appDependencyManager
        self.languages = languages
        self.selectedLanguage = selectedLanguage
        self.languageType = languageType
    }
    
    func getLanguages() {
        let title = languageType == .conjugationLanguage ?LocalizedString("mobile.ios.conjugate.languageSelection.conjugation") :  LocalizedString("mobile.ios.conjugate.languageSelection.translation")
        
        let languageViewModels = languages.map(makeLanguageViewModel)
        viewModel = LanguageSelectionViewModel(title: title, languages: languageViewModels)
        
        view.render(with: viewModel)
    }
    
    func didSelectLanguage(at index: Int) {
        let language = languages[index]
        
        if languageType == .conjugationLanguage {
            appDependencyManager.change(conjugationLanguageTo: language)
            selectedLanguage = appDependencyManager.languageConfig.selectedConjugationLanguage
        } else {
            appDependencyManager.change(translationLanguageTo: language)
            selectedLanguage = appDependencyManager.languageConfig.selectedTranslationLanguage
        }
        getLanguages()
    }
}

extension LanguageSelectionPresenter {
    func makeLanguageViewModel(from language: Language) -> LanguageViewModel {
        let name = language.name
        let imageName = language.languageCode.lowercased() + "_flag"
        let isSelected = selectedLanguage == language
        
        return LanguageViewModel(title: name,
                                 imageName: imageName,
                                 isSelected: isSelected)
    }
}
