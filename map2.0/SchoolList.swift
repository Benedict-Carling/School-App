//
//  SchoolList.swift
//  map2.0
//
//  Created by Benedict on 30/01/2020.
//  Copyright © 2020 Benedict. All rights reserved.
//

import Foundation

struct SchoolDetails:Codable {
    var schoolDetails:[SchoolDetail]
}

struct SchoolDetail:Codable {
    var school_name:String
    var latitude:Float
    var longitude:Float
}
