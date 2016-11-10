//
//  Clipboard.swift
//  Conjugate
//
//  Created by Halil Gursoy on 10/11/2016.
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit


class Clipboard {
    
    func copy(_ text: String) {
        UIPasteboard.general.string = text
    }
}
