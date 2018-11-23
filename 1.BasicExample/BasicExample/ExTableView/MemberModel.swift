import Foundation

struct MemberModel {
    let id: Int
    let name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    init(json: AnyObject) {
        self.id = (json["id"] as? Int) ?? 0
        self.name = (json["name"] as? String) ?? ""
    }
}
