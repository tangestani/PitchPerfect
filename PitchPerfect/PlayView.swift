//
//  PlayView.swift
//  PitchPerfect
//
//  Created by Mohammed Tangestani on 5/18/20.
//  Copyright © 2020 Mohammed Tangestani. All rights reserved.
//

import SwiftUI


struct PlayView: View {
    @EnvironmentObject private var audioEngine: AudioEngine
    
    var body: some View {
        VStack {
            Group {
                HStack {
                    Group {
                        Button(action: {
                            self.audioEngine.playSound(rate: 0.5)
                        }) {
                            Image("Slow")
                        }
                        Button(action: {
                            self.audioEngine.playSound(rate: 1.5)
                        }) {
                            Image("Fast")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(PlainButtonStyle())
                    .disabled(self.audioEngine.isPlaying)
                }
                HStack {
                    Group {
                        Button(action: {
                            self.audioEngine.playSound(pitch: -1000)
                        }) {
                            Image("LowPitch")
                        }
                        Button(action: {
                            self.audioEngine.playSound(pitch: 1000)
                        }) {
                            Image("HighPitch")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(PlainButtonStyle())
                    .disabled(self.audioEngine.isPlaying)
                }
                HStack {
                    Group {
                        Button(action: {
                            self.audioEngine.playSound(echo: true)
                        }) {
                            Image("Echo")
                        }
                        Button(action: {
                            self.audioEngine.playSound(reverb: true)
                        }) {
                            Image("Reverb")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(PlainButtonStyle())
                    .disabled(self.audioEngine.isPlaying)
                }
            }
            .frame(maxHeight: .infinity)
            
            Button(action: {
                self.audioEngine.stopPlayback()
            }) {
                Image("Stop")
                    .resizable()
                    .padding(5)
                    .frame(width: 90, height: 90)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!audioEngine.isPlaying)
        }
        .navigationBarTitle("Play")
    }
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PlayView()
        }
    }
}
