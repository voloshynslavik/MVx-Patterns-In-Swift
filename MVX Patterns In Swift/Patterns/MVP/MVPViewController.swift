//
//  MVPViewController.swift
//  MVX Patterns In Swift
//
//  Created by Yaroslav Voloshyn on 18/07/2017.
//

import UIKit

protocol PhotosView: class {

    func showNetworkActivityIndicator()
    func hideNetworkActivityIndicator()
    func updateView(with data: [(title: String, data: Data?)])
    func updateCell(at index: Int, with data: (title: String, data: Data?))
    
}

private let cellId = "500px_image_cell"

final class MVPViewController: UIViewController {

    fileprivate var data: [(title: String, data: Data?)] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    @IBOutlet weak var collectionView: UICollectionView!
    var presenter: Presenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        presenter.loadMoreItems()
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
        presenter.stopLoadPhoto(for: indexPath.row)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row + 1) == data.count {
            presenter.loadMoreItems()
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
        cell.imageView.image = getImage(for: indexPath)

        return cell
    }

    private func getImage(for indexPath: IndexPath) -> UIImage? {
        guard let imageData = data[indexPath.row].data else {
            presenter.startLoadPhoto(for: indexPath.row)
            return nil
        }

        return UIImage(data: imageData)
    }
}

// MARK: - View
extension MVPViewController: PhotosView {

    func updateView(with data: [(title: String, data: Data?)]) {
        self.data = data
    }

    func showNetworkActivityIndicator() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    func hideNetworkActivityIndicator() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

    func updateCell(at index: Int, with data: (title: String, data: Data?)) {
        self.data[index] = data
        let indexPath = IndexPath(row: index, section: 0)
        collectionView.reloadItems(at: [indexPath])
    }
}

