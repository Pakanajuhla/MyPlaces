//
//  PlaceModel.swift
//  My Place
//
//  Created by Владислав on 26.05.2023.
//

import RealmSwift   // библиотека для работы с базой данных Realm
import UIKit        // (фреймворк) предоставляет классы и методы для создания пользовательского интерфейса

class Place: Object {   // Class Object является частью Realm и служит базовым классом для моделей данных Realm
    
    // Аннотация @objc dynamic указывает, что это свойство должно быть доступно для использования с Realm
    
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?
    @objc dynamic var date = Date()
    
    // принимает параметры name, location, type и imageData и инициализирует соответствующие свойства объекта Place.
    
    convenience init(name: String, location: String?, type: String?, imageData: Data?) {
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
    }
}
