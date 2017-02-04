//
//  QuickAction.swift
//  Conjugate
//
//  Created by Halil Gursoy on 26/01/2017.
//  Copyright © 2017 Adel  Shehadeh. All rights reserved.
//

import UIKit

enum QuickActionType: String {
    case search
    
    fileprivate var shortcutIconType: UIApplicationShortcutIconType {
        return .search
    }
    
    fileprivate var shortcutItemType: String {
        return "\(self)"
    }
}

struct QuickAction {
    static let kLocaleKey = "locale"
    
    let type: QuickActionType
    let title: String
    let userInfo: [String: Any]?
    
    init(type: QuickActionType, title: String, userInfo: [String: Any]? = nil) {
        self.type = type
        self.title = title
        self.userInfo = userInfo
    }
}

extension QuickAction: Equatable {}

func == (lhs: QuickAction, rhs: QuickAction) -> Bool {
    return lhs.title == rhs.title
}

class QuickActionController {
    var quickActions: [QuickAction]
    
    init(quickActions: [QuickAction] = []) {
        self.quickActions = quickActions
    }
    
    func add(quickAction: QuickAction) {
        if quickActions.count == 4 {
            quickActions.removeFirst()
        }
        
        let isActionAlreadyAdded = quickActions.contains(quickAction)
        
        guard !isActionAlreadyAdded else { return }
        
        quickActions.append(quickAction)
        register()
    }
    
    func register() {
        UIApplication.shared.shortcutItems = quickActions.map(makeShortcutItem)
    }
    
    func update(from shortcutItems: [UIApplicationShortcutItem]) {
        quickActions = shortcutItems.flatMap(makeQuickAction)
    }
    
    func makeQuickAction(from shortcutItem: UIApplicationShortcutItem) -> QuickAction? {
        guard let type = QuickActionType(rawValue: shortcutItem.type) else { return nil }
        
        let title = shortcutItem.localizedTitle
        let userInfo = shortcutItem.userInfo
        
        return QuickAction(type: type, title: title, userInfo: userInfo)
    }
    
    func makeShortcutItem(from quickAction: QuickAction) -> UIApplicationShortcutItem {
        let icon = UIApplicationShortcutIcon(type: quickAction.type.shortcutIconType)
        let shortcutItem = UIApplicationShortcutItem(type: quickAction.type.shortcutItemType, localizedTitle: quickAction.title, localizedSubtitle: nil, icon: icon, userInfo: quickAction.userInfo)
        
        return shortcutItem
    }
}
