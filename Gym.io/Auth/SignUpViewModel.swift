//
//  SignUpViewModel.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/9/24.
//

import SwiftUI

class SignUpViewModel: ObservableObject {
    @Published var username = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var isCreatingAccount = false
    
    func createAccount() {
        // show loader while creating
        isCreatingAccount = true
        
        // api location is gym-io-api.vercel.app/api/user
        let url = URL(string: "https://gym-io-api.vercel.app/api/user")!
        
        // request body
        let body = [
            "username": username,
            "name": firstName + " " + lastName,
        ]
        
        // POST request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // send request
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isCreatingAccount = false
            }
            
            if let data = data {
                print(String(data: data, encoding: .utf8)!)
            }
        }.resume()
    }
}
