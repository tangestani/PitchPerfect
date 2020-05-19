//
//  AudioEngine.swift
//  PitchPerfect
//
//  Created by Mohammed Tangestani on 5/16/20.
//  Copyright © 2020 Mohammed Tangestani. All rights reserved.
//

import Foundation
import AVFoundation

class AudioEngine: NSObject, ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private let recordingURL = FileManager.default.temporaryDirectory.appendingPathComponent("recording.wav")
    private let session = AVAudioSession.sharedInstance()
    
    @Published public private(set) var isRecording = false
    @Published public private(set) var isPlaying = false
    
    func startRecording() {
        do {
            audioRecorder = try AVAudioRecorder(url: recordingURL, settings: [:])
            audioRecorder?.delegate = self
            try session.setActive(true)
        } catch {
            print("Could not start recording: \(error)")
            return
        }
        
        audioRecorder?.prepareToRecord()
        audioRecorder?.record()
        isRecording = true
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        try? session.setActive(false)
    }
    
    @objc
    func stopPlayback() {
        playerNode.stop()
        stopTimer?.invalidate()
        avAudioEngine.reset()
        avAudioEngine.stop()
        isPlaying = false  // delegate doesn't get called if user manually stops playback
        try? session.setActive(false)
    }
    
    private var audioFile: AVAudioFile?
    lazy private var playerNode = AVAudioPlayerNode()
    lazy private var timePitchNode = AVAudioUnitTimePitch()
    lazy private var echoNode = AVAudioUnitDistortion()
    lazy private var reverbNode = AVAudioUnitReverb()
    lazy private var avAudioEngine: AVAudioEngine = {
        let engine = AVAudioEngine()
        engine.attach(self.playerNode)
        engine.attach(self.timePitchNode)
        engine.attach(self.echoNode)
        engine.attach(self.reverbNode)
        return engine
    }()
    var stopTimer: Timer?
    
    func playSound(rate: Float = 1.0, pitch: Float = 0, echo: Bool = false, reverb: Bool = false) {
        do {
            audioFile = try AVAudioFile(forReading: recordingURL)
        } catch {
            print("Unable to open audio file for playback: \(error)")
        }
        guard let audioFile = audioFile else { return }
        
        timePitchNode.rate = min(max(rate, 1/32), 32)
        timePitchNode.pitch = pitch
        echoNode.loadFactoryPreset(.multiEcho1)
        reverbNode.loadFactoryPreset(.cathedral)
        reverbNode.wetDryMix = 50
        
        
        avAudioEngine.connect(playerNode, to: timePitchNode, format: audioFile.processingFormat)
        avAudioEngine.connect(timePitchNode, to: avAudioEngine.outputNode, format: audioFile.processingFormat)
        if echo {
            avAudioEngine.connect(timePitchNode, to: echoNode, format: audioFile.processingFormat)
            avAudioEngine.connect(echoNode, to: reverb ? reverbNode : avAudioEngine.outputNode, format: audioFile.processingFormat)
        }
        if reverb {
            avAudioEngine.connect(echo ? echoNode : timePitchNode, to: reverbNode, format: audioFile.processingFormat)
            avAudioEngine.connect(reverbNode, to: avAudioEngine.outputNode, format: audioFile.processingFormat)
        }
        
        playerNode.scheduleFile(audioFile, at: nil) { [unowned self] in
            var delayInSeconds: Double = 0.0
            if let lastRenderTime = self.playerNode.lastRenderTime,
                let playerTime = self.playerNode.playerTime(forNodeTime: lastRenderTime) {
                delayInSeconds = Double(audioFile.length - playerTime.sampleTime) / audioFile.processingFormat.sampleRate / Double(self.timePitchNode.rate)
            }
            self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(self.stopPlayback), userInfo: nil, repeats: false)
            RunLoop.main.add(self.stopTimer!, forMode: .default)
        }
        
        avAudioEngine.prepare()
        do {
            try avAudioEngine.start()
        } catch {
            print("Error occured while starting AVAudioEngine: \(error)")
        }
        try? session.setActive(true)
        playerNode.play()
        isPlaying = true
    }
}

extension AudioEngine: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        isRecording = false
    }
}
