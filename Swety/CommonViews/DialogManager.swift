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
    @Published var allowPop: Bool = true

    func showDialog<Content: View>(allowPop: Bool = true, @ViewBuilder content: () -> Content) {
        self.dialogContent = AnyView(content())
        self.isShowingDialog = true
        self.allowPop = allowPop // Allow the dialog to be popped by clicking outside
    }

    func hideDialog() {
        self.isShowingDialog = false
        self.dialogContent = nil
    }
}
