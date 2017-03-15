//
//  AppDependencyManager.swift
//  Conjugate
//
//  Created by Halil Gursoy on 26/02/2017.
//  Copyright © 2017 Adel  Shehadeh. All rights reserved.
//

import Foundation


class AppDependencyManager: NotificationSender {
    enum Notification: String, NotificationName {
        case conjugationLanguageDidChange
        case translationLanguageDidChange
    }
    
    enum NotificationKey: String, DictionaryKey {
        case language
    }
    
    enum UserDefaultKey: String, DictionaryKey {
        case savedLanguageConfig
    }
    
    static var shared: AppDependencyManager = setupSharedManager()
    
    
    private static func setupSharedManager() -> AppDependencyManager {
        let languageConfig = getLanguageConfig() ?? LanguageConfig.default
        
        return AppDependencyManager(
            languageConfig: languageConfig
        )
    }
    
    var languageConfig: LanguageConfig {
        didSet {
            save()
        }
    }
    
    init(languageConfig: LanguageConfig) {
        self.languageConfig = languageConfig
    }
    
    func change(conjugationLanguageTo language: Language) {
        languageConfig = languageConfig.byChangingConjugationLanguage(to: language)
        
        let userInfo: [AnyHashable: Any] = [NotificationKey.language.key: language]
        save()
        send(Notification.conjugationLanguageDidChange, userInfo: userInfo)
    }
    
    func change(translationLanguageTo language: Language) {
        languageConfig = languageConfig.byChangingTranslationLanguage(to: language)
        
        let userInfo: [AnyHashable: Any] = [NotificationKey.language.key: language]
        save()
        send(Notification.translationLanguageDidChange, userInfo: userInfo)
    }
    
    static func getLanguageConfig(from userDefaults: UserDefaults = UserDefaults.standard) -> LanguageConfig? {
        guard let languageConfigDict = userDefaults.dictionary(forKey: UserDefaultKey.savedLanguageConfig.key) else { return nil }
        return LanguageConfig(dictionary: languageConfigDict)
    }
    
    func save(to userDefaults: UserDefaults = UserDefaults.standard) {
        let languageConfigDict = languageConfig.dict()
        userDefaults.set(languageConfigDict, forKey: UserDefaultKey.savedLanguageConfig.key)
    }
}
