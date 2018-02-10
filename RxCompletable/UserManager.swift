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

enum Method {
    case GET
}

struct Request {
    let method: Method
    let path: String
    let authenticated: Bool
    let parameters: [String:Any]
}

struct APIClient {
    func sendRequest(_ request: Request, completion: (Result<Data?>) -> Void) {
    }
}

class UserManager {
    static let shared = UserManager()
    let apiClient = APIClient()

    // MARK: Imperative

    func getUser(withUserID userID: String, completion: @escaping (Result<User>) -> Void) {
        let request = Request(
            method: .GET,
            path: "user",
            authenticated: true,
            parameters: ["user_id": userID]
        )
        apiClient.sendRequest(request) { result in
            // Process result and call completion
        }
    }

    func getUsers(withGroupID groupID: String, completion: @escaping (Result<[User]>) -> Void) {
        let request = Request(
            method: .GET,
            path: "user",
            authenticated: true,
            parameters: ["group_id": groupID]
        )
        apiClient.sendRequest(request) { result in
            // Process result and call completion
        }
    }

    // MARK: Rx

//    func getUser(withUserID userID: String) -> Observable<User> {
//        return Observable.create({ observer in
//            self.getUser(withUserID: userID, completion: { result in
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
//        return Observable.create({ observer in
//            self.getUsers(withGroupID: groupID, completion: { result in
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
