//
//  PXImage.swift
//
//  Created by Voloshyn Slavik on 9/14/16.
//  Copyright © 2016 Voloshyn Slavik. All rights reserved.
//

struct PXPhoto: Codable {
    let id: Int
    let name: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case url = "image_url"
    }
    
}
