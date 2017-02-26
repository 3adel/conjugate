//
//  SettingsPresenter.swift
//  Conjugate
//
//  Created by Halil Gursoy on 06/11/2016.
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation

class SettingsPresenter: SettingsPresenterType {
    enum CellType: String {
        case sendFeedback
        case share
        case reportBug
        case rate
        
        var title: String {
            return LocalizedString("mobile.ios.conjugate.settings."+rawValue)
        }
        
        var imageName: String {
            return "settings_"+rawValue
        }
    }
    
    struct TableCell {
        var cellType: CellType
        var cellTitle: String
        
        init(cellType: CellType) {
            self.cellType = cellType
            self.cellTitle = cellType.title
        }
    }
    
    var settingsData: [TableCell] = [
            TableCell(cellType: .reportBug),
            TableCell(cellType: .sendFeedback),
            TableCell(cellType: .share),
            TableCell(cellType: .rate)
    ]
    
    var viewModel = SettingsViewModel.empty
    var emailComposer: EmailComposer?
    
    unowned let view: SettingsView
    
    init(view: SettingsView) {
        self.view = view
    }
    
    func getOptions() {
        viewModel = makeViewModel(from: settingsData)
        view.render(with: viewModel)
    }
    
    func optionSelected(at index: Int, sourceView: View, sourceRect: CGRect) {
        let selectedSettings = settingsData[index]
        
        switch selectedSettings.cellType {
        case .reportBug:
            sendSupportEmail(subject: "konj.me iOS bug")
        case .sendFeedback:
            sendSupportEmail(subject: "konj.me iOS feedback")
        case .share:
            let shareController = ShareController(view: view)
            shareController.shareApp(sourceView: sourceView, sourceRect: sourceRect)
        case .rate:
            rateUs()
        }
    }
    
    func makeViewModel(from options: [TableCell]) -> SettingsViewModel {
        let options = settingsData.map(makeSettingsOptionViewModel)
        
        let footerURL = "http://verbix.com"
        let footerTitle = "In collaboration with " + footerURL
        
        return SettingsViewModel(options: options, footerTitle: footerTitle, footerURL: footerURL)
    }
    
    func makeSettingsOptionViewModel(cellData: TableCell) -> SettingsOptionViewModel {
        let title = cellData.cellTitle
        let imageName = cellData.cellType.imageName
        
        return SettingsOptionViewModel(title: title, imageName: imageName)
    }
    
    func sendSupportEmail(subject: String) {
        guard let infoDict = Bundle.main.infoDictionary,
            let versionNumber = infoDict["CFBundleShortVersionString"] as? String,
            let buildNumber = infoDict["CFBundleVersion"] as? String
            else {
                return
        }
        
        emailComposer = EmailComposer(view: view)
        emailComposer?.sendEmail(withSubject: subject, recipient: "feedback@konj.me", version: versionNumber, build: buildNumber)
    }
    
    func rateUs(){
        UIApplication.shared.openURL(NSURL(string : "itms-apps://itunes.apple.com/app/id1163600729")! as URL)

    }
}

