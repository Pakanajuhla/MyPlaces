//
//  PlaceModel.swift
//  My Place
//
//  Created by Владислав on 26.05.2023.
//

import RealmSwift
import UIKit

class Place: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?
    @objc dynamic var date = Date()
    @objc dynamic var rating = 0.0
    
    convenience init(name: String, location: String?, type: String?, imageData: Data?, rating: Double) {
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
        self.rating = rating
    }
    
   static func seedTestData() {
        let restaurantNames = [
            "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
            "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
            "Speak Easy", "Morris Pub", "Вкусные истории",
            "Классик", "Love&Life", "Шок", "Бочка"
        ]
        restaurantNames.forEach { name in
            let imageData = UIImage(named: name)?.jpegData(compressionQuality: 0.8)
            let place: Place = .init(name: name, location: nil, type: nil, imageData: imageData, rating: 0)
            StorageManager.saveObject(place)
        }
    }
}
