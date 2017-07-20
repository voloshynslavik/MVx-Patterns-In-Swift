//
//  ImageLoader.swift
//  PipedriveTask
//
//  Created by Voloshyn Slavik on 10/8/16.
//  Copyright © 2016 Voloshyn Slavik. All rights reserved.
//

import UIKit

final class ImageLoader {
    static let shared = ImageLoader()
    
    private lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private init() {
    }
    
    func downloadImage(with url: String, callback: @escaping ((_ image: UIImage?)->Void)) {
        if isFileInDownloadQueue(url: url) {
            return
        }
        let operation = DownloadImageOperation(url: url, callback: callback)
        operation.name = url
        downloadQueue.addOperation(operation)
    }
    
    func isFileInDownloadQueue(url: String) -> Bool{
        for operation in downloadQueue.operations {
            if operation.name == url && !operation.isCancelled && !operation.isFinished {
                return true
            }
        }
        return false
    }
    
    func stopDownloadImage(with url: String) {
        for operation in downloadQueue.operations {
            if operation.name == url {
                operation.cancel()
            }
        }
    }
}
