//
//  MVPViewController.swift
//  MVX Patterns In Swift
//
//  Created by Yaroslav Voloshyn on 18/07/2017.
//

import UIKit

protocol View: class {

    func showNetworkActivityIndicator()
    func hideNetworkActivityIndicator()
    func updateView(with data: [(title: String, url: String)])

}

private let cellId = "500px_image_cell"

final class MVPViewController: UIViewController {

    fileprivate var cachedImages: [String: UIImage] = [:]
    fileprivate var data: [(title: String, url: String)] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    @IBOutlet weak var collectionView: UICollectionView!
    var presenter: Presenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        presenter.loadMorePhotos()
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension MVPViewController: UICollectionViewDelegateFlowLayout {

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
        if (indexPath.row + 1) == data.count {
            presenter.loadMorePhotos()
        }
    }

}

// MARK: - UICollectionViewDataSource
extension MVPViewController: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? ImageCell else {
            return UICollectionViewCell()
        }

        cell.nameLabel.text = data[indexPath.row].title
        let url = data[indexPath.row].url
        if let image = cachedImages[url] {
            cell.imageView.image = image
        } else {
            cell.imageView.image = nil
            startLoadImage(for: indexPath)
        }

        return cell
    }

}

// MARK: - Image Loader
extension MVPViewController {

    fileprivate func stopLoadImage(for index: IndexPath) {
        let url = data[index.row].url
        ImageLoader.shared.stopDownloadImage(with: url)
    }

    fileprivate func startLoadImage(for index: IndexPath) {
        let url = data[index.row].url
        ImageLoader.shared.downloadImage(with: url) { [weak self] (image) in
            guard let image = image else {
                return
            }

            self?.cachedImages[url] = image
            self?.collectionView.reloadItems(at: [index])
        }
    }

}


extension MVPViewController: View {

    func updateView(with data: [(title: String, url: String)]) {
        self.data = data
    }

    func showNetworkActivityIndicator() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    func hideNetworkActivityIndicator() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

}
