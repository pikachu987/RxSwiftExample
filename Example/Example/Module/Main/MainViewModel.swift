//
//  MainViewModel.swift
//  Example
//
//  Created by GwanhoKim on 2021/05/19.
//

import Foundation
import RxSwift
import RxCocoa

final class MainViewModel: BaseViewModel {
    var items = BehaviorRelay<[MainItemType]>(value: MainItemType.array)
    
    override init() {
        super.init()
    }
}

enum MainItemType {
    case simpleTable
    case githubTrending

    static var array: [MainItemType] {
        return [
            .githubTrending,
            .simpleTable
        ]
    }

    var title: String? {
        switch self {
        case .githubTrending: return "Github 트렌딩 테이블 + Refresh + Search + LoadMore + Moya"
        case .simpleTable: return "심플 테이블 + Refresh"
        }
    }
}
