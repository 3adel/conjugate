//
//  ViewPresenterInterface.swift
//  Conjugate
//
//  Created by Halil Gursoy on 30/10/2016.
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation

protocol View {
    func showLoader()
    func hideLoader()
    func show(errorMessage: String)
    func hideErrorMessage()
}

extension View {
    func showLoader() {}
    func hideLoader() {}
    func show(errorMessage: String) {}
    func hideErrorMessage() {}
}

protocol ConjugateView: View {
    func updateUI(with viewModel: ConjugateViewModel)
    func showVerbNotFoundError(
}

protocol ConjugatePresnterType {
    func search(for verb: String)
    func toggleSavingVerb()
    func updateViewModel()
}

struct ConjugateViewModel {
    let verb: String
    let language: String
    let meaning: String
    let starSelected: Bool
    let tenseTabs: [TenseTabViewModel]
    
    var isEmpty: Bool {
        return verb == ""
    }
    
    static let empty: ConjugateViewModel = ConjugateViewModel(verb: "", language: "", meaning: "", starSelected: false, tenseTabs: [])
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
