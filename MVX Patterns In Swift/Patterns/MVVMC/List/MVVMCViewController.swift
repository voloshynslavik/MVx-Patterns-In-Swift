//
//  MVVMViewController.swift
//  MVX Patterns In Swift
//
//  Created by Yaroslav Voloshyn on 17/07/2017.
//

import UIKit

private let cellId = "500px_image_cell"

final class MVVMСViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    fileprivate var cachedImages: [String: UIImage] = [:]
    var viewModel: MVVMCViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        viewModel.loadMoreItems()
    }

}

// MARK: - UICollectionViewDataSource
extension MVVMСViewController: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.photosCount    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? ImageCell else {
            return UICollectionViewCell()
        }

        cell.nameLabel.text = viewModel.getPhotoName(for: indexPath.row)
        cell.imageView.image = getImage(for: indexPath)

        return cell
    }

    private func getImage(for indexPath: IndexPath) -> UIImage? {
        guard let imageData = viewModel.getPhotoData(for: indexPath.row) else {
            return nil
        }

        return UIImage(data: imageData)
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension MVVMСViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let countOfCollumns: CGFloat = 3
        let widthCollectionView = collectionView.frame.width
        let widthCell = (widthCollectionView - (countOfCollumns - 1.0))/countOfCollumns
        return CGSize(width: widthCell, height: widthCell)
    }


    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.stopLoadPhoto(for: indexPath.row)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row + 1) == viewModel.photosCount {
            viewModel.loadMoreItems()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.usePhotoAtIndex(indexPath.row)
    }
}

// MARK: - ViewModelDelegate
extension MVVMСViewController: MVVMCViewModelDelegate {

    func didLoadingStateChanged(in viewModel: MVVMCViewModel, from oldState: Bool, to newState:Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = newState
    }

    func didUpdatedData(in viewModel: MVVMCViewModel) {
        collectionView.reloadData()
    }

    func didDownloadPhoto(in viewMode: MVVMCViewModel, with index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        collectionView.reloadItems(at: [indexPath])
    }
}

