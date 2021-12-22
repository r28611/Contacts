//
//  Contact.swift
//  Contacts
//
//  Created by Margarita Novokhatskaia on 22/12/2021.
//

import Foundation

protocol ContactProtocol {
    var title: String { get set }
    var phone: String { get set }
}
struct Contact: ContactProtocol {
    var title: String
    var phone: String
}
