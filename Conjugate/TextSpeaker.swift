//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import Foundation
import AVFoundation

class TextSpeaker {
    var locale = Locale(identifier: "de_DE")
    
    let synthesizer = AVSpeechSynthesizer()
    
    var utterance: AVSpeechUtterance?
    
    var isPlaying = false
    var textPlayed = ""
    
    init(locale: Locale) {
        self.locale = locale
    }
    
    func play(_ text: String) {
        utterance = AVSpeechUtterance(string: text)
        utterance?.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance?.voice = AVSpeechSynthesisVoice(language: locale.identifier)
        
        guard let utterance = utterance else { return }
        stop()
        
        synthesizer.speak(utterance)
        isPlaying = true
        textPlayed = text
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
}
