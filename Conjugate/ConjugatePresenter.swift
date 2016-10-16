//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation

protocol View {
    func showLoader()
    func hideLoader()
}

protocol ConjugateView {
    func updateUI(with viewModel: ConjugateViewModel)
}

protocol ConjugatePresnterType {
    func search(for verb: String)
}

struct ConjugateViewModel {
    let verb: String
    let language: String
    let meaning: String
}

class ConjugatePresenter: ConjugatePresnterType {
    let dataStore = DataStore()
    let view: ConjugateView
    
    init(view: ConjugateView) {
        self.view = view
    }
    
    func search(for verb: String) {
        let locale = Locale(identifier: "de_DE")
        dataStore.search(for: verb, in: locale) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let verb):
                let viewModel = strongSelf.conjugateViewModel(from: verb)
                strongSelf.view.updateUI(with: viewModel)
            default:
                break
            }
        }
    }
    
    func conjugateViewModel(from verb: Verb) -> ConjugateViewModel {
        let viewModel = ConjugateViewModel(verb: verb.name, language: "en", meaning: "asda")
        return viewModel
    }
}
