//
//  PXManager.swift
//
//  Created by Voloshyn Slavik on 9/14/16.
//  Copyright © 2016 Voloshyn Slavik. All rights reserved.
//

import Foundation

final class PXManager: BaseHttpManager {

    private let decoder = JSONDecoder()

    let consumerKey: String

    init(consumerKey: String = "3H6TjBLDdI4CB99FDfZXxoMvAa5XEWyGhnsE3N9S") {
        self.consumerKey = consumerKey
    }
    
    func getPageWithPhotos(_ pageIndex: Int = 1, callback: @escaping ((_ page: PXPage?, _ error: Error?) -> Void)) {
        let url = "https://api.500px.com/v1/photos?only=nature&consumer_key=\(consumerKey)&page=\(pageIndex)"
        _ = self.get(url) { [weak self] (data, _, error) in

            var page: PXPage?
            if let data = data {
                do {
                    page = try self?.decoder.decode(PXPage.self, from: data)
                } catch let error {
                    DispatchQueue.main.async(execute: {
                        callback(page, error)
                    })
                }
            }
            DispatchQueue.main.async(execute: {
                callback(page, error)
            })
        }
    }
    
}
