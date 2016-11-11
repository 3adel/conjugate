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
    func deleteVerb(at index: Int)
}

struct SavedVerbViewModel {
    let verbs: [SavedVerbCellViewModel]
    let showNoSavedVerbMessage: Bool
    let showVerbsList: Bool
    
    static let empty = SavedVerbViewModel(verbs: [], showNoSavedVerbMessage: false, showVerbsList: false)
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
    var verbs = [Verb]()
    
    init(view: SavedVerbView) {
        self.view = view
    }
    
    func getSavedVerbs() {
        verbs = storage.getSavedVerbs()
        
        viewModel = makeViewModel(from: verbs)
        view.update(with: viewModel)
    }
    
    func makeViewModel(from verbs: [Verb]) -> SavedVerbViewModel {
        var verbViewModels = [SavedVerbCellViewModel]()
        
        verbViewModels = verbs.map(makeCellViewModel)
        
        let showNoSavedVerbMessage = verbViewModels.isEmpty
        
        return SavedVerbViewModel(verbs: verbViewModels, showNoSavedVerbMessage: showNoSavedVerbMessage, showVerbsList: !showNoSavedVerbMessage)
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
    
}
