//
//  ProfileViewModel.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/9/24.
//

import Foundation

class ProfileViewModel: ObservableObject {
    let userId = UserDefaults.standard.string(forKey: .userId)
        
    func editUser(name: String, username: String) async -> User? {
        
        guard let userId = userId else {
            print("Could not find userId in UserDefaults")
            return nil
        }
                
        guard !(name.isEmpty && username.isEmpty) else {
            print("Please provide name or username to update")
            return nil
        }
        
        let url = URL(string: "https://gym-io-api.vercel.app/api/users/\(userId)")!
        let body = [
            "name": name,
            "username": username
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            print("editUserRaw: \(String(data: data, encoding: .utf8)!)")
            
            do {
                let decodedResponse = try JSONDecoder().decode([String: User].self, from: data)
                if let user = decodedResponse["data"] {
                    print("User edited: \(user)")
                    return user
                } else {
                    print("Failed to find user in decoded response")
                }
            } catch let decodeError {
                print("Failed to decode user: \(decodeError)")
            }
        } catch {
            print("Failed to edit user: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func deleteUser() async -> Bool {
        
        guard let userId = userId else {
            print("Could not find userId in UserDefaults")
            return false
        }
        
        let url = URL(string: "https://gym-io-api.vercel.app/api/users/\(userId)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            print("deleteUserRaw: \(response)")
            
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
        } catch {
            print("Failed to delete user: \(error.localizedDescription)")
        }
        
        return false
    }
    
}
