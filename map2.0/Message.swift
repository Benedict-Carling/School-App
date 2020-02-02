//
//  Message.swift
//  map2.0
//
//  Created by Benedict on 30/01/2020.
//  Copyright © 2020 Benedict. All rights reserved.
//

import Foundation

final class Message: Codable {
    var latitudeNorth:Float?
    var latitudeSouth:Float?
    var longitudeEast:Float?
    var longitudeWest:Float?
    
    init(latnorth:Float, latSouth:Float, longEast:Float, longWest:Float) {
        self.latitudeNorth = latnorth
        self.latitudeSouth = latSouth
        self.longitudeEast = longEast
        self.longitudeWest = longWest
    }
}
