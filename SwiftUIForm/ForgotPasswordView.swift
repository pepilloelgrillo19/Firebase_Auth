//
//  ForgotPasswordView.swift
//  SwiftUIForm
//
//  Created by Luis on 25/4/24.
//

import SwiftUI

struct ForgotPasswordView: View {
    
    @State private var emailAddress: String = ""
    @EnvironmentObject var authModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView{
            Form {
                Section {
                    TextField("Email", text: $emailAddress)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                }
                Section(footer: Text("Once sent, check youremail to reset your password.")) {
                    Button( action: {
                        authModel.resetPassword(emailAddress:emailAddress)
                    }) {
                        Text("Send email link").bold()
                    }
                }
            }.navigationTitle("Reset password")
                .toolbar {
                    ToolbarItemGroup(placement:
                            .confirmationAction) {
                                Button("Done") {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                }
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
