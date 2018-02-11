//
//  User.swift
//  RxCompletable
//
//  Created by Prime, Colden on 2/2/18.
//  Copyright © 2018 Intrepid Pursuits. All rights reserved.
//

import Foundation

struct User: Codable {
    let userID: String
    let displayName: String
    let email: String
    let groupID: String

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case groupID = "group_id"
        case userID = "user_id"
        case email
    }
}
