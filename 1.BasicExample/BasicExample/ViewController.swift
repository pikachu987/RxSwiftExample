import UIKit
import RxCocoa
import RxSwift
import RxDataSources


final class ViewController: UIViewController {
    var disposeBag = DisposeBag()
    
    let ex1 = Ex1Observable()
    let ex2 = Ex2Subject()
    let ex3 = Ex3Synthesis()
    let ex4 = Ex4Error()
    let ex5 = Ex5Transforming()
    let ex6 = Ex6Filtering()
    let ex7 = Ex7Utility()
    let ex8 = Ex8Subscriptions()
    
    // button Example
    @IBOutlet private weak var button: UIButton!
    
    // tableView Example
    @IBOutlet private weak var tableView: UITableView!
    typealias TrackedModelType = SectionModel<String, MemberModel>
    var trackedSectionViewModel = Variable([TrackedModelType]())
    var sectionViewModels: Driver<[TrackedModelType]> {
        get {
            return trackedSectionViewModel.asDriver().map { $0 }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        self.buttonExample()
//        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
//        self.tableViewExample()
        
        self.rx.viewWillAppear
            .subscribe({ event in
                print("viewWillAppear!!")
            })
            .disposed(by: self.disposeBag)
    }
    
    
    func buttonExample() {
        self.button.rx.tap
            .subscribe ( onNext: { [weak self] in
                guard let self = self else { return }
                print(self.button)
            })
            .disposed(by: self.disposeBag)
    }
    
    
    func tableViewExample() {
        let path = Bundle.main.path(forResource: "Member", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let jsonResult = try! JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
        let array = (jsonResult as? [AnyObject])!.compactMap { MemberModel(json: $0) }
        self.trackedSectionViewModel.value = [SectionModel(model: "section", items: array)]
        self.bindDataSource()
        
    }
    
    func bindDataSource() {
        func createDataSource() -> RxTableViewSectionedReloadDataSource<TrackedModelType> {
            let dataSource = RxTableViewSectionedReloadDataSource<TrackedModelType>(configureCell: { dataSource, tableView, indexPath, model in
                let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
                cell.textLabel?.text = "\(model.id): \(model.name)"
                return cell
            })
            return dataSource
        }
        self.sectionViewModels
            .drive(self.tableView.rx.items(dataSource: createDataSource()))
            .disposed(by: self.disposeBag)
    }
    
    
    func uiControlExample() {
        
    }
}

extension Reactive where Base: UIViewController {
    internal var viewWillAppear: Observable<[Any]> {
        return self.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
    }
    
}
