//
//  CustomDialogView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/23/24.
//

import SwiftUI

struct CustomDialogView: View {
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
            .frame(maxWidth: 300)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 10)
            .transition(.scale)
            .zIndex(1)
        }
    }
}
