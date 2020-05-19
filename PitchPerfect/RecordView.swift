//
//  RecordView.swift
//  PitchPerfect
//
//  Created by Mohammed Tangestani on 5/18/20.
//  Copyright © 2020 Mohammed Tangestani. All rights reserved.
//

import SwiftUI
import Combine

struct RecordView: View {
    @EnvironmentObject private var audioEngine: AudioEngine
    
    var body: some View {
        VStack {
            Button(action: { self.audioEngine.startRecording() }) {
                Image("Record")
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(audioEngine.isRecording)
            
            Text(audioEngine.isRecording ? "Recording..." : "Tap to start recording")
                .padding()
            
            Button(action: {
                self.audioEngine.stopRecording()
            }) {
                Image("Stop")
                    .resizable()
                    .frame(width: 77.5, height: 77.5)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!audioEngine.isRecording)
        }
        .navigationBarTitle("Record")
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView()
            .environmentObject(AudioEngine())
    }
}
