//
//  AppConstants.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 26.02.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import Foundation


struct AppConstants {
    
    // API
    static let serviceApiToken = "ef97318c84d4e8"
    
    static let apiURL = "http://tvthek.orf.at/"
    static let baseApiPath = "service_api/token/\(AppConstants.serviceApiToken)"
    
    // Colors
    static let grey = "808080".hexColor!
    static let red = "E12128".hexColor!
    static let blue = "222149".hexColor!
}