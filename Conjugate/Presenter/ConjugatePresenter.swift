//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation
import Fabric
import Crashlytics

class ConjugatePresenter: ConjugatePresenterType, NotificationObserver {
    let dataStore = DataStore()
    let quickActionController: QuickActionController?
    
    unowned let view: ConjugateView
    
    let observedNotifications: [(NotificationName, Selector)] = [(AppDependencyManager.Notification.conjugationLanguageDidChange, #selector(conjugationLanguageDidChange(_:))),
                                                                 (AppDependencyManager.Notification.translationLanguageDidChange, #selector(translationLanguageDidChange(_:)))]
    
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
    let speaker: TextSpeaker
    var searchLanguageType: LanguageType
    
    let storage = Storage()
    
    var searchText = ""
    var lastSearchText = ""
    
    //TODO: Decouple handling verb detail to another presenter
    let isVerbDetail: Bool
    
    var searchTimer: Timer?
    var minNumbOfCharactersForSearch: Int {
        get {
            let language = searchLanguageType == .conjugationLanguage ? targetLanguage : interfaceLanguage
            return language.minWordCharacterCount
        }
    }
    
    let languageConfig: LanguageConfig
    
    var targetLanguage: Language
    var interfaceLanguage: Language
    
    init(view: ConjugateView, appDependencyManager: AppDependencyManager, targetLanguage: Language? = nil, quickActionController: QuickActionController? = nil) {
        self.view = view
        self.quickActionController = quickActionController
        
        isVerbDetail = targetLanguage != nil
        self.targetLanguage = targetLanguage ?? appDependencyManager.languageConfig.selectedConjugationLanguage
        interfaceLanguage = appDependencyManager.languageConfig.selectedTranslationLanguage
        languageConfig = appDependencyManager.languageConfig
        
        searchLanguageType = .conjugationLanguage
        
        speaker = TextSpeaker(language: self.targetLanguage)
        
        storage.getSavedVerbs()
        speaker.delegate = self
        
        subscribeForNotifications()
    }
    
    @objc func conjugationLanguageDidChange(_ notification: Notification) {
        guard let language = notification.userInfo?[AppDependencyManager.NotificationKey.language.key] as? Language,
            !isVerbDetail else { return }
        
        targetLanguage = language
        speaker.language = language
        reset()
    }
    
    @objc func translationLanguageDidChange(_ notification: Notification) {
        guard let language = notification.userInfo?[AppDependencyManager.NotificationKey.language.key] as? Language,
            !isVerbDetail else { return }
        
        interfaceLanguage = language
        reset()
    }
    
    func reset() {
        verb = nil
        searchText = ""
        getInitialData()
    }
    
    func search(for verb: String, searchLanguageType: LanguageType? = nil) {
        lastSearchText = verb
        
        view.showLoader()
        view.hideErrorMessage()
        
        let searchLanguageType = searchLanguageType ?? self.searchLanguageType
        
        if searchLanguageType == .interfaceLanguage {
            translate(verb, fromInterfaceLanguage: interfaceLanguage, to: targetLanguage) { [weak self] translations in
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
            dataStore.getInfinitive(of: verb, in: targetLanguage) { [weak self] result in
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
        search(for: verb, searchLanguageType: searchLanguageType)
    }

    func translationSelected(at index: Int) {
        let translation = translations[index]
        search(for: translation.verb, searchLanguageType: .conjugationLanguage)
    }
    
    func conjugate(_ verb: String) {
        dataStore.conjugate(verb, in: targetLanguage) { [weak self] result in
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
        dataStore.getTranslation(of: verb, in: targetLanguage, for: interfaceLanguage) { [weak self] result in
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
    
    func translate(_ verb: String, fromInterfaceLanguage interfaceLanguage: Language, to targetLocale: Language, completion: (([Translation]?) -> ())? = nil) {
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
        let launchChecker = AppLaunchChecker()
        if launchChecker.isFirstInstall {
            let welcomeVerb = languageConfig.localizedString(withKey: "mobile.ios.conjugate.verb.welcome", languageType: .conjugationLanguage)
            verbToBeSearched = welcomeVerb
            launchChecker.appDidLaunch()
            
            return
        }
        
        if let verbString = verbToBeSearched {
            searchVerbToBeSearched(verbString)
        } else {
            viewModel = makeConjugateViewModel()
            view.updateUI(with: viewModel)
        }
    }
    
    fileprivate func searchVerbToBeSearched(_ verbString: String) {
        searchLanguageTypeChanged(to: .conjugationLanguage)
        
        searchText = verbString
        search(for: verbString)

    }
    
    fileprivate func didSearch(_ verb: Verb) {
        viewModel = makeConjugateViewModel(from: verb)
        view.updateUI(with: viewModel)
        
        //Track successful conjugations
        Answers.logCustomEvent(withName: "Success-\(targetLanguage.locale.description)-verb-conjugation",customAttributes: ["Query": searchText])
   
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
            
            //Track deleting a verb
            Answers.logCustomEvent(withName: "Unfavorited Verb",customAttributes: ["Verb": verb.name])
            
        } else {
            storage.save(verb: verb)
            view.show(successMessage: LocalizedString("mobile.ios.conjugate.verbSaved"))
            AppReviewController.sharedInstance.didSignificantEvent()
            
            //Track saving a verb
            Answers.logCustomEvent(withName: "Favorited Verb",customAttributes: ["Verb": verb.name])
        }
        
        viewModel = makeConjugateViewModel(from: verb)
        view.updateUI(with: viewModel)
    }
    
    func searchLanguageChanged(to languageCode: String) {
        let type: LanguageType
        
        if targetLanguage == interfaceLanguage {
            type = searchLanguageType == .conjugationLanguage ? .interfaceLanguage : .conjugationLanguage
        } else {
            type =  languageCode.lowercased() == targetLanguage.displayLanguageCode.lowercased() ? .conjugationLanguage : .interfaceLanguage
        }
        searchLanguageTypeChanged(to: type)
    }
    
    func searchLanguageTypeChanged(to type: LanguageType) {
        self.searchLanguageType = type
        
        let languageCode = type == .conjugationLanguage ? targetLanguage.displayLanguageCode : interfaceLanguage.displayLanguageCode
        view.update(searchLanguage: languageCode.uppercased(), searchFieldPlaceholder: makeSearchPlaceHolderText())
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
    
    deinit {
        unsubscribeForNotifications()
    }
}


// MARK: Handle user input for search
extension ConjugatePresenter {
    func userDidInput(searchText: String) {
        view.hideTranslationList()
        cancelSearch()
        clearSearchTimer()
        
        self.searchText = searchText
        if searchText.characters.count >= minNumbOfCharactersForSearch {
            searchTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(doSearch), userInfo: nil, repeats: false)
            
        }
    }
    
    func userDidTapSearchButton() {
        clearSearchTimer()
        if searchText.characters.count >= minNumbOfCharactersForSearch {
            doSearch()
        }
    }
    
    @objc func doSearch() {
        cancelSearch()
        if searchText.characters.count >= minNumbOfCharactersForSearch {
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
        let searchFieldPlaceholderVerbs = LocalizedString("searchPlaceholderVerbs", languageType: searchLanguageType).components(separatedBy: ",")
        
        let searchFieldPlaceHolder = LocalizedString("searchPlaceholder", args: searchFieldPlaceholderVerbs[0], searchFieldPlaceholderVerbs[1])
        
        return searchFieldPlaceHolder
    }
    
    func makeConjugateViewModel(from verb: Verb? = nil) -> ConjugateViewModel {
        let verbIsSaved = storage.getSavedVerbs().filter { $0 == verb }.isEmpty
        
        let switchInterfaceLanguage = interfaceLanguage.displayLanguageCode.uppercased()
        
        let switchInterfaceLanguageFlagImage = interfaceLanguage.flagImageName
        let switchLanguageFlagImage = targetLanguage.flagImageName
        
        let switchSearchLanguage = targetLanguage.displayLanguageCode.uppercased()
        
        let searchFieldPlaceHolder = makeSearchPlaceHolderText()
        
        var viewModel = ConjugateViewModel.empty

        if let verb = verb {
        
            self.verb = verb
            
            let infoText = NSMutableAttributedString(string: "\(verb.auxiliaryVerb) · ")
            
            let regularity = verb.regularity == .regular ? "Regular" : "Irregular"
            let regularityText = NSAttributedString(string: regularity, attributes: [.foregroundColor: color(for: verb.regularity)])
            
            infoText.append(regularityText)
            let nominalFormsString = verb.nominalForms.joined(separator: ", ")
            
            let tenseTabs = TenseGroup.allCases.flatMap(makeTenseTabViewModel)
            
            var meaningText = ""
            
            verb.translations?.forEach { translation in
                
                if verb.translations?.index(of: translation)! != 0 {
                    meaningText += ", "
                }
                meaningText += translation
            }
            
            let language = targetLanguage.displayLanguageCode.uppercased()
            let speakerLanguage = speaker.language
            
            viewModel = ConjugateViewModel(verb: verb.name,
                                           searchText: searchText,
                                           infoText: infoText,
                                           nominalForms: nominalFormsString,
                                           switchInterfaceLanguage: switchInterfaceLanguage,
                                           switchSearchLanguage: switchSearchLanguage,
                                           switchInterfaceLanguageFlagImage: switchInterfaceLanguageFlagImage,
                                           switchLanguageFlagImage: switchLanguageFlagImage,
                                           language: language,
                                           meaning: meaningText,
                                           starSelected: !verbIsSaved,
                                           tenseTabs: tenseTabs,
                                           searchFieldPlaceholder: searchFieldPlaceHolder,
                                           speakerLanguage: speakerLanguage)
        } else {
            viewModel = ConjugateViewModel(verb: "",
                                           searchText: searchText,
                                           infoText: NSAttributedString(string: ""),
                                           nominalForms: "",
                                           switchInterfaceLanguage: switchInterfaceLanguage,
                                           switchSearchLanguage: switchSearchLanguage,
                                           switchInterfaceLanguageFlagImage: switchInterfaceLanguageFlagImage,
                                           switchLanguageFlagImage: switchLanguageFlagImage,
                                           language: "",
                                           meaning: "",
                                           starSelected: false,
                                           tenseTabs: [],
                                           searchFieldPlaceholder: searchFieldPlaceHolder,
                                           speakerLanguage: nil)

        }
        return viewModel
    }
    
    func makeTenseTabViewModel(from tenseGroup: TenseGroup) -> TenseTabViewModel? {
        guard let verb = self.verb,
            let tenses = verb.tenses[tenseGroup],
            !tenses.isEmpty
            else { return nil }
        
        let tenseViewModels = tenses.sorted().map(makeTenseViewModel)
        
        let tenseGroupTitle = tenseGroup.localizedTitle(in: verb.language).capitalized
        
        return TenseTabViewModel(name: tenseGroupTitle, tenses: tenseViewModels)
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
        
        let language = verb?.language ?? .english
        let tenseTitle = tense.localizedTitle(in: language)
        
        return TenseViewModel(name: tenseTitle, forms: formViewModels)
    }
    
    private func color(for regularity: Verb.Regularity) -> UIColor {
        var colorR: CGFloat = 0
        var colorG: CGFloat = 0
        var colorB: CGFloat = 0
        
        switch regularity {
        case .regular:
            colorR = 63/255
            colorG = colorR
            colorB = colorR
        case .irregular:
            colorR = 208/255
            colorG = 2/255
            colorB = 27/255
        }
        
        return UIColor(red: colorR, green: colorG, blue: colorB, alpha: 1)
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
