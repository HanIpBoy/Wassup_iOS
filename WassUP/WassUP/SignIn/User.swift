//
//  User.swift
//  WassUP
//
//  Created by 김진웅 on 2023/05/09.
//

import Foundation
class User {
    var name: String
    var email: String
    var password: String
    var birth: String
    
    init(name: String, email: String, password: String, birth: String) {
        self.name = name
        self.email = email
        self.password = password
        self.birth = birth
    }
}
