//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation


class ConjugatePresenter: ConjugatePresenterType {
    let dataStore = DataStore()
    let quickActionController: QuickActionController?
    
    unowned let view: ConjugateView
    
    //A verb string can be pre-configured to automatically search when the view is presented
    var verbToBeSearched: String? {
        didSet {
            guard let verbToBeSearched = verbToBeSearched else { return }
            searchVerbToBeSearched(verbToBeSearched)
        }
    }
    
    var viewModel = ConjugateViewModel.empty
    var verb: Verb? {
        didSet {
            guard let verb = verb,
                !verb.name.isEmpty else { return }
            
            let quickAction = QuickAction(type: .search, title: verb.name)
            quickActionController?.add(quickAction: quickAction)
        }
    }
    var translations = [Translation]()
    
    let targetLocale = Locale(identifier: "de_DE")
    let speaker = TextSpeaker(locale: Locale(identifier: "de_DE"))

    let locale = Locale(identifier: "en_GB")
    
    var searchLocale: Locale
    
    let storage = Storage()
    
    var searchText = ""
    var lastSearchText = ""
    
    var searchTimer: Timer?
    let kMinNumbOfCharactersForSearch = 2
    
    init(view: ConjugateView, quickActionController: QuickActionController? = nil) {
        self.view = view
        self.quickActionController = quickActionController
        self.searchLocale = targetLocale
        
        storage.getSavedVerbs()
        speaker.delegate = self
    }
    
    func search(for verb: String, searchLocale: Locale?) {
        lastSearchText = verb
        
        view.showLoader()
        view.hideErrorMessage()
        
        let searchLocale = searchLocale ?? self.searchLocale
        
        if searchLocale == locale {
            translate(verb, fromInterfaceLanguage: locale, to: targetLocale) { [weak self] translations in
                self?.view.hideLoader()
                
                guard let strongSelf = self else { return }
                
                guard let translations = translations
                    else {
                        strongSelf.view.render(with: strongSelf.makeTranslationsViewModel(translations: []))
                        return
                }
                
                strongSelf.translations = translations
                let translationsViewModel = strongSelf.makeTranslationsViewModel(translations: translations)
                
                strongSelf.view.render(with: translationsViewModel)
                
            }
        } else {
            dataStore.getInfinitive(of: verb, in: targetLocale) { [weak self] result in
                guard let strongSelf = self else { return }
                
                switch result {
                case .success(let verb):
                    strongSelf.conjugate(verb.name)
                case .failure(let error):
                    strongSelf.handle(error: error)
                }
            }
        }
    }
    
    func search(for verb: String) {
        search(for: verb, searchLocale: searchLocale)
    }

    func translationSelected(at index: Int) {
        let translation = translations[index]
        search(for: translation.verb, searchLocale: targetLocale)
    }
    
    func conjugate(_ verb: String) {
        dataStore.conjugate(verb, in: targetLocale) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let verb):
                strongSelf.translate(verb)
            case .failure(let error):
                strongSelf.handle(error: error)
            }
        }
    }
    
    func translate(_ verb: Verb) {
        dataStore.getTranslation(of: verb, in: targetLocale, for: locale) { [weak self] result in
            guard let strongSelf = self else { return }
            
            strongSelf.view.hideLoader()
            
            switch result {
            case .success(let verb):
                strongSelf.didSearch(verb)
            case .failure(let error):
                strongSelf.handle(error: error)
            }
        }
    }
    
    func translate(_ verb: String, fromInterfaceLanguage interfaceLanguage: Locale, to targetLocale: Locale, completion: (([Translation]?) -> ())? = nil) {
        view.showLoader()
        
        dataStore.getTranslation(of: verb, in: interfaceLanguage, for: targetLocale) { [weak self] result in
            guard let strongSelf = self else { return }
            
            strongSelf.view.hideLoader()
            
            switch result {
            case .success(let translations):
                completion?(translations)
            case.failure(let error):
                strongSelf.handle(error: error)
                completion?(nil)
            }
        }
    }
    
    func getInitialData() {
        if let verbString = verbToBeSearched {
            searchVerbToBeSearched(verbString)
        } else {
            viewModel = makeConjugateViewModel()
            view.updateUI(with: viewModel)
        }
    }
    
    fileprivate func searchVerbToBeSearched(_ verbString: String) {
        guard let targetLanguageCode = targetLocale.languageCode?.lowercased() else { return }
        
        searchLanguageChanged(to: targetLanguageCode)
        
        searchText = verbString
        search(for: verbString)

    }
    
    fileprivate func didSearch(_ verb: Verb) {
        viewModel = makeConjugateViewModel(from: verb)
        view.updateUI(with: viewModel)
        
    }
    
    fileprivate func handle(error: Error) {
        view.hideLoader()
        
        guard let appError = error as? ConjugateError
            else {
                view.show(errorMessage: ConjugateError.genericError.localizedDescription)
                return
        }
        
        viewModel = makeConjugateViewModel()
        view.updateUI(with: viewModel)
        view.showVerbNotFoundError(message: appError.localizedDescription)
    }
    
    func playAudioForInfinitveVerb() {
        guard let name = verb?.name else { return }
        speaker.play(name)
    }
    
    func toggleSavingVerb() {
        guard let verb = verb else { return }
        
        if storage.verbExists(verb) {
            storage.remove(verb: verb)
            view.show(successMessage: LocalizedString("mobile.ios.conjugate.verbDeleted"))
        } else {
            storage.save(verb: verb)
            view.show(successMessage: LocalizedString("mobile.ios.conjugate.verbSaved"))
            AppReviewController.sharedInstance.didSignificantEvent()
        }
        
        viewModel = makeConjugateViewModel(from: verb)
        view.updateUI(with: viewModel)
    }
    
    func searchLanguageChanged(to languageCode: String) {
        searchLocale = targetLocale.languageCode?.lowercased() == languageCode.lowercased() ? targetLocale : locale
        
        view.update(searchLanguage: languageCode, searchFieldPlaceholder: makeSearchPlaceHolderText())
    }
    
    func updateViewModel() {
        guard let verb = verb else { return }
        viewModel = makeConjugateViewModel(from: verb)
        view.updateUI(with: viewModel)
    }
    
    func shareVerb(sourceView: View) {
        guard let verb = verb else { return }
        
        let shareController = ShareController(view: view)
        shareController.share(verb: verb, sourceView: sourceView)
    }
}


