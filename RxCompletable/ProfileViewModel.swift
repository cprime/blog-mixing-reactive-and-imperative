//
//  ProfileViewModel.swift
//  RxCompletable
//
//  Created by Prime, Colden on 2/3/18.
//  Copyright © 2018 Intrepid Pursuits. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: Fully Reactive

class ProfileViewModel {
    private let userID: String
    private let userManager: UserManagerType
    private let user: Observable<User>
    private let group: Observable<[User]>

    var displayName: Driver<String> {
        return user
            .map({ $0.displayName })
            .asDriver(onErrorJustReturn: "")
    }

    var email: Driver<String> {
        return user
            .map({ $0.email })
            .asDriver(onErrorJustReturn: "")
    }

    var connectionCount: Driver<String> {
        return group
            .map({ $0.count - 1 })
            .asDriver(onErrorJustReturn: 0)
            .map({ "\($0) connections" })
    }

    init(userID: String, userManager: UserManagerType) {
        self.userID = userID
        self.userManager = userManager

        user = userManager
            .getUser(withUserID: userID)
            .share(replay: 1)
        group = user
            .map({ $0.groupID })
            .flatMapLatest({ userManager.getUsers(withGroupID: $0) })
    }
}

// MARK: Partially Reactive, Partially Imperative

//class ProfileViewModel {
//    private let userID: String
//    private let userManager: UserManager
//    private let user: BehaviorSubject<User?> = BehaviorSubject(value: nil)
//    private let group: BehaviorSubject<[User]> = BehaviorSubject(value: [])
//
//    var displayName: Driver<String> {
//        return user
//            .map({ $0?.displayName ?? "" })
//            .asDriver(onErrorJustReturn: "")
//    }
//
//    var email: Driver<String> {
//        return user
//            .map({ $0?.email ?? "" })
//            .asDriver(onErrorJustReturn: "")
//    }
//
//    var connectionCount: Driver<String> {
//        return group
//            .map({ $0.count - 1})
//            .asDriver(onErrorJustReturn: 0)
//            .map({ "\($0) connections" })
//    }
//
//    init(userID: String, userManager: UserManager) {
//        self.userID = userID
//        self.userManager = userManager
//
//        userManager.getUser(withUserID: userID) { [weak self] result in
//            if case .success(let user) = result {
//                self?.user.onNext(user)
//                userManager.getUsers(withGroupID: user.groupID) { [weak self] result in
//                    if case .success(let users) = result {
//                        self?.group.onNext(users)
//                    }
//                }
//            }
//        }
//    }
//}

// MARK: Fully Imperative

//class ProfileViewModel {
//    private let userID: String
//    private let userManager: UserManager
//    private var user: User?
//    private var group: [User] = []
//
//    var displayName: String {
//        return user?.displayName ?? ""
//    }
//
//    var email: String {
//         return user?.email ?? ""
//    }
//
//    var connectionCount: String {
//        let count = group.count - 1
//        return "\(count) connections"
//    }
//
//    init(userID: String, userManager: UserManager) {
//        self.userID = userID
//        self.userManager = userManager
//    }
//
//    func reloadData(completion: @escaping (Bool) -> Void) {
//        userManager.getUser(withUserID: userID) { [weak self] result in
//            if case .success(let user) = result {
//                self?.user = user
//                self?.userManager.getUsers(withGroupID: user.groupID) { [weak self] result in
//                    if case .success(let users) = result {
//                        self?.group = users
//                        completion(true)
//                    } else {
//                        completion(false)
//                    }
//                }
//            } else {
//                completion(false)
//            }
//        }
//    }
//}

