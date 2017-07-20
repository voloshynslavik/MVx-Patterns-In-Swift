//
//  PXPage.swift
//
//  Created by Voloshyn Slavik on 9/14/16.
//  Copyright © 2016 Voloshyn Slavik. All rights reserved.
//

struct PXPage: Codable {
    let index: Int
    let totalPages: Int
    let totalItems: Int
    let feature: String
    let photos: [PXPhoto]

    enum CodingKeys: String, CodingKey {
        case index = "current_page"
        case totalPages = "total_pages"
        case feature
        case totalItems = "total_items"
        case photos
    }
    
}