// MARK: Handle user input for search
extension ConjugatePresenter {
    func userDidInput(searchText: String) {
        cancelSearch()
        clearSearchTimer()
        
        self.searchText = searchText
        if searchText.characters.count >= kMinNumbOfCharactersForSearch {
            searchTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(doSearch), userInfo: nil, repeats: false)
            
        }
    }
    
    func userDidTapSearchButton() {
        clearSearchTimer()
        if searchText.characters.count >= kMinNumbOfCharactersForSearch {
            doSearch()
        }
    }
    
    @objc func doSearch() {
        cancelSearch()
        if searchText.characters.count >= kMinNumbOfCharactersForSearch {
            search(for: searchText)
        }
    }
    
    func cancelSearch() {
        dataStore.cancelPreviousSearches()
        view.hideLoader()
    }
    
    func clearSearchTimer() {
        searchTimer?.invalidate()
        searchTimer = nil
    }
}

// MARK: Actions
extension ConjugatePresenter {
    func tappedForm(inTab tab: Int, atTense tense: Int, at index: Int) {
        view.showActionsForForm(inTab: tab, atTense: tense, at: index)
    }
    
    func copyForm(inTab tab: Int, atTense tense: Int, at index: Int) {
        let selectedTab = viewModel.tenseTabs[tab]
        let tense = selectedTab.tenses[tense]
        let form = tense.forms[index]
        
        let conjugation = form.pronoun + " " + form.verb
        Clipboard().copy(conjugation)
    }
    
    func shareForm(inTab tab: Int, atTense tense: Int, at index: Int, sourceView: View, sourceRect: CGRect) {
        let selectedTab = viewModel.tenseTabs[tab]
        let tense = selectedTab.tenses[tense]
        let form = tense.forms[index]
        
        let conjugation = form.pronoun + " " + form.verb
        let tenseGroupName = selectedTab.name
        let tenseName = !tense.name.isEmpty ? "\(tenseGroupName) \(tense.name)" : tenseGroupName
        let verbName = viewModel.verb
        
        let text = "\(tenseName) form of the verb \(verbName) is \(conjugation).\n\n"
            + "Via konj.me app"
        let url = "https://goo.gl/0iUTJI"
        
        let shareController = ShareController(view: view)
        shareController.share(text: text, url: url, sourceView: sourceView, sourceRect: sourceRect)
    }
}

//MARK: ViewModel Factory
extension ConjugatePresenter {
    func makeTranslationsViewModel(translations: [Translation]) -> TranslationsViewModel {
        let translationViewModels = translations.map (makeTranslationViewModel)
        
        return TranslationsViewModel(translations: translationViewModels)
    }
    
    func makeTranslationViewModel(translation: Translation) -> TranslationViewModel {
        let verb = translation.verb
        let meaning = translation.meaning
        
        return TranslationViewModel(verb: verb, meaning: meaning)
    }
    
    func makeSearchPlaceHolderText() -> String {
        let searchFieldPlaceholderVerbs = searchLocale == targetLocale ? ["trank", "hast"] : ["drink", "have"]
        
        let searchFieldPlaceHolder = LocalizedString("searchPlaceholder", args: searchFieldPlaceholderVerbs[0], searchFieldPlaceholderVerbs[1])
        
        return searchFieldPlaceHolder
    }
    
