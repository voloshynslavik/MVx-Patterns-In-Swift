//
//  PatternsTableViewController.swift
//  MVX Patterns In Swift
//
//  Created by Yaroslav Voloshyn on 18/07/2017.
//

import UIKit

final class PatternsTableViewController: UITableViewController {

    private lazy var mvvvmcCoordinator: MVVMCCoordinator? = {
        guard let nc = self.navigationController else {
            return nil
        }

        return MVVMCCoordinator(navigationController: nc)
    }()

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mvvmViewController = segue.destination as? MVVMViewController {
                let viewModel = ViewModel()
                viewModel.delegate = mvvmViewController
                mvvmViewController.viewModel = viewModel
        } else if let mvpViewController = segue.destination as? MVPViewController {
            let presenter = ConcretePresenter(view: mvpViewController)
            mvpViewController.presenter = presenter
        }

    }

    @IBAction func onSelectMVVMC(_ sender: UITapGestureRecognizer) {
        mvvvmcCoordinator?.start()
    }

}
