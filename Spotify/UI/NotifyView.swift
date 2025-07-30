//
//  NotifyView.swift
//  Spotify
//
//  Created by Alex Frisoni on 30/07/25.
//
import SwiftUI

struct NotifyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var inAppNotificationsEnabled: Bool = true
    @State private var successMessage: String?
    @State private var isProcessing = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notifiche In-App")) {
                    Toggle("Attiva notifiche in-app", isOn: $inAppNotificationsEnabled)
                        .onChange(of: inAppNotificationsEnabled) { _, newValue in
                            handleInAppNotificationToggle(newValue)
                        }
                    
                    Text("Le notifiche in-app mostrano messaggi e aggiornamenti mentre stai usando l'applicazione")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                if let successMessage = successMessage {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .font(.caption)
                }
                
                Button(action: {
                    saveNotificationSettings()
                }) {
                    if isProcessing {
                        ProgressView()
                    } else {
                        Text("Salva Impostazioni")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(isProcessing)
            }
            .navigationTitle("Notifiche")
            .navigationBarItems(trailing: Button("Chiudi") {
                dismiss()
            })
        }
        .onAppear {
            loadNotificationSettings()
        }
    }
    
    private func handleInAppNotificationToggle(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "inAppNotificationsEnabled")
        successMessage = enabled ? "Notifiche in-app attivate" : "Notifiche in-app disattivate"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            successMessage = nil
        }
    }
    
    private func loadNotificationSettings() {
        inAppNotificationsEnabled = UserDefaults.standard.bool(forKey: "inAppNotificationsEnabled")
    }
    
    private func saveNotificationSettings() {
        isProcessing = true
        UserDefaults.standard.set(inAppNotificationsEnabled, forKey: "inAppNotificationsEnabled")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isProcessing = false
            self.successMessage = "Impostazioni salvate con successo!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.successMessage = nil
                self.dismiss()
            }
        }
    }
}

#Preview {
    NotifyView()
}
