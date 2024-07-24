//
//  DialogManager.swift
//  Swety
//
//  Created by Matheus Jorge on 7/23/24.
//

import SwiftUI

class DialogManager: ObservableObject {
    @Published var isShowingDialog: Bool = false
    @Published var dialogContent: AnyView? = nil

    func showDialog<Content: View>(@ViewBuilder content: () -> Content) {
        self.dialogContent = AnyView(content())
        self.isShowingDialog = true
    }

    func hideDialog() {
        self.isShowingDialog = false
        self.dialogContent = nil
    }
}
