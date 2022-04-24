//
//  Service.swift
//  QR AJ
//
//  Created by Ariana Esquivel on 23/04/22.
//

import Foundation
import Alamofire

class Service {
    fileprivate var baseUrl = ""
    var headers : HTTPHeaders!
    
    init() {
        self.baseUrl = "http://192.168.100.9:3333"
        self.headers = [
            .contentType("application/json")]
//        self.headersToken = [
//            .contentType("application/json"),
//            .authorization(bearerToken: App.shared.Token)]
    }
}
