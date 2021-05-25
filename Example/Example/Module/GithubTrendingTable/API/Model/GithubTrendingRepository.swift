//
//  GithubTrendingRepository.swift
//  Example
//
//  Created by corpdocfriends on 2021/05/20.
//

import Foundation

struct GithubTrendingRepository: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, url, description, size, owner
        case htmlURL = "html_url"
        case updatedAt = "updated_at"
        case stargazersCount = "stargazers_count"
        case watchersCount = "watchers_count"
        case forksCount = "forks_count"
        case openIssuesCount = "open_issues_count"
    }

    let id: Double
    let name: String
    let htmlURL: String
    let url: String
    let description: String?
    let updatedAt: String? // 2021-05-18T22:09:24Z
    let size: Int
    let stargazersCount: Int
    let watchersCount: Int
    let forksCount: Int
    let openIssuesCount: Int
    let owner: GithubTrendingRepositoryOwner?
}

extension GithubTrendingRepository {
    var updatedRegDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        guard let date = dateFormatter.date(from: self.updatedAt ?? "") else { return "" }
        let calendar = Calendar.current
        guard let year = (calendar as NSCalendar).components(.year, from: date).year,
              let month = (calendar as NSCalendar).components(.month, from: date).month,
              let day = (calendar as NSCalendar).components(.day, from: date).day,
              let hour = (calendar as NSCalendar).components(.hour, from: date).hour,
              let minute = (calendar as NSCalendar).components(.minute, from: date).minute else { return "" }
        let yearString = "\(year)"
        let monthString = month < 10 ? "0\(month)" : "\(month)"
        let dayString = day < 10 ? "0\(day)" : "\(day)"
        let hourString = hour < 10 ? "0\(hour)" : "\(hour)"
        let minuteString = minute < 10 ? "0\(minute)" : "\(minute)"
        return "\(yearString)-\(monthString)-\(dayString) \(hourString):\(minuteString)"
    }
}
