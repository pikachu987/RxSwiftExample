//
//  GithubTrendingViewController.swift
//  Example
//
//  Created by GwanhoKim on 2021/05/19.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class GithubTrendingViewController: BaseViewController {
    static func instance() -> GithubTrendingViewController? {
        let viewController = GithubTrendingViewController(nibName: nil, bundle: nil)
        return viewController
    }

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let viewModel = GithubTrendingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.fetchData()
    }
    
    override func setupUI() {
        super.setupUI()
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            view.topAnchor.constraint(equalTo: tableView.topAnchor),
            view.bottomAnchor.constraint(equalTo: tableView.bottomAnchor)
        ])
    }
    
    override func setupBindings() {
        super.setupBindings()
        
        rx.viewWillAppear.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.title = "Github Trending"
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "👈", style: .done, target: self, action: nil)
            self.navigationItem.leftBarButtonItem?.rx.tap.subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }).disposed(by: self.disposeBag)
        }).disposed(by: self.disposeBag)
        
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.rx
            .controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.fetchData()
            })
            .disposed(by: disposeBag)

        self.viewModel.refreshIndicator
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, GithubTrendingRepository>>(configureCell: { dataSource, tableView, IndexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: IndexPath)
            cell.textLabel?.text = item.name
            return cell
        })

        viewModel.items
            .asDriver()
            .map({ [SectionModel(model: "GithubTrendingRepository", items: $0)] })
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(ExampleSimpleTableMemberModel.self))
            .bind { [weak self] indexPath, item in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            }
            .disposed(by: disposeBag)
    }
}



//final class ViewController: UIViewController {
//    // button Example
//    @IBOutlet private weak var button: UIButton!
//
//    var trackedSectionViewModel = BehaviorRelay(value: [TrackedModelType]())
//    var sectionViewModels: Driver<[TrackedModelType]> {
//        get {
//            return trackedSectionViewModel.asDriver().map { $0 }
//        }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//
//        let customView: CustomView = CustomView(frame: CGRect(x: 0, y: 500, width: 300, height: 60))
//        customView.rx.customTest.subscribe { event in
//            print("customTest delegate: \(event)")
//        }.disposed(by: self.disposeBag)
//
//        customView.test()
//        customView.test()
//        customView.test()
//
//        let customSecondView: CustomSecondView = CustomSecondView(frame: CGRect(x: 0, y: 500, width: 300, height: 60))
//        customSecondView.rx.customTest.subscribe { event in
//            print("customSecondView delegate: \(event)")
//        }.disposed(by: self.disposeBag)
//
//        customSecondView.test()
//        customSecondView.test()
//        customSecondView.test()
//
//        self.rx.viewWillAppear
//            .subscribe({ event in
//                print("viewWillAppear!!")
//            })
//            .disposed(by: self.disposeBag)
//
//        let textField = UITextField(frame: CGRect(x: 0, y: 400, width: 300, height: 60))
//        textField.borderStyle = .roundedRect
//        self.view.addSubview(textField)
//
//        textField.rx.text
//            .distinctUntilChanged()
//            .subscribe { event in
//                print(event)
//            }.disposed(by: self.disposeBag)
//    }
//}
//

//
//// objc optional
//
//@objc protocol CustomDelegate: AnyObject {
//    @objc optional func customTest(_ view: CustomView, value: String)
//}
//
//class CustomView: UIView {
//    deinit {
//        print("deinit: \(self)")
//    }
//    weak var delegate: CustomDelegate?
//
//    func test() {
//        self.delegate?.customTest?(self, value: "value")
//    }
//}
//
//class CustomDelegateProxy: DelegateProxy<CustomView, CustomDelegate>, DelegateProxyType, CustomDelegate {
//    deinit {
//        print("deinit: \(self)")
//    }
//
//    static func registerKnownImplementations() {
//        self.register(make: { CustomDelegateProxy(parentObject: $0, delegateProxy: self) })
//    }
//
//    static func currentDelegate(for object: CustomView) -> CustomDelegate? {
//        return object.delegate
//    }
//
//    static func setCurrentDelegate(_ delegate: CustomDelegate?, to object: CustomView) {
//        object.delegate = delegate
//    }
//}
//
//extension Reactive where Base: CustomView {
//    var delegate: DelegateProxy<CustomView, CustomDelegate> {
//        return CustomDelegateProxy.proxy(for: self.base)
//    }
//
//    var customTest: Observable<String> {
//        return delegate.methodInvoked(#selector(CustomDelegate.customTest(_:value:)))
//            .map { parameter in
//                return parameter[1] as? String ?? ""
//            }
//    }
//}
//
//// objc optional X
//
//protocol CustomSecondDelegate: AnyObject {
//    func customTest(_ view: CustomSecondView, value: String)
//}
//
//class CustomSecondView: UIView {
//    deinit {
//        print("deinit: \(self)")
//    }
//    weak var delegate: CustomSecondDelegate?
//
//    func test() {
//        self.delegate?.customTest(self, value: "value")
//    }
//}
//
//class CustomSecondDelegateProxy: DelegateProxy<CustomSecondView, CustomSecondDelegate>, DelegateProxyType, CustomSecondDelegate {
//    deinit {
//        print("deinit: \(self)")
//        self.customTestSubject.onCompleted()
//    }
//
//    lazy var customTestSubject = PublishSubject<String>()
//
//    func customTest(_ view: CustomSecondView, value: String) {
//        self.customTestSubject.onNext(value)
//    }
//
//    static func registerKnownImplementations() {
//        self.register(make: { CustomSecondDelegateProxy(parentObject: $0, delegateProxy: self) })
//    }
//
//    static func currentDelegate(for object: CustomSecondView) -> CustomSecondDelegate? {
//        return object.delegate
//    }
//
//    static func setCurrentDelegate(_ delegate: CustomSecondDelegate?, to object: CustomSecondView) {
//        object.delegate = delegate
//    }
//}
//
//extension Reactive where Base: CustomSecondView {
//    var delegate: CustomSecondDelegateProxy {
//        return CustomSecondDelegateProxy.proxy(for: self.base)
//    }
//
//    var customTest: Observable<String> {
//        return self.delegate.customTestSubject.asObserver()
//    }
//}
