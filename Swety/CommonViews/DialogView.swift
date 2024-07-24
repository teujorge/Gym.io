//
//  DialogView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/23/24.
//

import SwiftUI

struct DialogView: View {
    @EnvironmentObject var dialogManager: DialogManager

    var body: some View {
        if dialogManager.isShowingDialog {
            VStack {
                dialogManager.dialogContent
                Button("Close") {
                    dialogManager.hideDialog()
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(.black.opacity(0.2))
            .shadow(radius: .large)
            .zIndex(1)
            .ignoresSafeArea(.all)
            .onTapGesture {
                if dialogManager.allowPop {
                    dialogManager.hideDialog()
                }
            }
        }
    }
}
