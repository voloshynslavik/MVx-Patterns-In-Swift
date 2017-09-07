//
//  MVVMCViewModel.swift
//  MVX Patterns In Swift
//
//  Created by Yaroslav Voloshyn on 07/09/2017.
//

import Foundation

protocol MVVMCViewModelCoordinatorDelegate: class {
    func didSelectItem(withName name: String, andUrl url: String)
}

protocol MVVMCViewModelDelegate: class {

    func didLoadingStateChanged(in viewModel: MVVMCViewModel, from oldState: Bool, to newState:Bool)
    func didUpdatedData(in viewModel: MVVMCViewModel)
    func didDownloadPhoto(in viewMode: MVVMCViewModel, with index: Int)

}

final class MVVMCViewModel: NSObject {

    weak var delegate: MVVMCViewModelDelegate?
    weak var coordinatorDelegate: MVVMCViewModelCoordinatorDelegate?

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

    func usePhotoAtIndex(_ index: Int) {
        if index < photosCount {
            let item = photos[index].0
            coordinatorDelegate?.didSelectItem(withName: item.name, andUrl: item.url)
        }
    }
}

// MARK: - Load items
extension MVVMCViewModel {

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
extension MVVMCViewModel {

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
