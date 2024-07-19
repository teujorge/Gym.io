//
//  HTTPClient.swift
//  Swety
//
//  Created by Matheus Jorge on 7/11/24.
//

import Foundation

enum HTTPResponse<T> {
    case success(T)
    case failure(String)
}

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

struct EmptyBody: Codable {}

func sendRequest<T: Codable>(endpoint: String, queryItems: [URLQueryItem]? = nil, body: Encodable? = nil, method: HTTPMethod, shouldRetry: Bool = true) async -> HTTPResponse<T> {
    print("")
    print("Sending request to \(endpoint)")
    
//    let baseURL = "https://swety.fit/"
    let baseURL = "https://swety-git-authentication-mrljorge.vercel.app/"
    var components = URLComponents(string: "\(baseURL)api/\(endpoint)")!
    if let queryItems = queryItems {
        components.queryItems = queryItems
    }
    
    guard let url = components.url else {
        print("Invalid URL")
        return .failure("Invalid URL")
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    
    if let token = currentUserAccessToken {
        print("Token: \(token)")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    
    if let body = body {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        if let jsonData = try? encoder.encode(body) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("HTTP Request: \(jsonString)")
            }
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } else {
            print("Failed to encode body")
            return .failure("Failed to encode request body")
        }
    }

    do {
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Response Status: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 403 {
                if shouldRetry {
                    print("HTTP Response: 403 and shouldRetry")
                    // Handle expired token
                    let refreshResult: HTTPResponse<Auth> = await refreshAuthToken()
                    switch refreshResult {
                    case .success(_):
                        return await sendRequest(endpoint: endpoint, queryItems: queryItems, body: body, method: method, shouldRetry: false)
                    case .failure(let error):
                        currentUserAccessToken = nil
                        currentUserRefreshToken = nil
                        return .failure("Failed to refresh token: \(error)")
                    }
                } else {
                    print("HTTP Response: 403 and !shouldRetry")
                    // Handle sign out
                    currentUserAccessToken = nil
                    currentUserRefreshToken = nil
                }
            }
            
        }
        if let responseString = String(data: data, encoding: .utf8) {
            print("HTTP Response: \(responseString)")
        }
        
        let decodedResponse = try JSONDecoder().decode([String: T].self, from: data)
        
        if let decodedData = decodedResponse["data"] {
            return .success(decodedData)
        } else {
            return .failure("Failed to find data in decoded response")
        }
        
    } catch {
        print("HTTP Request Failed: \(error.localizedDescription)")
        return .failure(error.localizedDescription)
    }
}


private func refreshAuthToken() async -> HTTPResponse<Auth> {
    print()
    print("refreshAuthToken")
    print()
    
    guard let refreshToken = currentUserRefreshToken else {
        return .failure("No refresh token available")
    }

    let result: HTTPResponse<Auth> = await sendRequest(
        endpoint: "auth/refresh",
        body: ["refreshToken": refreshToken],
        method: .POST,
        shouldRetry: false
    )

    switch result {
    case .success(let auth):
        currentUserAccessToken = auth.accessToken
        currentUserRefreshToken = auth.refreshToken
        return .success(auth)
    case .failure(let error):
        return .failure("Failed to refresh token: \(error)")
    }
}
