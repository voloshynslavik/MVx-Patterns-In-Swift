//
//  ModelView.swift
//  MVX Patterns In Swift
//
//  Created by Yaroslav Voloshyn on 17/07/2017.
//

import Foundation

final class ViewModel: NSObject {

    weak var delegate: ViewModelDelegate?

    fileprivate let pxManager = PXManager()
    fileprivate var lastPageIndex: Int?
    fileprivate var photos: [(PXPhoto, Data?)] = []
    fileprivate var isLoading = false {
        didSet {
            self.delegate?.didLoadingStateChanged(in: self, from: oldValue, to: isLoading)
        }
    }

    var photosCount: Int {
        return photos.count
    }

    func getPhotoData(for index: Int) -> Data? {
        guard let data = photos[index].1 else {
            startLoadPhoto(for: index)
            return nil
        }

        return data
    }

    func getPhotoName(for index: Int) -> String {
        return photos[index].0.name
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
        pxManager.getPageWithPhotos(pageIndex) { [weak self] (page, error) in
            defer {
                self?.isLoading = false
            }

            guard let photos = page?.photos,
                  let sself = self else {
                    return
            }

            sself.lastPageIndex = pageIndex
            for photo in photos {
                sself.photos.append((photo, nil))
            }
            sself.delegate?.didUpdatedData(in: sself)
        }
    }
}

// MARK: - Load Photo
extension ViewModel {

    func stopLoadPhoto(for index: Int) {
        let url = photos[index].0.url
        DataLoader.shared.stopDownload(with: url)
    }

    func startLoadPhoto(for index: Int) {
        let url = photos[index].0.url
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
