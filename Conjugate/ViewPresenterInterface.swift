//
//  ViewPresenterInterface.swift
//  Conjugate
//
//  Created by Halil Gursoy on 30/10/2016.
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation

protocol View: class {
    func showLoader()
    func hideLoader()
    func show(errorMessage: String)
    func hideErrorMessage()
    func show(successMessage: String)
    func dismissView()
}

extension View {
    func showLoader() {}
    func hideLoader() {}
    func show(errorMessage: String) {}
    func hideErrorMessage() {}
    func show(successMessage: String) {}
    func dismissView() {}
}

protocol ConjugateView: View {
    func render(with viewModel: TranslationsViewModel)
    func update(searchLanguage: String, searchFieldPlaceholder: String)
    func updateUI(with viewModel: ConjugateViewModel)
    func showVerbNotFoundError(message: String)
    func animateInfinitveAudioButton()
    func stopAnimatingInfinitiveAudioButton()
    func showActionsForForm(inTab tab: Int, atTense tense: Int, at index: Int)
}

extension ConjugateView {
    func render(with viewModel: TranslationsViewModel) {}
    func update(searchLanguage: String, searchFieldPlaceholder: String) {}
}

protocol ConjugatePresenterType {
    func getInitialData()
    func search(for verb: String)
    func translationSelected(at index: Int)
    func searchLanguageChanged(to languageCode: String)
    func playAudioForInfinitveVerb()
    func toggleSavingVerb()
    func updateViewModel()
    func shareVerb(sourceView: View)
    func tappedForm(inTab tab: Int, atTense tense: Int, at index: Int)
    func copyForm(inTab tab: Int, atTense tense: Int, at index: Int)
    func shareForm(inTab tab: Int, atTense tense: Int,  at index: Int, sourceView: View, sourceRect: CGRect)
    func userDidInput(searchText: String)
    func userDidTapSearchButton()
}

protocol SettingsView: View {
    func render(with viewModel: SettingsViewModel)
}

protocol SettingsPresenterType {
    func getOptions()
    func optionSelected(at section: Int, index: Int, sourceView: View, sourceRect: CGRect)
}

protocol LanguageSelectionView: View {
    func render(with viewModel: LanguageSelectionViewModel)
}

protocol LanguageSelectionPresenterType {
    func getLanguages()
    func didSelectLanguage(at index: Int)
    func didPressApplyButton()
}

protocol OnboardingPresenterType {
    func getInitialData()
}

protocol OnboardingViewType: View {
    func render(with viewModel: OnboardingViewModel)
}

struct ConjugateViewModel {
    let verb: String
    let searchText: String
    let nominalForms: String
    let switchInterfaceLanguage: String
    let switchSearchLanguage: String
    let switchInterfaceLanguageFlagImage: String
    let switchLanguageFlagImage: String
    let language: String
    let meaning: String
    let starSelected: Bool
    let tenseTabs: [TenseTabViewModel]
    let searchFieldPlaceholder: String
    
    var isEmpty: Bool {
        return verb == ""
    }
    
    static let empty: ConjugateViewModel = ConjugateViewModel(verb: "", searchText: "", nominalForms: "", switchInterfaceLanguage: "", switchSearchLanguage: "", switchInterfaceLanguageFlagImage: "", switchLanguageFlagImage: "", language: "", meaning: "", starSelected: false, tenseTabs: [], searchFieldPlaceholder: "")
}

struct TranslationsViewModel {
    let translations: [TranslationViewModel]
}

struct TranslationViewModel {
    let verb: String
    let meaning: String
}

struct TenseTabViewModel {
    let name: String
    let tenses: [TenseViewModel]
    
    static let empty = TenseTabViewModel(name: "", tenses: [])
}

extension TenseTabViewModel: Equatable {}

func ==(lhs: TenseTabViewModel, rhs: TenseTabViewModel) -> Bool {
    return lhs.name == rhs.name
}

struct TenseViewModel {
    let name: String
    let forms: [FormViewModel]
}

struct FormViewModel {
    let pronoun: String
    let verb: String
    let audioText: String
    let textColor: (Float, Float, Float)
    let audioImageHidden: Bool
}

struct SettingsViewModel {
    let sections: [TableSectionViewModel]
    let footerTitle: String
    let footerURL: String
    
    static let empty: SettingsViewModel = SettingsViewModel(sections: [], footerTitle: "", footerURL: "")
}

protocol CellViewModel {}

struct TableSectionViewModel {
    let title: String
    let cells: [CellViewModel]
}

struct SettingsOptionViewModel: CellViewModel {
    let title: String
    let imageName: String
}

struct SettingsLanguageViewModel: CellViewModel {
    let title: String
    let languageName: String
    let languageImageName: String
}

struct LanguageViewModel {
    let title: String
    let imageName: String
    let isSelected: Bool
}

struct LanguageSelectionViewModel {
    let title: String
    let languages: [LanguageViewModel]
    let applyButtonBackgroundColor: (CGFloat, CGFloat, CGFloat)
    let applyButtonIsEnabled: Bool
    let applyButtonTitle: String
    
    static let empty: LanguageSelectionViewModel = LanguageSelectionViewModel(title: "", languages: [], applyButtonBackgroundColor: (0,0,0), applyButtonIsEnabled: false, applyButtonTitle: "")
}

struct OnboardingViewModel {
    let descriptionText: String
    let languageSelectionViewModel: LanguageSelectionViewModel
    
    static let empty: OnboardingViewModel = OnboardingViewModel(descriptionText: "",
                                                                languageSelectionViewModel: .empty)
    
}
