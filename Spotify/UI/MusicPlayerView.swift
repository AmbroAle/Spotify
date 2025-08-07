//
//  MusicPlayerView.swift
//  Spotify
//
//  Created by Alex Frisoni on 07/08/25.
//


import SwiftUI
import Foundation

struct MusicPlayerView: View {
    let track: TrackAlbumDetail
    let trackList: [TrackAlbumDetail]
    let currentIndex: Int
    @ObservedObject var playlistPlayerVM: PlaylistPlayerViewModel
    @ObservedObject var albumDetailVM: AlbumDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isLiked: Bool = false
    
    // Computed properties per la navigazione
    private var hasPrevious: Bool { currentIndex > 0 }
    private var hasNext: Bool { currentIndex < trackList.count - 1 }
    private var currentTrack: TrackAlbumDetail { trackList[currentIndex] }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.black.opacity(0.8), .gray.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header con dismiss button
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
                
                // Album cover
                albumCoverView
                    .frame(maxWidth: 300, maxHeight: 300)
                    .shadow(radius: 20)
                
                Spacer()
                
                // Track info
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
                
                // Controls
                VStack(spacing: 20) {
                    // Like button
                    HStack {
                        Spacer()
                        Button(action: toggleLike) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(isLiked ? .red : .white)
                        }
                        Spacer()
                    }
                    
                    // Main controls
                    HStack(spacing: 50) {
                        // Previous button
                        Button(action: previousTrack) {
                            Image(systemName: "backward.fill")
                                .font(.title)
                                .foregroundColor(hasPrevious ? .white : .gray)
                        }
                        .disabled(!hasPrevious)
                        
                        // Play/Pause button
                        Button(action: togglePlayPause) {
                            Image(systemName: isCurrentlyPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 70))
                                .foregroundColor(.green)
                        }
                        
                        // Next button
                        Button(action: nextTrack) {
                            Image(systemName: "forward.fill")
                                .font(.title)
                                .foregroundColor(hasNext ? .white : .gray)
                        }
                        .disabled(!hasNext)
                    }
                    
                    // Progress indicator (se disponibile)
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
        .onChange(of: currentIndex) { _ in
            checkIfLiked()
        }
    }
    
    @ViewBuilder
    private var albumCoverView: some View {
        if let coverString = currentTrack.cover_medium,
           let url = URL(string: coverString) {
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
    
    private var isCurrentlyPlaying: Bool {
        playlistPlayerVM.currentlyPlayingTrackID == currentTrack.id ||
        albumDetailVM.currentlyPlayingTrackID == currentTrack.id
    }
    
    private func setupInitialState() {
        // Configura la playlist nel PlaylistPlayerViewModel se non è già configurata
        playlistPlayerVM.setPlaylist(trackList)
    }
    
    private func togglePlayPause() {
        if isCurrentlyPlaying {
            // Se sta suonando, metti in pausa
            playlistPlayerVM.togglePlayPause()
            albumDetailVM.stopPlayback()
        } else {
            // Se non sta suonando, avvia la riproduzione
            albumDetailVM.stopPlayback()
            playlistPlayerVM.stopPlayback()
            playlistPlayerVM.playTrack(at: currentIndex)
        }
    }
    
    private func previousTrack() {
        guard hasPrevious else { return }
        let newIndex = currentIndex - 1
        playlistPlayerVM.playTrack(at: newIndex)
    }
    
    private func nextTrack() {
        guard hasNext else { return }
        let newIndex = currentIndex + 1
        playlistPlayerVM.playTrack(at: newIndex)
    }
    
    private func toggleLike() {
        isLiked.toggle()
        albumDetailVM.toggleLike(for: currentTrack)
    }
    
    private func checkIfLiked() {
        isLiked = albumDetailVM.likedTracks.contains(currentTrack.id)
    }
}

// MARK: - Estensione per TrackRowView
extension TrackRowView {
    // Aggiungi questo modificatore per aprire il player
    func onTapGesture(trackList: [TrackAlbumDetail], currentIndex: Int, playlistPlayerVM: PlaylistPlayerViewModel) -> some View {
        self.onTapGesture {
            // Qui potresti aggiungere la navigazione al MusicPlayerView
            // Oppure usare un sheet
        }
    }
}

// MARK: - Vista per l'integrazione nelle liste
struct PlayableTrackRow: View {
    let track: TrackAlbumDetail
    let trackList: [TrackAlbumDetail]
    let currentIndex: Int
    let albumCoverURL: String
    @ObservedObject var albumDetailVM: AlbumDetailViewModel
    @ObservedObject var playlistPlayerVM: PlaylistPlayerViewModel
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var showingMusicPlayer = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Album cover
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
                            let isNewTrack = albumDetailVM.currentlyPlayingTrackID != track.id
                            if isNewTrack {
                                albumDetailVM.saveRecentTrack(track)
                            }
                            albumDetailVM.playOrPause(track: track)
                        }) {
                            Image(systemName: albumDetailVM.currentlyPlayingTrackID == track.id ? "pause.circle.fill" : "play.circle.fill")
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
        .contentShape(Rectangle()) // Rende tutta l'area tappabile
        .onTapGesture {
            showingMusicPlayer = true
        }
        .fullScreenCover(isPresented: $showingMusicPlayer) {
            MusicPlayerView(
                track: track,
                trackList: trackList,
                currentIndex: currentIndex,
                playlistPlayerVM: playlistPlayerVM,
                albumDetailVM: albumDetailVM
            )
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