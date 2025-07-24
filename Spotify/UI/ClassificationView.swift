import SwiftUI

struct ClassificationView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(spacing: 24) {
                        Text("Seleziona Classifica")
                            .font(.largeTitle.bold())
                            .foregroundColor(.primary)
                            .padding(.top, 32)

                        VStack(spacing: 16) {
                            NavigationLink(destination: Text("Classifica Globale")) {
                                classificationCard(
                                    imageName: "spotify-top-50-global",
                                    title: "Top Global",
                                    subtitle: "Le canzoni più ascoltate al mondo"
                                )
                            }

                            NavigationLink(destination: Text("Classifica Nazionale")) {
                                classificationCard(
                                    imageName: "region_it_default",
                                    title: "Top Country",
                                    subtitle: "Classifica musicale per nazione"
                                )
                            }
                        }
                    }
                }

                BottomMenuView()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Classifiche")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }

    // MARK: - Card View
    @ViewBuilder
    func classificationCard(imageName: String, title: String, subtitle: String) -> some View {
        VStack {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)

            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 250)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
        )
        .padding(.horizontal, 16)
    }
}
