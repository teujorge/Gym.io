//
//  SignInViewModel.swift
//  Gym.io
//
//  Created by Matheus Jorge on 7/9/24.
//

import SwiftUI
import Combine

class SignInViewModel: ObservableObject {
    @Published var username = ""
    @Published var isSearching = false
    @Published var userProfiles = [User]()
    
    private var debounceCancellable: AnyCancellable?
    
    func setupDebounce() {
        debounceCancellable = $username
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] newValue in
                self?.searchByUsername()
            }
    }
    
    private func searchByUsername() {
        guard !username.isEmpty else {
            userProfiles = []
            return
        }
        
        guard !isSearching else {
            return
        }
        
        isSearching = true
        
        let url = URL(string: "https://gym-io-api.vercel.app/api/user?username=\(username)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isSearching = false
            }
            
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([String: [User]].self, from: data) {
                    DispatchQueue.main.async {
                        self?.userProfiles = decodedResponse["result"] ?? []
                    }
                    return
                }
            }
        }.resume()
    }
}
