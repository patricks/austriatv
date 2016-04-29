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
    private let favoriteProgramsKey = "favoritePrograms"
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    // MARK: Favorites
    
    var favoritePrograms: Set<Int>? {
        get {
            if let data  = defaults.objectForKey(favoriteProgramsKey) as? NSData {
                let unarc = NSKeyedUnarchiver(forReadingWithData: data)
                return unarc.decodeObjectForKey("root") as? Set<Int>
            }
            
            return nil
        }
        
        set {
            if let _ = newValue {
                let object = NSKeyedArchiver.archivedDataWithRootObject(newValue!)
                defaults.setObject(object, forKey: favoriteProgramsKey)
            }
        }
    }
    
    func addFavoriteProgram(programId: Int) {
        if let _ = self.favoritePrograms {
            self.favoritePrograms!.insert(programId)
        } else {
            var favs = Set<Int>()
            favs.insert(programId)
            
            self.favoritePrograms = favs
        }
    }
    
    func removeFavoriteProgram(programId: Int) {
        if let _ = self.favoritePrograms {
            self.favoritePrograms!.remove(programId)
        }
    }
    
    func isFavoriteProgam(programId: Int) -> Bool {
        if let result = favoritePrograms?.contains(programId) {
            return result
        }
        
        return false
    }
}