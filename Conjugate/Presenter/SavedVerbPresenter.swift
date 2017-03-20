//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation


protocol SavedVerbView: View {
    func update(with viewModel: SavedVerbViewModel)
}

protocol SavedVerbPresenterType {
    func getSavedVerbs()
    func openVerbDetails(at index: Int, ofLanguageAt languageIndex: Int)
    func open(verbDetailView view: ConjugateView)
    func deleteVerb(at index: Int, ofLanguageAt languageIndex: Int)
    func getVerbDetailView(at index: Int, ofLanguageAt languageIndex: Int) -> ConjugateView?
}

struct SavedVerbViewModel {
    let savedVerbLanguages: [SavedVerbLanguageViewModel]
    let showNoSavedVerbMessage: Bool
    let showVerbsList: Bool
    
    static let empty = SavedVerbViewModel(savedVerbLanguages: [], showNoSavedVerbMessage: false, showVerbsList: false)
}

struct SavedVerbLanguageViewModel {
    let name: String
    let flagImageName: String
    let tintColor: (CGFloat, CGFloat, CGFloat)
    let savedVerbs: [SavedVerbCellViewModel]
}

struct SavedVerbCellViewModel {
    let verb: String
    let meaning: String
    
    static let empty = SavedVerbCellViewModel(verb: "", meaning: "")
}


class SavedVerbPresenter: SavedVerbPresenterType {
    let storage = Storage()
    
    unowned let view: SavedVerbView
    
    var viewModel = SavedVerbViewModel.empty
    var languageVerbs: [Language: [Verb]] = [:]
    var languages: [Language] = []
    
    let router: Router?
    
    init(view: SavedVerbView) {
        self.view = view
        self.router = Router(view: view)
    }
    
    func getSavedVerbs() {
        let verbs = storage.getSavedVerbs()
        
        languages.removeAll()
        languageVerbs = verbs.reduce([Language: [Verb]]()) { (languageVerbs, verb) in
            var languageVerbs = languageVerbs
            var verbsOfLanguage: [Verb] = languageVerbs[verb.language] ?? []
            verbsOfLanguage.append(verb)
            
            languageVerbs[verb.language] = verbsOfLanguage
            
            if !languages.contains(verb.language) {
                languages.append(verb.language)
            }
            
            return languageVerbs
        }
        
        viewModel = makeViewModel(from: languageVerbs, languages: languages)
        view.update(with: viewModel)
    }
    
    func makeViewModel(from languageVerbs: [Language: [Verb]], languages: [Language]) -> SavedVerbViewModel {
        let languagesViewModel = makeLanguagesViewModel(from: languageVerbs, languages: languages)
        
        let showNoSavedVerbMessage = languagesViewModel.isEmpty
        
        return SavedVerbViewModel(savedVerbLanguages: languagesViewModel, showNoSavedVerbMessage: showNoSavedVerbMessage, showVerbsList: !showNoSavedVerbMessage)
    }
    
    func makeLanguagesViewModel(from languageVerbs: [Language: [Verb]], languages: [Language]) -> [SavedVerbLanguageViewModel] {
        let languageViewModels: [SavedVerbLanguageViewModel] = languages.flatMap { language in
            guard let verbs = languageVerbs[language] else { return nil }
            
            let verbCellViewModels: [SavedVerbCellViewModel] = verbs.flatMap({ verb in
                guard verb.language == language else { return nil }
                return makeCellViewModel(from: verb)
            })
            
            return SavedVerbLanguageViewModel(name: language.name, flagImageName: language.flagImageName, tintColor: language.tintColor, savedVerbs: verbCellViewModels)
        }
        return languageViewModels
    }
    
    func makeCellViewModel(from verb: Verb) -> SavedVerbCellViewModel {
        var meaningText = ""
        
        verb.translations?.forEach { translation in
            if verb.translations?.index(of: translation)! != 0 {
                meaningText += ", "
            }
            meaningText += translation
        }
        return SavedVerbCellViewModel(verb: verb.name, meaning: meaningText)
    }
    
    func openVerbDetails(at index: Int, ofLanguageAt languageIndex: Int) {
        let language = languages[languageIndex]
        guard let verb = languageVerbs[language]?[index] else { return }
        
        let router = Router(view: view)
        
        router?.openDetail(of: verb)
    }
    
    func deleteVerb(at index: Int, ofLanguageAt languageIndex: Int) {
        let language = languages[languageIndex]
        guard let verb = languageVerbs[language]?[index] else { return }
        
        storage.remove(verb: verb)
        getSavedVerbs()
        
        view.show(successMessage: LocalizedString("mobile.ios.conjugate.verbDeleted"))
    }
    
    func getVerbDetailView(at index: Int, ofLanguageAt languageIndex: Int) -> ConjugateView? {
        let language = languages[languageIndex]
        guard let verb = languageVerbs[language]?[index] else { return nil }
        
        return router?.makeDetailView(from: verb)
    }
    
    func open(verbDetailView view: ConjugateView) {
        router?.show(view: view)
    }
}
