//
//  ModelView.swift
//  MVX Patterns In Swift
//
//  Created by Yaroslav Voloshyn on 17/07/2017.
//

import Foundation

final class ViewModel: NSObject {

    weak var delegate: ViewModelDelegate?

    fileprivate let picsumPhotos = PicsumPhotosManager()
    fileprivate var lastPageIndex: Int?
    fileprivate var photos: [(PicsumPhoto, Data?)] = []
    fileprivate var isLoading = false {
        didSet {
            self.delegate?.didLoadingStateChanged(in: self, from: oldValue, to: isLoading)
        }
    }

    var photosCount: Int {
        return photos.count
    }

    func getPhotoData(for index: Int, width: Int, height: Int) -> Data? {
        guard let data = photos[index].1 else {
            startLoadPhoto(for: index, width: width, height: height)
            return nil
        }

        return data
    }

    func getPhotoAuthor(for index: Int) -> String {
        return photos[index].0.author
    }
}

// MARK: - Load items
extension ViewModel {

    func loadMoreItems() {
        guard !isLoading else {
            return
        }

        var pageIndex = 1
        if let lastPageIndex = lastPageIndex {
            pageIndex = lastPageIndex + 1
        }

        loadItems(with: pageIndex)
    }

    private func loadItems(with pageIndex: Int) {
        isLoading = true
        picsumPhotos.getPhotos(pageIndex) { [weak self] (photos, error) in
            defer {
                self?.isLoading = false
            }
            
            guard let sself = self else {
                return
            }
            
            sself.lastPageIndex = pageIndex
            photos?.forEach {
                sself.photos.append(($0, nil))
            }
            sself.delegate?.didUpdatedData(in: sself)
        }
    }
}

// MARK: - Load Photo
extension ViewModel {

    func stopLoadPhoto(for index: Int, width: Int, height: Int) {
        let url = photos[index].0.getResizedImageURL(width: width, height: height)
        DataLoader.shared.stopDownload(with: url)
    }

    func startLoadPhoto(for index: Int, width: Int, height: Int) {
        let url = photos[index].0.getResizedImageURL(width: width, height: height)
        DataLoader.shared.downloadData(with: url) { [weak self] (data) in
            guard let sself = self else {
                return
            }

            sself.photos[index].1 = data
            sself.delegate?.didDownloadPhoto(in: sself, with: index)
        }
    }

}

protocol ViewModelDelegate: class {

    func didLoadingStateChanged(in viewModel: ViewModel, from oldState: Bool, to newState:Bool)
    func didUpdatedData(in viewModel: ViewModel)
    func didDownloadPhoto(in viewMode: ViewModel, with index: Int)

}
