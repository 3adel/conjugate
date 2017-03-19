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
    let router: Router?
    
    let languages: [Language]
    let languageType: LanguageType
    let appDependencyManager: AppDependencyManager
    
    var selectedLanguage: Language
    var newlySelectedLanguage: Language
    
    var viewModel = LanguageSelectionViewModel.empty
    
    init(view: LanguageSelectionView, appDependencyManager: AppDependencyManager, languages: [Language], selectedLanguage: Language, languageType: LanguageType) {
        self.view = view
        self.appDependencyManager = appDependencyManager
        self.languages = languages
        self.selectedLanguage = selectedLanguage
        self.languageType = languageType
        self.newlySelectedLanguage = selectedLanguage
        self.router = Router(view: view)
    }
    
    func getLanguages() {
        let title = languageType == .conjugationLanguage ?LocalizedString("mobile.ios.conjugate.languageSelection.conjugation") :  LocalizedString("mobile.ios.conjugate.languageSelection.translation")
        
        let languageViewModels = languages.map(makeLanguageViewModel)
        
        let isApplyButtonEnabled = newlySelectedLanguage != selectedLanguage
        let applyButtonBackgroundColor: (CGFloat, CGFloat, CGFloat) = isApplyButtonEnabled ? (102, 176, 76) : (151, 151, 151)
        
        let applyButtonTitle = LocalizedString("mobile.ios.conjugate.languageSelection.apply")
        
        viewModel = LanguageSelectionViewModel(title: title,
                                               languages: languageViewModels,
                                               applyButtonBackgroundColor: applyButtonBackgroundColor,
                                               applyButtonIsEnabled: isApplyButtonEnabled,
                                               applyButtonTitle: applyButtonTitle)
        
        view.render(with: viewModel)
    }
    
    func didSelectLanguage(at index: Int) {
        let language = languages[index]
        
        newlySelectedLanguage = language

        getLanguages()
    }
    
    func didPressApplyButton() {
        if languageType == .conjugationLanguage {
            appDependencyManager.change(conjugationLanguageTo: newlySelectedLanguage)
        } else {
            appDependencyManager.change(translationLanguageTo: newlySelectedLanguage)
        }
        router?.dismiss()
    }
}

extension LanguageSelectionPresenter {
    func makeLanguageViewModel(from language: Language) -> LanguageViewModel {
        let name = language.name
        let imageName = language.countryCode.lowercased() + "_flag"
        let isSelected = newlySelectedLanguage == language
        
        return LanguageViewModel(title: name,
                                 imageName: imageName,
                                 isSelected: isSelected)
    }
}
