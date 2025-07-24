import SwiftUI

struct GlobalChartView: View {
    @StateObject private var viewModel = ClassificationViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            List(viewModel.tracks) { track in
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: track.sizeMedium)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                    VStack(alignment: .leading) {
                        Text(track.nameTrack)
                            .font(.headline)
                        Text(track.nameArtist)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            BottomMenuView()
        }
        .navigationTitle("Top Global")
        .task {
            await viewModel.fetchGlobalCharts()
        }
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
