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
}

struct SavedVerbViewModel {
    let verbs: [SavedVerbCellViewModel]
    
    static let empty = SavedVerbViewModel(verbs: [])
}

struct SavedVerbCellViewModel {
    let verb: String
    let meaning: String
    
    static let empty = SavedVerbCellViewModel(verb: "", meaning: "")
}


class SavedVerbPresenter: SavedVerbPresenterType {
    let storage = Storage()
    let view: SavedVerbView
    
    var viewModel = SavedVerbViewModel.empty
    var verbs = [Verb]()
    
    init(view: SavedVerbView) {
        self.view = view
        storage.loadVerbs()
    }
    
    func getSavedVerbs() {
        verbs = storage.loadVerbs()
        
        viewModel = makeViewModel(from: verbs)
        view.update(with: viewModel)
    }
    
    func makeViewModel(from verbs: [Verb]) -> SavedVerbViewModel {
        var verbViewModels = [SavedVerbCellViewModel]()
        
        verbViewModels = verbs.map(makeCellViewModel)
        
        return SavedVerbViewModel(verbs: verbViewModels)
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
    
}
