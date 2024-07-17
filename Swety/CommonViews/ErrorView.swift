//
//  ErrorView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/13/24.
//

import SwiftUI

struct ErrorView: View {
    var error: String
    
    var body: some View {
        Image(systemName: "exclamationmark.triangle")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .foregroundColor(.red)
            .padding(.top, 32)
            .padding(.horizontal, 32)
        Text(error)
            .foregroundColor(.red)
            .padding(.bottom, 32)
            .padding(.horizontal, 32)
    }
}

#Preview {
    ErrorView(error: "some error occured")
}
