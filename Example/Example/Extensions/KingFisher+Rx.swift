//
//  KingFisher+Rx.swift
//  Example
//
//  Created by corpdocfriends on 2021/05/31.
//

import Kingfisher
import RxSwift

extension KingfisherManager: ReactiveCompatible {
    public var rx: Reactive<KingfisherManager> {
        get { return Reactive(self) }
        set { }
    }
}

extension Reactive where Base == KingfisherManager {
    public func image(with source: URL) -> Single<KFCrossPlatformImage> {
        return Single.create { [base] single in
            base.retrieveImage(with: source, options: nil) { result in
                switch result {
                case .success(let value):
                    single(.success(value.image))
                case .failure(let error):
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
