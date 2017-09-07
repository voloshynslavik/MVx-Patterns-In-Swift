//
//  MVVMСDetailsViewController.swift
//  MVX Patterns In Swift
//
//  Created by Yaroslav Voloshyn on 07/09/2017.
//

import UIKit

final class MVVMCDetailsViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    var viewModel: MVVMCDetailsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.name
        viewModel.updateImage()
    }

    @IBAction func done(_ sender: Any) {
        self.viewModel.done()
    }
}

// MARK: - MVVMCDetailsViewModelDelegate
extension MVVMCDetailsViewController: MVVMCDetailsViewModelDelegate {

    func didLoadImage(image: Data?, in viewModel: MVVMCDetailsViewModel) {
        guard let image = image else {
            imageView.image = nil
            return
        }
        
        imageView.image = UIImage(data: image)
    }

}
