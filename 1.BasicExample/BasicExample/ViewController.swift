//
//  ViewController.swift
//  BasicExample
//
//  Created by APPLE on 22/11/2018.
//  Copyright © 2018 pikachu987. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    let ex1 = Ex1Observable()
    let ex2 = Ex2Subject()
    let ex3 = Ex3ObservableSynthesis()
    let ex4 = Ex4Error()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        Observable.zip(observable1, Observable.just("Sum")) { (sum, text) -> String in return "\(text): \(sum)" }
//            .subscribeOn(SerialDispatchQueueScheduler(qos: .background)) // 백그라운드에서 연산한다.
//            .observeOn(MainScheduler.instance) // UI등을 변화시킬때는 메인에서 처리할수 있게 쓰레드를 변경한다.
//            .subscribe(onNext: { (value) in
//                print("Observable zip Complete")
//                let label = UILabel(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 100))
//                label.text = value
//                // self.view.addSubview(label)
//            })
//            .disposed(by: self.disposeBag)
    }
    
    
//    func setup1() {
//        self.button.rx.tap
//            .subscribe(onNext: { [weak self] in self?.reload() })
//            .disposed(by: self.disposeBag)
//    }
//
//    func setup2() {
//        self.button.rx.tap
//            .bind(onNext: self.reload)
//            .disposed(by: self.disposeBag)
//        //bindNext도 self 레퍼런스를 strong하게 capture하기 때문에 사용하지 않게 될 때 명시적으로 disposeBag을 해제하는 등의 주의를 기울여야 합니다.
//    }
//
//    func setup3() {
//        self.button.rx.tap
//            .do(onNext: {
//                print("buttonClick")
//            })
//            .bind(onNext: self.reload)
//            .disposed(by: self.disposeBag)
//        //또한 메서드 체이닝으로 오퍼레이터를 추가할 수 있는데, 위 코드처럼 중간에 이벤트에 대한 로그를 넣을 수도 있습니다.
//    }
//
//    func setup4() {
//        self.button.rx.tap
//            .debounce(1, scheduler: MainScheduler.instance)
//            .do(onNext: {
//                print("buttonClick")
//            })
//            .subscribe(onNext: { [weak self] in self?.reload() })
//            .disposed(by: self.disposeBag)
//        //debounce는 이벤트를 그룹화하여 특정시간이 지난 후 하나의 이벤트만 발생하는 기술이다.
//    }
//
//    func setup5() {
//        self.textField.rx.text
//            .throttle(1, scheduler: MainScheduler.instance)
//            .subscribe({ (event) in
//                print(event.element as? String ?? "")
//            })
//            .disposed(by: self.disposeBag)
//        //throttle은 이벤트를 일정한 주기마다 발생하도록 하는 기술이다.
//    }
//
//    func reload() {
//        print("reload")
//    }
//
    
    
}

