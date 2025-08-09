//
//  MusicPlayerView.swift
//  Spotify
//
//  Created by Alex Frisoni on 07/08/25.
//
import SwiftUI
import Foundation

struct MusicPlayerView: View {
    let trackList: [TrackAlbumDetail]
    let albumCoverURL: String
    @EnvironmentObject var playlistPlayerVM: PlaylistPlayerViewModel
    @ObservedObject var albumDetailVM: AlbumDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isLiked: Bool = false
    
    private var currentTrack: TrackAlbumDetail {
        playlistPlayerVM.currentTrack!
    }
    
    private var currentIndex: Int {
        playlistPlayerVM.currentIndex
    }
    
    private var hasPrevious: Bool {
        playlistPlayerVM.hasPrevious
    }
    
    private var hasNext: Bool {
        playlistPlayerVM.hasNext
    }
    
    private var isCurrentlyPlaying: Bool {
        playlistPlayerVM.currentlyPlayingTrackID == currentTrack.id && playlistPlayerVM.isPlaying
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black.opacity(0.8), .gray.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.down")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("In riproduzione")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal)
                
                Spacer()
                
                albumCoverView
                    .frame(maxWidth: 300, maxHeight: 300)
                    .shadow(radius: 20)
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text(currentTrack.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    
                    Text(currentTrack.artistName)
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 20) {
                    HStack {
                        Spacer()
                        Button(action: toggleLike) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(isLiked ? .red : .white)
                        }
                        Spacer()
                    }
                    
                    HStack(spacing: 50) {
                        Button(action: previousTrack) {
                            Image(systemName: "backward.fill")
                                .font(.title)
                                .foregroundColor(hasPrevious ? .white : .gray)
                        }
                        .disabled(!hasPrevious)
                        
                        Button(action: togglePlayPause) {
                            Image(systemName: isCurrentlyPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 70))
                                .foregroundColor(.green)
                        }
                        
                        Button(action: nextTrack) {
                            Image(systemName: "forward.fill")
                                .font(.title)
                                .foregroundColor(hasNext ? .white : .gray)
                        }
                        .disabled(!hasNext)
                    }
                    
                    if !currentTrack.preview.isEmpty {
                        Text("Preview - 30 secondi")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            checkIfLiked()
            setupInitialState()
        }
        .onChange(of: currentIndex) {
            checkIfLiked()
        }
    }
    
    @ViewBuilder
    private var albumCoverView: some View {
        let coverString = currentTrack.cover_medium ?? albumCoverURL
        if let url = URL(string: coverString) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.3)
                    .overlay {
                        Image(systemName: "music.note")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.5))
                    }
            }
            .frame(width: 300, height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        } else {
            Image("playlistcover")
                .resizable()
                .scaledToFill()
                .frame(width: 300, height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
    
    private func setupInitialState() {
        playlistPlayerVM.setPlaylist(trackList)
    }
    
    private func togglePlayPause() {
        playlistPlayerVM.togglePlayPause()
                if playlistPlayerVM.isPlaying {
            albumDetailVM.stopPlayback()
        }
    }
    
    private func previousTrack() {
        guard hasPrevious else { return }
        playlistPlayerVM.playTrack(at: currentIndex - 1)
    }
    
    private func nextTrack() {
        guard hasNext else { return }
        playlistPlayerVM.playTrack(at: currentIndex + 1)
    }
    
    private func toggleLike() {
        isLiked.toggle()
        albumDetailVM.toggleLike(for: currentTrack)
    }
    
    private func checkIfLiked() {
        isLiked = albumDetailVM.likedTracks.contains(currentTrack.id)
    }
}

struct PlayableTrackRow: View {
    let track: TrackAlbumDetail
    let trackList: [TrackAlbumDetail]
    let currentIndex: Int
    let albumCoverURL: String
    @ObservedObject var albumDetailVM: AlbumDetailViewModel
    @EnvironmentObject var playlistPlayerVM: PlaylistPlayerViewModel
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var showingMusicPlayer = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: URL(string: track.cover_medium ?? albumCoverURL)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 6) {
                Text(track.title)
                    .font(.headline)
                Text(track.artistName)
                    .font(.caption)

                HStack(spacing: 12) {
                    if !track.preview.isEmpty {
                        Button(action: {

                            if playlistPlayerVM.currentlyPlayingTrackID == track.id {
                                playlistPlayerVM.togglePlayPause()
                            } else {
                                albumDetailVM.stopPlayback()
                                playlistPlayerVM.setCurrentTrack(at: currentIndex)
                                playlistPlayerVM.playTrack(at: currentIndex)
                            }
                        }) {
                            Image(systemName: (playlistPlayerVM.currentlyPlayingTrackID == track.id && playlistPlayerVM.isPlaying) ? "pause.circle.fill" : "play.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.green)
                        }
                    }

                    Button(action: {
                        let wasLiked = albumDetailVM.likedTracks.contains(track.id)
                        albumDetailVM.toggleLike(for: track)
                        showLikeNotification(for: track, wasLiked: wasLiked)
                    }) {
                        Image(systemName: albumDetailVM.likedTracks.contains(track.id) ? "heart.fill" : "heart")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onTapGesture {
            playlistPlayerVM.setCurrentTrack(at: currentIndex)
            showingMusicPlayer = true
        }
        .fullScreenCover(isPresented: $showingMusicPlayer) {
            MusicPlayerView(
                trackList: trackList,
                albumCoverURL: albumCoverURL,
                albumDetailVM: albumDetailVM
            )
            .environmentObject(playlistPlayerVM)

        }
    }
    
    private func showLikeNotification(for track: TrackAlbumDetail, wasLiked: Bool) {
        let inAppEnabled = UserDefaults.standard.bool(forKey: "inAppNotificationsEnabled")
        guard inAppEnabled else { return }
        
        let message = wasLiked
            ? "\"\(track.title)\" rimosso dai preferiti"
            : "\"\(track.title)\" aggiunto ai preferiti"
        
        notificationManager.show(message: message)
    }
}
