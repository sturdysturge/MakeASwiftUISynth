//
//  DataModel.swift
//  Make a SwiftUI Synth
//
//  Created by Rob Sturgeon on 28/04/2020.
//  Copyright © 2020 Rob Sturgeon. All rights reserved.
//

import AudioKit

final class DataModel: ObservableObject {
    
    ///The single shared instance of this class that we will use
    static let shared = DataModel()
    ///The oscillator that we will set the frequency and amplitude of
    private let oscillator = AKOscillator()
    ///A second oscillator that will be mixed with the first one
    private let oscillator2 = AKOscillator()
    ///Whether sound is enabled
    @Published var sound = false
    ///Whether slider movements are being played
    @Published var recording = false
    ///Whether slider movements are being played
    @Published var playing = false
    
    ///When the amplitude variable changes, update the oscillator accordingly
    @Published var amplitude = 0.5 {
        didSet {setAmplitudeAndFrequency()}
    }
    
    ///When the frequency variable changes, update the oscillator accordingly
    @Published var frequency = 0.5 {
        didSet {setAmplitudeAndFrequency()}
    }
    
    ///A timer used for recording and playing
    private var timer = Timer()
    ///The recorded amplitude values
    private var recordedAmplitudes = [Double]()
    ///The recorded frequency values
    private var recordedFrequencies = [Double]()
    
    ///Example recording
    private let demoRecordedFrequencies = [1500.0, 1259.0, 959.0, 877.0, 938.6, 1129.0, 936.0, 568.0, 620.0, 754.0, 839.6, 629.0, 375.0, 547.0, 658.0, 492.0, 320.0, 509.0, 471.6, 207.0, 191.0, 209.0, 134.0, 153.0, 153.0, 136.0, 0.0, 0.0, 33.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    private let demoRecordedAmplitudes = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.6, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.6, 1.0, 1.0, 1.0, 2.0, 1.0, 1.6, 1.0, 1.0, 1.0, 0.0, 0.6, 0.0, 0.0, 0.0]
    
    ///Index for amplitude when looping through array during playback
    private var ampIndex = 0
    
    ///Index for frequency when looping through array during playback
    private var freqIndex = 0
    
    //Start by setting the output to the oscillators and start AudioKit
    init() {
        AudioKit.output = AKMixer(oscillator, oscillator2)
        do {
            try AudioKit.start()
        }
        catch {
            assertionFailure("Failed to start AudioKit")
        }
    }
    
    ///Change the oscillator to match variables
    func setAmplitudeAndFrequency() {
        oscillator.amplitude = amplitude
        oscillator.frequency = frequency
    }
    
    ///Start or stop the timer that records the frequency and amplitude slider positions
    func record() {
        playing = false
        recording.toggle()
        timer.invalidate()
        if recording {
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {
                _ in self.recordSliders()
            })
        }
    }
    
    /// Start or stop th timer that moves the sliders according to what was recorded (every 0.1 seconds)
    func play() {
        recording = false
        playing.toggle()
        timer.invalidate()
        if playing {
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in  self.moveSliders() })
        }
    }
    
    ///Record the position of the sliders (every 0.1 seconds)
    func recordSliders() {
        recordedAmplitudes.append(amplitude)
        recordedFrequencies.append(frequency)
    }
    
    ///Move the sliders when playing (every 0.1 seconds)
    func moveSliders() {
        //End playing if arrays are empty
        if recordedAmplitudes.isEmpty && recordedFrequencies.isEmpty {
            playing = false
        }
        if playing {
            if !recordedAmplitudes.isEmpty {
                amplitude = recordedAmplitudes[ampIndex]
                ampIndex += 1
                if ampIndex == recordedAmplitudes.count {
                    ampIndex = 0
                }
                
            }
            if !recordedFrequencies.isEmpty {
                frequency = recordedFrequencies[freqIndex]
                freqIndex += 1
                if freqIndex == recordedFrequencies.count {
                    freqIndex = 0
                }
            }
        setAmplitudeAndFrequency()
        }
    }
    
    ///Delete all recorded frequencies and amplitudes
    func delete() {
        recordedAmplitudes.removeAll()
        recordedFrequencies.removeAll()
    }
    
    ///Load the demo arrays
    func loadDemo() {
        recordedAmplitudes = demoRecordedAmplitudes
        recordedFrequencies = demoRecordedFrequencies
    }
    
    ///Mute or unmute the sound output
    func toggleSound() {
        if oscillator.isPlaying {
            oscillator.stop()
        } else {
            oscillator.amplitude = amplitude
            oscillator.frequency = frequency
            oscillator.start()
        }
        sound = oscillator.isPlaying
    }
}
