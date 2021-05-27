//
//  GithubTrendingLanguageItem.swift
//  Example
//
//  Created by GwanhoKim on 2021/05/27.
//

import Foundation

enum GithubTrendingLanguageItem: String {
    case javaScript = "JavaScript"
    case python = "Python"
    case java = "Java"
    case go = "Go"
    case ruby = "Ruby"
    case cpp = "C++"
    case typeScript = "TypeScript"
    case php = "PHP"
    case cshop = "C#"
    case originC = "C"
    case shell = "Shell"
    case scala = "Scala"
    case dart = "Dart"
    case rust = "Rust"
    case kotlin = "Kotlin"
    case swift = "Swift"
    case groovy = "Groovy"
    case objectiveC = "Objective-C"

    static var array: [GithubTrendingLanguageItem] {
        return [
            .javaScript, .python, .java, .go, .ruby,
            .cpp, .typeScript, .php, .cshop, .originC,
            .shell, .scala, .dart, .rust, .kotlin,
            .swift, .groovy, .objectiveC
        ]
    }
}
