//
//  MVVMCDetailsViewModel.swift
//  MVX Patterns In Swift
//
//  Created by Yaroslav Voloshyn on 09/09/2017.
//

import Foundation

protocol MVVMCDetailsViewModelСoordinatorDelegate: class {
    func done(in viewModel: MVVMCDetailsViewModel)
}

protocol MVVMCDetailsViewModelDelegate: class {
    func didLoadImage(image: Data?, in viewModel: MVVMCDetailsViewModel)
}

final class MVVMCDetailsViewModel {

    let name: String
    private let url: String

    private(set) var image: Data? {
        didSet {
            delegate?.didLoadImage(image: image, in: self)
        }
    }

    weak var delegate: MVVMCDetailsViewModelDelegate?
    weak var coordinatorDelegate: MVVMCDetailsViewModelСoordinatorDelegate?

    init(name: String, url: String) {
        self.name = name
        self.url = url
    }

    func updateImage() {
        DataLoader.shared.downloadData(with: url) { [weak self] (data) in
            self?.image = data
        }
    }

    func done() {
        coordinatorDelegate?.done(in: self)
    }
}
