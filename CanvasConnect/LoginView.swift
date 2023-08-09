//loginview.swift
import SwiftUI
import FirebaseAuth

struct LoginPage: View {
    @Binding var loggedIn: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var errorText = ""
    @State private var showPassword = false // Toggle for showing the password

    var body: some View {
        VStack {
            Text("bartista")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom)

            TextField("Email", text: $email)
                .padding()
                .autocapitalization(.none)

            HStack {
                if showPassword {
                    TextField("Password", text: $password)
                } else {
                    SecureField("Password", text: $password)
                }
                Button(action: {
                    showPassword.toggle()
                }) {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .padding()

            Button("Login", action: login)
                .padding()

            Button("Register", action: register)
                .padding()

            Text(errorText)
                .foregroundColor(.red)
        }
        .padding()
    }

    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorText = error.localizedDescription
            } else {
                // Handle successful login
                self.errorText = ""
                self.loggedIn = true
            }
        }
    }

    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorText = error.localizedDescription
            } else {
                // Handle successful registration
                self.errorText = ""
                self.loggedIn = true
            }
        }
    }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage(loggedIn: .constant(false))
    }
}
