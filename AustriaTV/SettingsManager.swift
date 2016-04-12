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
    
    var favoritePrograms: Set<Program>? {
        get {
            if let data  = defaults.objectForKey(favoriteProgramsKey) as? NSData {
                let unarc = NSKeyedUnarchiver(forReadingWithData: data)
                return unarc.decodeObjectForKey("root") as? Set<Program>
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
    
    func addFavoriteProgram(program: Program) {
        if let _ = self.favoritePrograms {
            self.favoritePrograms!.insert(program)
        } else {
            var favs = Set<Program>()
            favs.insert(program)
            
            self.favoritePrograms = favs
        }
    }
    
    func removeFavoriteProgram(program: Program) {
        if let _ = self.favoritePrograms {
            self.favoritePrograms!.remove(program)
        }
    }
    
    func isFavoriteProgam(program: Program) -> Bool {
        if let result = favoritePrograms?.contains(program) {
            return result
        }
        
        return false
    }
}