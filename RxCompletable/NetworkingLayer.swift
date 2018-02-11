//
//  NetworkingLayer.swift
//  RxCompletable
//
//  Created by Prime, Colden on 2/10/18.
//  Copyright © 2018 Intrepid Pursuits. All rights reserved.
//

import Foundation
import Alamofire

enum Method {
    case GET
    case POST
}

struct Request {
    let method: Method
    let path: String
    let authenticated: Bool
    let parameters: [String:Any]
}

enum NetworkingError: Error {
    case unknown
}

protocol NetworkingLayer {
    func sendRequest(_ request: Request, completion: @escaping (Result<Data?>) -> Void)
}

extension NetworkingLayer {
    func sendRequest<T: Decodable>(_ request: Request, completion: @escaping (Result<T>) -> Void) {
        sendRequest(request) { result in
            switch result{
            case .success(let data):
                let jsonDecoder = JSONDecoder()
                if let data = data, let user = try? jsonDecoder.decode(T.self, from: data) {
                    completion(.success(user))
                } else {
                    completion(.failure(NetworkingError.unknown))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
