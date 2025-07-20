import SwiftUI

struct LoginView: View {
    @StateObject private var authVM = AppViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                VStack(spacing: 20) {
                    
                    Image("Full_Logo_Green_RGB")
                        .resizable()
                        .scaledToFit()
                        .padding(.bottom, 80)

                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.none)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)

                    if let error = authVM.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }

                    Button(action: {
                        if isRegistering {
                            authVM.register(email: email, password: password)
                        } else {
                            authVM.login(email: email, password: password)
                        }
                    }) {
                        Text(isRegistering ? "Registrati" : "Accedi")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        isRegistering.toggle()
                    }) {
                        Text(isRegistering
                             ? "Hai già un account? Accedi"
                             : "Non hai un account? Registrati")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }

                    Spacer()
                }
                .padding()

                if authVM.isRegistered {
                    Text("✅ Registrazione effettuata!")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.top, 150)
                        .transition(.opacity)
                        .animation(.easeInOut, value: authVM.isRegistered)
                }
                
            }
            .navigationDestination(isPresented: $authVM.isAuthenticated) {
                    HomeView()
            }
        }
    }
}

#Preview {
    LoginView()
}
