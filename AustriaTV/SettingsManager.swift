//
//  SettingsManager.swift
//  AustriaTV
//
//  Created by Patrick Steiner on 12.04.16.
//  Copyright © 2016 Patrick. All rights reserved.
//

import Foundation

private let _SettingsManagerSharedInstance = SettingsManager()

class SettingsManager {
    
    /**
     Get the singelton object of this class.
     */
    class var sharedInstance: SettingsManager {
        return _SettingsManagerSharedInstance
    }
    
    // Settings Keys
    fileprivate let favoriteProgramsKey = "favoritePrograms"
    
    fileprivate let defaults = UserDefaults.standard
    
    // MARK: Favorites
    
    var favoritePrograms: Set<Program>? {
        get {
            if let data  = defaults.object(forKey: favoriteProgramsKey) as? Data {
                let unarc = NSKeyedUnarchiver(forReadingWith: data)
                return unarc.decodeObject(forKey: "root") as? Set<Program>
            }
            
            return nil
        }
        
        set {
            if let _ = newValue {
                let object = NSKeyedArchiver.archivedData(withRootObject: newValue!)
                defaults.set(object, forKey: favoriteProgramsKey)
            }
        }
    }
    
    func addFavoriteProgram(_ program: Program) {
        if let _ = self.favoritePrograms {
            self.favoritePrograms!.insert(program)
        } else {
            var favs = Set<Program>()
            favs.insert(program)
            
            self.favoritePrograms = favs
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: AppConstants.FavoritesUpdatedKey), object: nil)
    }
    
    func removeFavoriteProgram(_ program: Program) {
        if let _ = self.favoritePrograms {
            self.favoritePrograms!.remove(program)
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: AppConstants.FavoritesUpdatedKey), object: nil)
    }
    
    func isFavoriteProgam(_ program: Program) -> Bool {
        if let result = favoritePrograms?.contains(program) {
            return result
        }
        
        return false
    }
}
