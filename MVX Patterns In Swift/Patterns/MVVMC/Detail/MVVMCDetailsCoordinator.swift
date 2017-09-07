//
//  MVVMCDetailsCoordinator.swift
//  MVX Patterns In Swift
//
//  Created by Yaroslav Voloshyn on 09/09/2017.
//

import UIKit

final class MVVMCDetailsCoordinator: Coordinator {

    let navigationController: UINavigationController
    let name: String
    let url: String

    fileprivate var detaisViewController: MVVMCDetailsViewController?

    init(navigationController: UINavigationController, name: String, url: String) {
        self.navigationController = navigationController
        self.name = name
        self.url = url
    }

    func start() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "MVVMCDetailsViewController") as? MVVMCDetailsViewController else {
            return
        }
        
        detaisViewController = controller
        let viewModel = MVVMCDetailsViewModel(name: name, url: url)
        viewModel.delegate = controller
        viewModel.coordinatorDelegate = self
        controller.viewModel = viewModel
        self.navigationController.present(controller, animated: true, completion: nil)
    }

}

// MARK:- MVVMCDetailsViewModelСoordinatorDelegate
extension MVVMCDetailsCoordinator: MVVMCDetailsViewModelСoordinatorDelegate {

    func done(in viewModel: MVVMCDetailsViewModel) {
        detaisViewController?.dismiss(animated: true, completion: nil)
    }

}
