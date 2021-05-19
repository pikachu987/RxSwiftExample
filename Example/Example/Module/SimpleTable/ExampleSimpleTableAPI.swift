//
//  ExampleSimpleTableAPI.swift
//  Example
//
//  Created by GwanhoKim on 2021/05/19.
//

import Foundation
import RxSwift
import RxCocoa

class ExampleSimpleTableAPI: NSObject {
    static func simple() -> Single<[ExampleSimpleTableMemberModel]> {
        guard let path = Bundle.main.path(forResource: "ExampleSimpleTableMember", ofType: "json"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
           let list = try? JSONDecoder().decode([ExampleSimpleTableMemberModel].self, from: data) else {
            return Single.error(NSError(domain: "error", code: -1, userInfo: nil))
        }
        return Single.just(list)
    }
}
