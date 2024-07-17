//
//  HTTPClient.swift
//  Gym.io
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

func sendRequest<T: Codable>(endpoint: String, queryItems: [URLQueryItem]? = nil, body: Encodable? = nil, method: HTTPMethod) async -> HTTPResponse<T> {
    let baseURL = "https://swety.fit/"
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
