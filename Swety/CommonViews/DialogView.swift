//
//  DialogView.swift
//  Swety
//
//  Created by Matheus Jorge on 7/23/24.
//

import SwiftUI

struct DialogView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var dialogManager: DialogManager

    var body: some View {
        if dialogManager.isShowingDialog {
            VStack(alignment: .center) {
                Spacer()
                dialogManager.dialogContent
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(colorScheme == .dark ? .black.opacity(0.7) : .black.opacity(0.3))
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
