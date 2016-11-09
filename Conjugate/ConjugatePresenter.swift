//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation


class ConjugatePresenter: ConjugatePresnterType {
    let dataStore = DataStore()
    
    unowned let view: ConjugateView
    
    var viewModel = ConjugateViewModel.empty
    var verb: Verb?
    
    let searchLocale = Locale(identifier: "de_DE")
    let speaker = TextSpeaker(locale: Locale(identifier: "de_DE"))

    let locale = Locale(identifier: "en_US")
    
    let storage = Storage()
    
    var isSearching = false
    
    init(view: ConjugateView) {
        self.view = view
        storage.getSavedVerbs()
        speaker.delegate = self
    }
    
    func search(for verb: String) {
        guard !isSearching else { return }
        
        isSearching = true
        
        view.showLoader()
        view.hideErrorMessage()
        
        dataStore.getInfinitive(of: verb, in: searchLocale) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let verb):
                strongSelf.conjugate(verb.name)
            case .failure(let error):
                strongSelf.handle(error: error)
            }
        }
    }
    
    func conjugate(_ verb: String) {
        dataStore.conjugate(verb, in: searchLocale) { [weak self] result in
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
        dataStore.getTranslation(of: verb, in: searchLocale, for: locale) { [weak self] result in
            guard let strongSelf = self else { return }
            
            strongSelf.view.hideLoader()
            
            switch result {
            case .success(let verb):
                strongSelf.isSearching = false
                strongSelf.viewModel = strongSelf.makeConjugateViewModel(from: verb)
                strongSelf.view.updateUI(with: strongSelf.viewModel)
            case .failure(let error):
                strongSelf.handle(error: error)
            }
        }
    }
    
    fileprivate func handle(error: Error) {
        isSearching = false
        view.hideLoader()
        
        guard let appError = error as? ConjugateError,
            appError == .verbNotFound || appError == .conjugationNotFound
            else {
                view.show(errorMessage: ConjugateError.genericError.localizedDescription)
                return
        }
        
        view.updateUI(with: ConjugateViewModel.empty)
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
        }
        
        viewModel = makeConjugateViewModel(from: verb)
        view.updateUI(with: viewModel)
    }
    
    func updateViewModel() {
        guard let verb = verb else { return }
        viewModel = makeConjugateViewModel(from: verb)
        view.updateUI(with: viewModel)
    }
    
    func shareVerb() {
        guard let verb = verb else { return }
        
        let shareController = ShareController(view: view)
        shareController.share(verb: verb)
    }
    
    func makeConjugateViewModel(from verb: Verb) -> ConjugateViewModel {
        self.verb = verb
        
        var tenseTabs = [TenseTabViewModel]()
        
        Verb.TenseGroup.allCases.forEach { tenseGroup in
            guard let tenses = verb.tenses[tenseGroup],
                !tenses.isEmpty
                else { return }
            
            var tenseViewModels = [TenseViewModel]()
            
            Tense.Name.allTenses.forEach { tenseName in
                let tensesWithThisName = tenses.filter { $0.name == tenseName }
                tensesWithThisName.forEach { tense in
                    var formViewModels = [FormViewModel]()
                    tense.forms.forEach { form in
                        var colorR: Float = 0
                        var colorG: Float = 0
                        var colorB: Float = 0
                        
                        if form.irregular {
                            colorR = 208/255
                            colorG = 2/255
                            colorB = 27/255
                        } else {
                            colorR = 63/255
                            colorG = colorR
                            colorB = colorR
                        }
                        
                        let color = (colorR, colorG, colorB)
                        
                        let audioPronoun = form.pronoun.components(separatedBy: "/").first ?? ""
                        let audioText = audioPronoun + " " + form.conjugatedVerb
                        
                        let formViewModel = FormViewModel(pronoun: form.pronoun, verb: form.conjugatedVerb, audioText: audioText, textColor: color, audioImageHidden: false)
                        formViewModels.append(formViewModel)
                    }
                    let tenseViewModel = TenseViewModel(name: tense.name.text, forms: formViewModels)
                    tenseViewModels.append(tenseViewModel)
                }
            }
            
            let tenseTabViewModel = TenseTabViewModel(name: tenseGroup.text.capitalized, tenses: tenseViewModels)
            tenseTabs.append(tenseTabViewModel)
        }
        
        var meaningText = ""
        
        verb.translations?.forEach { translation in
            if verb.translations?.index(of: translation)! != 0 {
                meaningText += ", "
            }
            meaningText += translation
        }
        
        let verbIsSaved = storage.getSavedVerbs().filter { $0 == verb }.isEmpty
        
        let viewModel = ConjugateViewModel(verb: verb.name, language: locale.languageCode!.uppercased(), meaning: meaningText, starSelected: !verbIsSaved, tenseTabs: tenseTabs)
        return viewModel
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
