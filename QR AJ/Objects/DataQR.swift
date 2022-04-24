//
//  DataQR.swift
//  QR AJ
//
//  Created by Ariana Esquivel on 21/04/22.
//

class DataQR: Decodable{
    var email:String = ""
    var password:String = ""
    
    internal init(email: String = "", password: String = "") {
        self.email = email
        self.password = password
    }
}
