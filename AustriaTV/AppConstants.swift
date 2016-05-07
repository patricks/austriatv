//
//  AppConstants.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 26.02.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import UIKit

struct AppConstants {
    
    // API
    static let ServiceApiToken = "ef97318c84d4e8"
    
    static let ApiURL = "http://tvthek.orf.at/"
    static let BaseApiPath = "service_api/token/\(AppConstants.ServiceApiToken)"
    
    // Colors
    static let Grey = "808080".hexColor!
    static let Red = "E12128".hexColor!
    static let Blue = "222149".hexColor!
    static let LightBlue = "3E8FF4".hexColor!
    
    // Indicator
    static let  ActivityIndicatorColor = UIColor.whiteColor()
}