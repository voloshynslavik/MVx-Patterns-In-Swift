//
//  DataLoader.swift
//
//  Copyright © 2016 Voloshyn Slavik. All rights reserved.
//

import Foundation

final class DataLoader {
    static let shared = DataLoader()
    
    private lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private init() {
    }
    
    func downloadData(with url: String, callback: @escaping ((_ data: Data?) -> Void)) {
        guard !isFileInDownloadQueue(url: url) else {
            return
        }
        
        let operation = DownloadDataOperation(url: url, callback: callback)
        operation.name = url
        downloadQueue.addOperation(operation)
    }
    
    private func isFileInDownloadQueue(url: String) -> Bool{
        for operation in downloadQueue.operations {
            if operation.name == url && !operation.isCancelled && !operation.isFinished {
                return true
            }
        }
        return false
    }
    
    func stopDownload(with url: String) {
        for operation in downloadQueue.operations {
            if operation.name == url {
                operation.cancel()
            }
        }
    }
}
