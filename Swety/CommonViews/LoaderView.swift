//
//  LoaderView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/11/24.
//

import SwiftUI

enum LoaderState: Equatable {
    case idle
    case loading
    case success
    case failure(String)
}

struct LoaderView: View {
    
    let size: Double
    let weight: Font.Weight
    let state: LoaderState
    let showErrorMessage: Bool
    
    @State private var isAnimating = false
    
    init(size: Double = 30, weight: Font.Weight = .light, state: LoaderState = .loading, showErrorMessage: Bool = false) {
        self.size = size
        self.weight = weight
        self.state = state
        self.showErrorMessage = showErrorMessage
    }
    
    var body: some View {
        VStack {
            switch state {
            case .idle:
                Image(systemName: "circle")
                    .resizable()
                    .frame(width: size, height: size)
                    .foregroundColor(.accent)
                    .fontWeight(weight)
                    .transition(.opacity)
            case .loading:
                Image("circle.part")
                    .resizable()
                    .foregroundColor(.accent)
                    .fontWeight(weight)
                    .frame(width: size, height: size)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .onAppear {
                        withAnimation(Animation.linear(duration: 0.8).repeatForever(autoreverses: false)) {
                            self.isAnimating = true
                        }
                    }
                    .onDisappear {
                        self.isAnimating = false
                    }
                    .transition(.opacity)
            case .success:
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .frame(width: size, height: size)
                    .foregroundColor(.green)
                    .fontWeight(weight)
                    .transition(.opacity)
            case .failure(let error):
                Image(systemName: "xmark.circle")
                    .resizable()
                    .frame(width: size, height: size)
                    .foregroundColor(.red)
                    .fontWeight(weight)
                    .transition(.opacity)
                if (showErrorMessage) {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.bottom)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .animation(.easeInOut, value: state)
    }
}

#Preview {
    LoaderPreview()
}

private struct LoaderPreview: View {
    @State private var loaderState: LoaderState = .loading
    
    var body: some View {
        VStack {
            
            LoaderView(state: loaderState, showErrorMessage: true)
                .padding()
            LoaderView(size: 100, weight: .thin, state: loaderState)
                .padding()
            
            HStack {
                Button("Idle") {
                    loaderState = .idle
                }
                Button("Loading") {
                    loaderState = .loading
                }
                Button("Success") {
                    loaderState = .success
                }
                Button("Failure") {
                    loaderState = .failure("The data couldn’t be read because it isn’t in the correct format")
                }
            }
            .padding()
        }
    }
}
