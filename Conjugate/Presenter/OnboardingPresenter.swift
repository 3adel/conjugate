//
//  OnboardingPresenter.swift
//  Conjugate
//
//  Created by Halil Gursoy on 12/03/2017.
//  Copyright © 2017 Adel  Shehadeh. All rights reserved.
//

import Foundation


class OnboardingPresenter: OnboardingPresenterType, LanguageSelectionPresenterType {    
    unowned let view: OnboardingViewType
    
    var selectedLanguage: Language?
    
    let languages: [Language]
    let appDependencyManager: AppDependencyManager
    
    var viewModel: OnboardingViewModel = .empty
    
    init(view: OnboardingViewType, appDependencyManager: AppDependencyManager, languages: [Language]) {
        self.view = view
        self.appDependencyManager = appDependencyManager
        self.languages = languages
        self.selectedLanguage = nil
    }
    
    func getInitialData() {
        let languageViewModels = languages.map(makeLanguageViewModel)
        
        let isApplyButtonEnabled = selectedLanguage != nil
        let applyButtonBackgroundColor: (CGFloat, CGFloat, CGFloat) = isApplyButtonEnabled ? (102, 176, 76) : (151, 151, 151)
        
        let applyButtonTitle = LocalizedString("mobile.ios.conjugate.languageSelection.continue")
        
        let languageSelectionViewModel = LanguageSelectionViewModel(title: "",
                                               languages: languageViewModels,
                                               applyButtonBackgroundColor: applyButtonBackgroundColor,
                                               applyButtonIsEnabled: isApplyButtonEnabled,
                                               applyButtonTitle: applyButtonTitle)
        
        viewModel = OnboardingViewModel(descriptionText: LocalizedString("mobile.ios.conjugate.onboarding.description"),
                                        languageSelectionViewModel: languageSelectionViewModel)
        
        view.render(with: viewModel)
    }
    
    func didPressApplyButton() {
        guard let selectedLanguage = selectedLanguage else { return }
        
        let defaultConfig = LanguageConfig.default
        
        let languageConfig = LanguageConfig(selectedConjugationLanguage: selectedLanguage,
                                            selectedTranslationLanguage: defaultConfig.selectedTranslationLanguage,
                                            availableConjugationLanguages: defaultConfig.availableConjugationLanguages,
                                            availableTranslationLanguages: defaultConfig.availableTranslationLanguages)
        
        appDependencyManager.languageConfig = languageConfig
        
    }
    
    func didSelectLanguage(at index: Int) {
        selectedLanguage = languages[index]
        getInitialData()
    }
    
    func getLanguages() {}
}

extension OnboardingPresenter {
    func makeLanguageViewModel(from language: Language) -> LanguageViewModel {
        let name = language.name
        let imageName = language.countryCode.lowercased() + "_flag"
        let isSelected = selectedLanguage == language
        
        return LanguageViewModel(title: name,
                                 imageName: imageName,
                                 isSelected: isSelected)
    }
}
