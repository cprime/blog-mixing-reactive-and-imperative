//
//  Observable+Helpers.swift
//  RxCompletable
//
//  Created by Prime, Colden on 2/2/18.
//  Copyright © 2018 Intrepid Pursuits. All rights reserved.
//

import Alamofire
import Foundation
import RxSwift

extension Observable {
    static func create(from block: @escaping (@escaping (Element) -> Void) -> ()) -> Observable<Element> {
        return Observable.create({ observer in
            block({ element in
                observer.on(.next(element))
                observer.on(.completed)
            })
            return Disposables.create()
        })
    }
}

extension Observable {
    static func create(from block: @escaping (@escaping (Result<Element>) -> Void) -> ()) -> Observable<Element> {
        return Observable.create({ observer in
            block({ result in
                switch result {
                case .success(let element):
                    observer.on(.next(element))
                    observer.on(.completed)
                case .failure(let error):
                    observer.on(.error(error))
                }
            })
            return Disposables.create()
        })
    }
}
