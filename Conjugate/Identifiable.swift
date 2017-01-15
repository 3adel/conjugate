//
//  Identifiable.swift
//  Conjugate
//
//  Created by Halil on 15/01/2017.
//  Copyright © 2017 Adel  Shehadeh. All rights reserved.
//

import UIKit

/**
 Types that implement this protocol are able to
 identify themselves by querying their static
 Identifier-Property
 
 The default implementation returns the name
 of the type the instance was created from.
 
 UIView and UIViewController are both extended
 to implement this protocol
 */
public protocol Identifiable {
    
    /**
     The Identifier of the type.
     Defaults to the name of the type
     */
    static var Identifier:String! {get}
}

// Default implementation
extension Identifiable {
    
    /**
     The Identifier of the type.
     Defaults to the name of the type
     */
    public static var Identifier:String! { return "\(self)" }  //TODO: Use String(self) instead for more readability
}


extension UIViewController: Identifiable {
}

extension UIView: Identifiable {
}

public protocol NibCell {
    static var Nib: String { get }
}

extension NibCell {
    public static var Nib: String { return "\(self)" }
}

extension UITableViewCell: NibCell {
}

extension UICollectionViewCell: NibCell {
}
