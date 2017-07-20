//
//  MVVMViewController.swift
//  MVX Patterns In Swift
//
//  Created by Yaroslav Voloshyn on 17/07/2017.
//

import UIKit

private let cellId = "500px_image_cell"

final class MVVMViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    fileprivate var cachedImages: [String: UIImage] = [:]
    var viewModel: ViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        viewModel.loadMorePhotos()
    }

}

// MARK: - UICollectionViewDataSource
extension MVVMViewController: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.photosCount    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? ImageCell else {
            return UICollectionViewCell()
        }

        cell.nameLabel.text = viewModel.getPhotoName(for: indexPath)
        let url = viewModel.getPhotoUrl(for: indexPath)
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
extension MVVMViewController {

    fileprivate func stopLoadImage(for index: IndexPath) {
        let url = viewModel.getPhotoUrl(for: index)
        ImageLoader.shared.stopDownloadImage(with: url)
    }

    fileprivate func startLoadImage(for index: IndexPath) {
        let url = viewModel.getPhotoUrl(for: index)
        ImageLoader.shared.downloadImage(with: url) { [weak self] (image) in
            guard let image = image else {
                return
            }

            self?.cachedImages[url] = image
            self?.collectionView.reloadItems(at: [index])
        }
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension MVVMViewController: UICollectionViewDelegateFlowLayout {

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
        if (indexPath.row + 1) == viewModel.photosCount {
            viewModel.loadMorePhotos()
        }
    }

}

extension MVVMViewController: ViewModelDelegate {

    func didLoadingStateChanged(in viewModel: ViewModel, from oldState: Bool, to newState:Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = newState
    }

    func didUpdatedData(in viewModel: ViewModel) {
        collectionView.reloadData()
    }

}
