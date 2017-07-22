//
//  DownloadDataOperation.swift
//
//  Copyright © 2016 Voloshyn Slavik. All rights reserved.
//

import  Foundation

final class DownloadDataOperation: Operation {
    private let url:String
    
    private(set) var downloadedData: Data?
    
    init(url: String, callback: @escaping ((_ data: Data?) -> Void)) {
        self.url = url
        super.init()
        self.completionBlock = {
            DispatchQueue.main.async {
                if !self.isCancelled {
                    callback(self.downloadedData)
                }
            }
        }
    }
    
    override func main() {
        guard let url = URL(string: url) else {
            return
        }

        downloadedData = try? Data(contentsOf: url)
    }
    
}

