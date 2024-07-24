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
            .frame(width: 75, height: 75)
            .foregroundColor(.red)
            .padding(.top, 32)
            .padding(.horizontal, 32)
        Text(error)
            .foregroundColor(.red)
            .padding(.bottom, 32)
            .padding(.horizontal, 32)
            .frame(alignment: .center)
    }
}

#Preview {
    ErrorView(error: "some error occured")
}
