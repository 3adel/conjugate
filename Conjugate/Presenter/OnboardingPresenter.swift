//
//  OnboardingPresenter.swift
//  Conjugate
//
//  Created by Halil Gursoy on 12/03/2017.
//  Copyright © 2017 Adel  Shehadeh. All rights reserved.
//

import Foundation

protocol OnboardingDelegate: class {
    func didSelectConjugationLanguage()
}


class OnboardingPresenter: OnboardingPresenterType, LanguageSelectionPresenterType {    
    unowned let view: OnboardingViewType
    
    var selectedLanguage: Language?
    
    let languages: [Language]
    let appDependencyManager: AppDependencyManager
    
    var viewModel: OnboardingViewModel = .empty
    
    weak var delegate: OnboardingDelegate?
    
    init(view: OnboardingViewType, appDependencyManager: AppDependencyManager, languages: [Language], delegate: OnboardingDelegate?) {
        self.view = view
        self.appDependencyManager = appDependencyManager
        self.languages = languages
        self.selectedLanguage = nil
        self.delegate = delegate
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
        
        let currentLanguageCode = Locale.current.identifier.components(separatedBy: "_").first ?? ""
        let translationLanguage = Language(languageCode: currentLanguageCode) ?? defaultConfig.selectedTranslationLanguage
        
        let languageConfig = LanguageConfig(selectedConjugationLanguage: selectedLanguage,
                                            selectedTranslationLanguage: translationLanguage,
                                            availableConjugationLanguages: defaultConfig.availableConjugationLanguages,
                                            availableTranslationLanguages: defaultConfig.availableTranslationLanguages)
        
        appDependencyManager.languageConfig = languageConfig
        
        delegate?.didSelectConjugationLanguage()
        
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
