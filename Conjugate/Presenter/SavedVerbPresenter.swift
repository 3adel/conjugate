//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation


protocol SavedVerbView: View {
    func update(with viewModel: SavedVerbViewModel)
}

protocol SavedVerbPresenterType {
    func getSavedVerbs()
    func openVerbDetails(at index: Int)
    func open(verbDetailView view: ConjugateView)
    func deleteVerb(at index: Int)
    func getVerbDetailView(at index: Int) -> ConjugateView?
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
    var verbs = [Verb]() {
        didSet {
            var languages: [Language] = []
            for verb in verbs {
                if !languages.contains(verb.language) {
                    languages.append(verb.language)
                }
            }
            self.languages = languages
        }
    }
    var languages = [Language]()
    
    let router: Router?
    
    init(view: SavedVerbView) {
        self.view = view
        self.router = Router(view: view)
    }
    
    func getSavedVerbs() {
        verbs = storage.getSavedVerbs()
        
        viewModel = makeViewModel(from: verbs)
        view.update(with: viewModel)
    }
    
    func makeViewModel(from verbs: [Verb]) -> SavedVerbViewModel {
        let languagesViewModel = makeLanguagesViewModel(from: languages, verbs: verbs)
        
        let showNoSavedVerbMessage = languagesViewModel.isEmpty
        
        return SavedVerbViewModel(savedVerbLanguages: languagesViewModel, showNoSavedVerbMessage: showNoSavedVerbMessage, showVerbsList: !showNoSavedVerbMessage)
    }
    
    func makeLanguagesViewModel(from languages: [Language], verbs: [Verb]) -> [SavedVerbLanguageViewModel] {
        let languageViewModels: [SavedVerbLanguageViewModel] = languages.map { language in
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
    
    func openVerbDetails(at index: Int) {
        let verb = verbs[index]
        let router = Router(view: view)
        
        router?.openDetail(of: verb)
    }
    
    func deleteVerb(at index: Int) {
        storage.remove(verb: verbs[index])
        getSavedVerbs()
        
        view.show(successMessage: LocalizedString("mobile.ios.conjugate.verbDeleted"))
    }
    
    func getVerbDetailView(at index: Int) -> ConjugateView? {
        let verb = verbs[index]
        return router?.makeDetailView(from: verb)
    }
    
    func open(verbDetailView view: ConjugateView) {
        router?.show(view: view)
    }
}
