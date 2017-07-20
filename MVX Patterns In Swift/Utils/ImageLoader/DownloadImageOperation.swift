//
//  DownloadImageOperation.swift
//  PipedriveTask
//
//  Created by Voloshyn Slavik on 10/8/16.
//  Copyright © 2016 Voloshyn Slavik. All rights reserved.
//

import UIKit

final class DownloadImageOperation: Operation {
    private let url:String
    
    private(set) var downloadedImage: UIImage?
    
    init(url: String, callback: @escaping ((_ image: UIImage?)->Void)) {
        self.url = url
        super.init()
        self.completionBlock = {
            DispatchQueue.main.async {
                if !self.isCancelled {
                    callback(self.downloadedImage)
                }
            }
        }
    }
    
    override func main() {
        if  let url = URL(string: url),
            let data = try? Data(contentsOf: url),
            let image  = UIImage(data: data){
            self.downloadedImage = image
        }
    }
    
}

