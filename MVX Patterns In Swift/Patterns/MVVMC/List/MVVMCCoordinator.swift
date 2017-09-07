//
//  MVVMCCoordinator.swift
//  MVX Patterns In Swift
//
//  Created by Yaroslav Voloshyn on 07/09/2017.
//

import UIKit

final class MVVMCCoordinator: Coordinator {

    let navigationController: UINavigationController

    fileprivate var detailsCoordinator: MVVMCDetailsCoordinator?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "MVVMCViewController") as? MVVMСViewController else {
            return
        }
        
        let viewModel = MVVMCViewModel()
        viewModel.delegate = controller
        viewModel.coordinatorDelegate = self
        controller.viewModel = viewModel
        self.navigationController.pushViewController(controller, animated: true)
    }
    
}

// MARK: - MVVMCViewModelCoordinatorDelegate
extension MVVMCCoordinator: MVVMCViewModelCoordinatorDelegate {
    
    func didSelectItem(withName name: String, andUrl url: String) {
        detailsCoordinator = MVVMCDetailsCoordinator(navigationController: navigationController,
                                                     name: name,
                                                     url: url)
        detailsCoordinator?.start()
    }

}
