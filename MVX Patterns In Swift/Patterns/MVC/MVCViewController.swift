//
//  MVCViewController.swift
//  MVX Patterns In Swift
//
//  Created by Yaroslav Voloshyn on 15/07/2017.
//

import UIKit

private let cellId = "500px_image_cell"

final class MVCViewController: UIViewController {

    fileprivate let pxManager = PXManager()

    fileprivate var lastPageIndex: Int?
    fileprivate var photos: [(PXPhoto, UIImage?)] = []
    fileprivate var isLoading = false {
        didSet {
            UIApplication.shared.isNetworkActivityIndicatorVisible = isLoading
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadMorePhotos()
        collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: cellId)
    }

}

// MARK: - Data management
extension MVCViewController {

    fileprivate func loadMorePhotos() {
        guard !isLoading else {
            return
        }

        isLoading = true
        var pageIndex = 1
        if let lastPageIndex = lastPageIndex {
            pageIndex = lastPageIndex + 1
        }
        pxManager.getPageWithPhotos(pageIndex) { [weak self] (page, error) in
            defer {
                self?.isLoading = false
            }

            guard let photos = page?.photos else {
                return
            }

            for photo in photos {
                self?.photos.append((photo, nil))
            }
            self?.lastPageIndex = pageIndex
            self?.collectionView.reloadData()
        }
    }

   fileprivate func startLoadImage(for index: IndexPath) {
        let url = photos[index.row].0.url
        ImageLoader.shared.downloadImage(with: url) { [weak self] (image) in
            self?.photos[index.row].1 = image
            self?.collectionView.reloadItems(at: [index])
        }
    }

    fileprivate func stopLoadImage(for index: IndexPath) {
        let url = photos[index.row].0.url
        ImageLoader.shared.stopDownloadImage(with: url)
    }
}

// MARK: - UICollectionViewDataSource
extension MVCViewController: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? ImageCell else {
            return UICollectionViewCell()
        }

        cell.nameLabel.text = photos[indexPath.row].0.name
        if let image = photos[indexPath.row].1 {
            cell.imageView.image = image
        } else {
            cell.imageView.image = nil
            startLoadImage(for: indexPath)
        }

        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension MVCViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let countOfCollumns: CGFloat = 3
        let widthCollectionView = collectionView.frame.width
        let widthCell = (widthCollectionView - (countOfCollumns - 1.0))/countOfCollumns
        return CGSize(width: widthCell, height: widthCell)
    }

    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        stopLoadImage(for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row + 1) == photos.count {
            self.loadMorePhotos()
        }
    }

}
