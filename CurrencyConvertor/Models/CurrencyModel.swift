//
//  CurrencyModel.swift
//  CurrencyConvertor
//
//  Created by Syed Uzair Ahmed on 15/11/2017.
//  Copyright © 2017 Syed Uzair Ahmed. All rights reserved.
//


import Foundation
import ObjectMapper

class CurrencyModel: Mappable {
    
    var base: String?
    var date:String?
    var rates = Dictionary<String,Double>()

    
    required init?(map: Map){ }
    
    
    func mapping(map: Map) {
        base <- map["base"]
        date <- map["date"]
        rates <- map["rates"]

    }
}
