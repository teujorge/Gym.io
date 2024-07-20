//
//  AuthModel.swift
//  Swety
//
//  Created by Matheus Jorge on 7/18/24.
//

import Foundation
import Combine

class Auth: ObservableObject, Codable {
    static let shared = Auth()
    
    @Published var id: String
    @Published var password: String?
    @Published var accessToken: String? { didSet { currentUserAccessToken = accessToken } }
    @Published var refreshToken: String? { didSet { currentUserRefreshToken = refreshToken } }
    @Published var userId: String
    
    @Published var user: User?
    
    enum CodingKeys: String, CodingKey {
        case id, userId, password, accessToken, refreshToken, user
    }
    
    init() {
        id = ""
        password = nil
        accessToken = currentUserAccessToken
        refreshToken = currentUserRefreshToken
        userId = ""
        user = nil
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        password = try container.decodeIfPresent(String.self, forKey: .password)
        accessToken = try container.decodeIfPresent(String.self, forKey: .accessToken)
        refreshToken = try container.decodeIfPresent(String.self, forKey: .refreshToken)
        userId = try container.decode(String.self, forKey: .userId)
        user = try container.decodeIfPresent(User.self, forKey: .user)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(password, forKey: .password)
        try container.encode(accessToken, forKey: .accessToken)
        try container.encode(refreshToken, forKey: .refreshToken)
        try container.encode(userId, forKey: .userId)
        try container.encode(user, forKey: .user)
    }
    
    var isSignedIn: Bool {
        return user != nil
    }
    
    func clear() {
        id = ""
        password = nil
        accessToken = nil
        refreshToken = nil
        userId = ""
        user = nil
    }
    
}
