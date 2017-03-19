//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation
import AVFoundation

protocol TextSpeakerDelegate: class {
    func speakerDidStartPlayback(for text: String)
    func speakerDidFinishPlayback(for text: String)
}

class TextSpeaker: NSObject {
    var language: Language
    
    weak var delegate: TextSpeakerDelegate?
    
    let synthesizer = AVSpeechSynthesizer()
    
    var utterance: AVSpeechUtterance?
    
    var isPlaying = false
    var textPlayed = ""
    
    init(language: Language) {
        self.language = language
        
        super.init()
        
        synthesizer.delegate = self
    }
    
    func play(_ text: String) {
        activatePlayer()
        
        utterance = AVSpeechUtterance(string: text)
        utterance?.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance?.voice = AVSpeechSynthesisVoice(language: language.localeIdentifier)
        
        guard let utterance = utterance else { return }
        stop()
        
        synthesizer.speak(utterance)
        isPlaying = true
        textPlayed = text
        
        delegate?.speakerDidStartPlayback(for: text)
    }
    
    func pause() {
        synthesizer.pauseSpeaking(at: .immediate)
        isPlaying = false
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isPlaying = false
    }
    
    func isPlaying(_ text: String) -> Bool {
        return textPlayed == text && isPlaying
    }
    
    func activatePlayer() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
        catch let error as NSError {
            print("Error: Could not set audio category: \(error), \(error.userInfo)")
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch let error as NSError {
            print("Error: Could not setActive to true: \(error), \(error.userInfo)")
        }
    }
}

extension TextSpeaker: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        delegate?.speakerDidFinishPlayback(for: textPlayed)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        delegate?.speakerDidFinishPlayback(for: textPlayed)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        delegate?.speakerDidFinishPlayback(for: textPlayed)
    }
}
