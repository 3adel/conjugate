//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation

protocol View {
    func showLoader()
    func hideLoader()
}

protocol ConjugateView: View {
    func updateUI(with viewModel: ConjugateViewModel)
}

protocol ConjugatePresnterType {
    func search(for verb: String)
}

struct ConjugateViewModel {
    let verb: String
    let language: String
    let meaning: String
    let tenseTabs: [TenseTabViewModel]
    
    static let empty: ConjugateViewModel = ConjugateViewModel(verb: "", language: "", meaning: "", tenseTabs: [])
}

struct TenseTabViewModel {
    let name: String
    let tenses: [TenseViewModel]
    
    static let empty = TenseTabViewModel(name: "", tenses: [])
}

struct TenseViewModel {
    let name: String
    let forms: [FormViewModel]
}

struct FormViewModel {
    let pronoun: String
    let verb: String
    let textColor: (Float, Float, Float)
    let audioImageHidden: Bool
}

class ConjugatePresenter: ConjugatePresnterType {
    let dataStore = DataStore()
    let view: ConjugateView
    
    let searchLocale = Locale(identifier: "de_DE")
    let locale = Locale(identifier: "en_US")
    
    init(view: ConjugateView) {
        self.view = view
    }
    
    func search(for verb: String) {
        view.showLoader()
        dataStore.getInfinitive(of: verb, in: searchLocale) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let verb):
                strongSelf.conjugate(verb.name)
            default:
                break
            }
        }
    }
    
    func conjugate(_ verb: String) {
        dataStore.conjugate(verb, in: searchLocale) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let verb):
                strongSelf.translate(verb)
            default:
                break
            }
        }
    }
    
    func translate(_ verb: Verb) {
        dataStore.getTranslation(of: verb, in: searchLocale, for: locale) { [weak self] result in
            guard let strongSelf = self else { return }
            
            strongSelf.view.hideLoader()
            
            switch result {
            case .success(let verb):
                let viewModel = strongSelf.makeConjugateViewModel(from: verb)
                strongSelf.view.updateUI(with: viewModel)
            default:
                break
            }
        }
    }
    
    func makeConjugateViewModel(from verb: Verb) -> ConjugateViewModel {
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
                        
                        
                        let formViewModel = FormViewModel(pronoun: form.pronoun, verb: form.conjugatedVerb, textColor: color, audioImageHidden: false)
                        formViewModels.append(formViewModel)
                    }
                    let tenseViewModel = TenseViewModel(name: tense.name.rawValue, forms: formViewModels)
                    tenseViewModels.append(tenseViewModel)
                }
            }
            
            let tenseTabViewModel = TenseTabViewModel(name: tenseGroup.rawValue.capitalized, tenses: tenseViewModels)
            tenseTabs.append(tenseTabViewModel)
        }
        
        var meaningText = ""
        
        verb.translations?.forEach { translation in
            if verb.translations?.index(of: translation)! != 0 {
                meaningText += ", "
            }
            meaningText += translation
        }
        
        let viewModel = ConjugateViewModel(verb: verb.name, language: locale.languageCode!.uppercased(), meaning: meaningText, tenseTabs: tenseTabs)
        return viewModel
    }
}
