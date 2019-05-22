//
//  Presenter.swift
//  MVX Patterns In Swift
//
//  Created by Yaroslav Voloshyn on 18/07/2017.
//

import Foundation

protocol Presenter {

    func loadMoreItems()
    func startLoadPhoto(for index: Int, width: Int, height: Int)
    func stopLoadPhoto(for index: Int, width: Int, height: Int)
    
}

final class ConcretePresenter {

    fileprivate weak var view: PhotosView?
    fileprivate let picsumPhotos = PicsumPhotosManager()

    fileprivate var lastPageIndex: Int?
    fileprivate var photos: [(PicsumPhoto, Data?)] = []
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
            return (title: photo.0.author, data: photo.1)
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
        picsumPhotos.getPhotos(pageIndex) { [weak self] (photos, error) in
            defer {
                self?.isLoading = false
            }

            photos?.forEach {
                self?.photos.append(($0, nil))
            }

            self?.lastPageIndex = pageIndex
            self?.updateView()
        }
    }

}

// MARK: - Load Photo
extension ConcretePresenter {

    func stopLoadPhoto(for index: Int, width: Int, height: Int) {
        let url = photos[index].0.getResizedImageURL(width: width, height: height)
        DataLoader.shared.stopDownload(with: url)
    }

    func startLoadPhoto(for index: Int, width: Int, height: Int) {
        let url = photos[index].0.getResizedImageURL(width: width, height: height)
        DataLoader.shared.downloadData(with: url) { [weak self] (data) in
            self?.photos[index].1 = data
            if let photo = self?.photos[index] {
                self?.view?.updateCell(at: index, with: (title: photo.0.author, data: photo.1))
            }
        }
    }

}
