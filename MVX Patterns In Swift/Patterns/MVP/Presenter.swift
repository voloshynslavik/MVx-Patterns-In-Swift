//
//  Presenter.swift
//  MVX Patterns In Swift
//
//  Created by Yaroslav Voloshyn on 18/07/2017.
//

protocol Presenter {

    func loadMorePhotos()

}

final class ConcretePresenter {

    fileprivate weak var view: View?
    fileprivate let pxManager = PXManager()

    fileprivate var lastPageIndex: Int?
    fileprivate var photos: [PXPhoto] = [] {
        didSet {
            let data: [(title: String, url: String)] = photos.map { (photo) -> (title: String, url: String) in
                return (title: photo.name, url: photo.url)
            }
            view?.updateView(with: data)
        }
    }
    fileprivate var isLoading = false {
        didSet {
            if isLoading {
                view?.showNetworkActivityIndicator()
            } else {
                view?.hideNetworkActivityIndicator()
            }
        }
    }

    init(view: View) {
        self.view = view
    }
    
}

extension ConcretePresenter: Presenter {

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
