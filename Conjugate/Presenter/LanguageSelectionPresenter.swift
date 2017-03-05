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
    let selectedLanguage: Language
    
    var viewModel = LanguageSelectionViewModel.empty
    
    init(view: LanguageSelectionView, title: String, languages: [Language], selectedLanguage: Language) {
        self.view = view
        self.languages = languages
        self.selectedLanguage = selectedLanguage
        
        let languageViewModels = languages.map(makeLanguageViewModel)
        viewModel = LanguageSelectionViewModel(title: title, languages: languageViewModels)
    }
    
    func getLanguages() {
        view.render(with: viewModel)
    }
    
    func didSelectLanguage(at index: Int) {
        
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
