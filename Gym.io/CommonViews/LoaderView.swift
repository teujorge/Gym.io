//
//  LoaderView.swift
//  Gym.io
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
    
    @State private var isAnimating = false
    
    init(size: Double = 50, weight: Font.Weight = .regular, state: LoaderState = .loading) {
        self.size = size
        self.weight = weight
        self.state = state
    }
    
    var body: some View {
        ZStack {
            
            switch state {
            case .idle:
                Image(systemName: "circle")
                    .resizable()
                    .frame(width: size, height: size)
                    .foregroundColor(.blue)
                    .fontWeight(weight)
                    .transition(.opacity)
            case .loading:
                Image("circle.part")
                    .resizable()
                    .foregroundColor(.blue)
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
            case .failure:
                Image(systemName: "xmark.circle")
                    .resizable()
                    .frame(width: size, height: size)
                    .foregroundColor(.red)
                    .fontWeight(weight)
                    .transition(.opacity)
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
            
            LoaderView(state: loaderState)
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
                    loaderState = .failure("error message")
                }
            }
            .padding()
        }
    }
}
