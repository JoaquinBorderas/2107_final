//
//  UserNameView.swift
//  CanvasConnect
//
//  Created by Joaquín Borderas Ochoa on 2023-08-08.
//

import Foundation
import SwiftUI

struct UserNameView: View {
    @Binding var userNameSet: Bool
    @State private var userName: String = ""
    
    var body: some View {
        VStack {
            TextField("Enter your username", text: $userName)
                .padding()
            
            Button("Continue") {
                if !userName.isEmpty {
                    UserDefaults.standard.setValue(userName, forKey: "userName")
                    userNameSet = true
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
}
