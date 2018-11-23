import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = (UIApplication.shared.delegate as? AppDelegate)?.window
        window?.rootViewController = UINavigationController(rootViewController: SearchViewController())
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
        return true
    }
}

