import SwiftUI

struct TopBarView: View {

    var body: some View {
        HStack(spacing: 24) {
            Image("UserIcon")
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black, lineWidth: 2))

            NavigationLink(destination: ArtistView()) {
                VStack {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.15))
                            .frame(width: 60, height: 60)
                        Image(systemName: "music.mic")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                            .foregroundColor(.black)
                    }
                    .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)

                    Text("Artisti")
                        .font(.caption)
                        .foregroundColor(.black)
                }
            }

            VStack {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.15))
                        .frame(width: 60, height: 60)
                    Image(systemName: "square.stack")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.black)
                }
                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)

                Text("Album")
                    .font(.caption)
                    .foregroundColor(.black)
            }

            Spacer()
        }
        .padding([.top, .horizontal])
        .background(Color.black.opacity(0.1))
    }
}
