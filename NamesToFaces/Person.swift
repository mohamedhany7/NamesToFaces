//
//  Person.swift
//  NamesToFaces
//
//  Created by Mohamed Hany on 05/05/2022.
//

import UIKit

class Person: NSObject, Codable{
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
