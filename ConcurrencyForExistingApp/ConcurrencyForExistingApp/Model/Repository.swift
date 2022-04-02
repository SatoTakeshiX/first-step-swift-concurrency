//
//  Repository.swift
//  ConcurrencyForExistingApp
//
//  Created by satoutakeshi on 2022/04/02.
//

import Foundation

public struct Repository: Decodable, Hashable, Identifiable {
    public let id: Int
    public let name: String
    public let description: String?
    public let stargazersCount: Int
    public let language: String?
    public let htmlUrl: String
    public let owner: Owner
}

public struct Owner: Decodable, Hashable, Identifiable {
    public let id: Int
    public let avatarUrl: String
}
