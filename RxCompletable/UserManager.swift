//
//  UserManager.swift
//  RxCompletable
//
//  Created by Prime, Colden on 2/2/18.
//  Copyright © 2018 Intrepid Pursuits. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

protocol UserManagerType: class {
    func getUser(withUserID userID: String, completion: @escaping (Result<User>) -> Void)
    func getUsers(withGroupID groupID: String, completion: @escaping (Result<[User]>) -> Void)
}

class UserManager: UserManagerType {
    let networkingLayer: NetworkingLayer

    init(networkingLayer: NetworkingLayer) {
        self.networkingLayer = networkingLayer
    }

    // MARK: Imperative

    func getUser(withUserID userID: String, completion: @escaping (Result<User>) -> Void) {
        let request = Request(
            method: .GET,
            path: "users",
            authenticated: true,
            parameters: ["user_id": userID]
        )
        networkingLayer.sendRequest(request) { result in
            completion(result)
        }
    }

    func getUsers(withGroupID groupID: String, completion: @escaping (Result<[User]>) -> Void) {
        let request = Request(
            method: .GET,
            path: "groups",
            authenticated: true,
            parameters: ["group_id": groupID]
        )
        networkingLayer.sendRequest(request) { result in
            completion(result)
        }
    }
}

extension UserManagerType {
    // MARK: Rx - With Boilerplate Code

//    func getUser(withUserID userID: String) -> Observable<User> {
//        return Observable.create({ [weak self] observer in
//            self?.getUser(withUserID: userID, completion: { result in
//                switch result {
//                case .success(let element):
//                    observer.on(.next(element))
//                    observer.on(.completed)
//                case .failure(let error):
//                    observer.on(.error(error))
//                }
//            })
//            return Disposables.create()
//        })
//    }
//
//    func getUsers(withGroupID groupID: String) -> Observable<[User]> {
//        return Observable.create({ [weak self] observer in
//            self?.getUsers(withGroupID: groupID, completion: { result in
//                switch result {
//                case .success(let element):
//                    observer.on(.next(element))
//                    observer.on(.completed)
//                case .failure(let error):
//                    observer.on(.error(error))
//                }
//            })
//            return Disposables.create()
//        })
//    }

    // MARK: Rx - Without Boilerplate Code

    func getUser(withUserID userID: String) -> Observable<User> {
        return Observable.create(from: { [weak self] completion in
            self?.getUser(withUserID: userID, completion: completion)
        })
    }

    func getUsers(withGroupID groupID: String) -> Observable<[User]> {
        return Observable.create(from: { [weak self] completion in
            self?.getUsers(withGroupID: groupID, completion: completion)
        })
    }
}
