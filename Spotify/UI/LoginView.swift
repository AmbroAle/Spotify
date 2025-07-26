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
                    HStack(spacing: 12) {
                        Image("Sonix")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)

                        Text("Sonix")
                            .font(.system(size: 36, weight: .medium))
                            .fontWeight(.bold)
                            .foregroundColor(.primary) // oppure bianco, se su sfondo scuro
                    }
                    .padding(.bottom, 20)

                    


                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.none)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)

                    if let error = authVM.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }

                    LiquidGlassButton(
                        title: isRegistering ? "Registrati" : "Accedi",
                        action: {
                            if isRegistering {
                                authVM.register(email: email, password: password)
                            } else {
                                authVM.login(email: email, password: password)
                            }
                        },
                        gradientColors: [
                            Color.green.opacity(0.4),
                            Color.green.opacity(0.60)
                        ]
                    )



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