    func makeConjugateViewModel(from verb: Verb? = nil) -> ConjugateViewModel {
        let verbIsSaved = storage.getSavedVerbs().filter { $0 == verb }.isEmpty
        
        let switchInterfaceLanguage = locale.languageCode!.uppercased()
        
        let flagSuffix = "_flag"
        let switchInterfaceLanguageFlagImage = locale.regionCode!.lowercased()+flagSuffix
        let switchLanguageFlagImage = targetLocale.regionCode!.lowercased()+flagSuffix
        
        let switchSearchLanguage = targetLocale.regionCode!.uppercased()
        
        let searchFieldPlaceHolder = makeSearchPlaceHolderText()
        
        var viewModel = ConjugateViewModel.empty

        if let verb = verb {
        
            self.verb = verb
            let nominalFormsString = verb.nominalForms.joined(separator: ", ")
            
            let tenseTabs = Verb.TenseGroup.allCases.flatMap(makeTenseTabViewModel)
            
            var meaningText = ""
            
            verb.translations?.forEach { translation in
                
                if verb.translations?.index(of: translation)! != 0 {
                    meaningText += ", "
                }
                meaningText += translation
            }
            
            let language = locale.languageCode!.uppercased()
            
            viewModel = ConjugateViewModel(verb: verb.name,
                                           searchText: searchText,
                                           nominalForms: nominalFormsString,
                                           switchInterfaceLanguage: switchInterfaceLanguage,
                                           switchSearchLanguage: switchSearchLanguage,
                                           switchInterfaceLanguageFlagImage: switchInterfaceLanguageFlagImage,
                                           switchLanguageFlagImage: switchLanguageFlagImage,
                                           language: language,
                                           meaning: meaningText,
                                           starSelected: !verbIsSaved,
                                           tenseTabs: tenseTabs,
                                           searchFieldPlaceholder: searchFieldPlaceHolder)
        } else {
            viewModel = ConjugateViewModel(verb: "",
                                           searchText: searchText,
                                           nominalForms: "",
                                           switchInterfaceLanguage: switchInterfaceLanguage,
                                           switchSearchLanguage: switchSearchLanguage,
                                           switchInterfaceLanguageFlagImage: switchInterfaceLanguageFlagImage,
                                           switchLanguageFlagImage: switchLanguageFlagImage,
                                           language: "",
                                           meaning: "",
                                           starSelected: false,
                                           tenseTabs: [],
                                           searchFieldPlaceholder: searchFieldPlaceHolder)

        }
        return viewModel
    }
    
    func makeTenseTabViewModel(from tenseGroup: Verb.TenseGroup) -> TenseTabViewModel? {
        guard let verb = self.verb,
            let tenses = verb.tenses[tenseGroup],
            !tenses.isEmpty
            else { return nil }
        
        var tenseViewModels = [TenseViewModel]()
        
        Tense.Name.allTenses.forEach { tenseName in
            let tensesWithThisName = tenses.filter { $0.name == tenseName }
            tenseViewModels.append(contentsOf: tensesWithThisName.map(makeTenseViewModel))
        }
        return TenseTabViewModel(name: tenseGroup.text.capitalized, tenses: tenseViewModels)
    }
    
    func makeFormViewModel(from form: Form) -> FormViewModel {
        var colorR: Float = 0
        var colorG: Float = 0
        var colorB: Float = 0
        
        switch form.type {
        case .regular:
            colorR = 63/255
            colorG = colorR
            colorB = colorR
        case .irregular:
            colorR = 208/255
            colorG = 2/255
            colorB = 27/255
        case .accepted:
            colorR = 0/255
            colorG = 118/255
            colorB = 255/255
        }
        
        let color = (colorR, colorG, colorB)
        
        let audioPronoun = form.pronoun.components(separatedBy: "/").first ?? ""
        let audioText = audioPronoun + " " + form.conjugatedVerb
        
        return FormViewModel(pronoun: form.pronoun, verb: form.conjugatedVerb, audioText: audioText, textColor: color, audioImageHidden: false)
    }
    
    func makeTenseViewModel(from tense: Tense) -> TenseViewModel {
        let formViewModels = tense.forms.map(makeFormViewModel)
        return TenseViewModel(name: tense.name.text, forms: formViewModels)
    }
}

extension ConjugatePresenter: TextSpeakerDelegate {
    func speakerDidStartPlayback(for text: String) {
        view.animateInfinitveAudioButton()
    }
    
    func speakerDidFinishPlayback(for text: String) {
        view.stopAnimatingInfinitiveAudioButton()
    }
}
