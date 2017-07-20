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
    fileprivate var photos: [PXPhoto] = [] {
        didSet {
            delegate?.didUpdatedData(in: self)
        }
    }
    fileprivate var isLoading = false {
        didSet {
            self.delegate?.didLoadingStateChanged(in: self, from: oldValue, to: isLoading)
        }
    }

    var photosCount: Int {
        return photos.count
    }

    func getPhotoUrl(for index: IndexPath) -> String {
        return photos[index.row].url
    }

    func getPhotoName(for index: IndexPath) -> String {
        return photos[index.row].name
    }



}

// MARK: - Loading data
extension ViewModel {

    func loadMorePhotos() {
        guard !isLoading else {
            return
        }

        var pageIndex = 1
        if let lastPageIndex = lastPageIndex {
            pageIndex = lastPageIndex + 1
        }

        loadPhotos(with: pageIndex)
    }

    private func loadPhotos(with pageIndex: Int) {
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
            sself.photos.append(contentsOf: photos)
        }
    }
}

protocol ViewModelDelegate: class {

    func didLoadingStateChanged(in viewModel: ViewModel, from oldState: Bool, to newState:Bool)
    func didUpdatedData(in viewModel: ViewModel)

}
