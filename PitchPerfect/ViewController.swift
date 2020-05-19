//
//  ViewController.swift
//  PitchPerfect
//
//  Created by Mohammed Tangestani on 5/18/20.
//  Copyright © 2020 Mohammed Tangestani. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

class ViewController: UINavigationController {
    
    private let audioEngine = AudioEngine()
    private var isRecordingSub: Cancellable?

    private var isRecording: Bool = false {
        didSet {
            if oldValue == true && !isRecording {
                transitionToPlayView()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let recordView = RecordView().environmentObject(audioEngine)
        pushViewController(UIHostingController(rootView: recordView), animated: false)
        navigationBar.prefersLargeTitles = true
        
        isRecordingSub = audioEngine.$isRecording
            .assign(to: \.isRecording, on: self)
    }
    
    func transitionToPlayView() {
        let playView = PlayView().environmentObject(audioEngine)
        pushViewController(UIHostingController(rootView: playView), animated: true)
    }
}
