//
//  ProfileViewController.swift
//  RxCompletable
//
//  Created by Prime, Colden on 2/2/18.
//  Copyright © 2018 Intrepid Pursuits. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

struct StubbedNetworkingLayer: NetworkingLayer {
    var stubbedUser: User?
    var stubbedGroup: [User]?
    func sendRequest(_ request: Request, completion: @escaping (Result<Data?>) -> Void) {
        let encoder = JSONEncoder()
        var data: Data?
        switch request.path {
        case "users":
            data = try? encoder.encode(stubbedUser)
        case "groups":
            data = try? encoder.encode(stubbedGroup)
        default:
            break
        }
        DispatchQueue.main.async {
            if let data = data {
                completion(.success(data))
            } else {
                completion(.failure(NetworkingError.unknown))
            }
        }
    }
}

class ProfileViewController: UIViewController {
    let viewModel: ProfileViewModel = {
        let user1 = User(userID: "user_1", displayName: "Alice", email: "alice@example.com", groupID: "group_1")
        let user2 = User(userID: "user_2", displayName: "Bob", email: "bob@example.com", groupID: "group_1")

        var networkingLayer = StubbedNetworkingLayer()
        networkingLayer.stubbedUser = user1
        networkingLayer.stubbedGroup = [user1, user2]

        let userManager = UserManager(networkingLayer: networkingLayer)
        
        return ProfileViewModel(userID: user1.userID, userManager: userManager)
    }()

    let disposeBag = DisposeBag()

    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var groupLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.displayName.drive(displayNameLabel.rx.text).disposed(by: disposeBag)
        viewModel.email.drive(emailLabel.rx.text).disposed(by: disposeBag)
        viewModel.connectionCount.drive(groupLabel.rx.text).disposed(by: disposeBag)

//        viewModel.reloadData { [weak self] success in
//            if success {
//                self?.displayNameLabel.text = self?.viewModel.displayName
//                self?.emailLabel.text = self?.viewModel.email
//                self?.groupLabel.text = self?.viewModel.connectionCount
//            }
//        }
    }
}

