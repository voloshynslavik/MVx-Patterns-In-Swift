//
//  Presenter.swift
//  MVX Patterns In Swift
//
//  Created by Yaroslav Voloshyn on 18/07/2017.
//

import Foundation

protocol Presenter {

    func loadMoreItems()
    func startLoadPhoto(for index: Int)
    func stopLoadPhoto(for index: Int)
}

final class ConcretePresenter {

    fileprivate weak var view: PhotosView?
    fileprivate let pxManager = PXManager()

    fileprivate var lastPageIndex: Int?
    fileprivate var photos: [(PXPhoto, Data?)] = []
    fileprivate var isLoading = false {
        didSet {
            if isLoading {
                view?.showNetworkActivityIndicator()
            } else {
                view?.hideNetworkActivityIndicator()
            }
        }
    }

    init(view: PhotosView) {
        self.view = view
    }

    fileprivate func updateView() {
        let data: [(title: String, data: Data?)] = photos.map { (photo) -> (title: String, data: Data?) in
            return (title: photo.0.name, data: photo.1)
        }
        view?.updateView(with: data)
    }
}

extension ConcretePresenter: Presenter {

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

            guard let photos = page?.photos else {
                    return
            }

            self?.lastPageIndex = pageIndex
            photos.forEach { self?.photos.append(($0, nil)) }
            self?.updateView()
        }
    }

}

// MARK: - Load Photo
extension ConcretePresenter {

    func stopLoadPhoto(for index: Int) {
        let url = photos[index].0.url
        DataLoader.shared.stopDownload(with: url)
    }

    func startLoadPhoto(for index: Int) {
        let url = photos[index].0.url
        DataLoader.shared.downloadData(with: url) { [weak self] (data) in
            self?.photos[index].1 = data
            if let photo = self?.photos[index] {
                self?.view?.updateCell(at: index, with: (title: photo.0.name, data: photo.1))
            }
        }
    }

}
