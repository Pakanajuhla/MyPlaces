//
//  StorageManeger.swift
//  My Place
//
//  Created by Владислав on 10.07.2023.
//

import RealmSwift

let realm = try! Realm()

class StorageManeger {
    
    static func saveObject (_ place: Place) {
        
        try! realm.write {
            realm.add(place)
            
        }
    }
}
