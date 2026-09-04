//
//  SoundManager.swift
//  Chroma Orbit
//

import AVFoundation

/// Generates short synthesized tones at runtime (sine-wave blips whose pitch
/// rises with the current combo) so the game ships with zero bundled audio
/// assets. Silently no-ops if the audio session can't be configured, rather
/// than risk crashing a run over sound.
final class SoundManager {
    static let shared = SoundManager()

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let sampleRate: Double = 44_100
    private var isReady = false

    private init() {
        engine.attach(player)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
            isReady = true
        } catch {
            isReady = false
        }
    }

    /// A short blip whose pitch rises with combo level, so a long matching
    /// streak sounds like it's climbing.
    func playCapture(comboLevel: Int) {
        guard isReady else { return }
        let baseFrequency = 440.0
        let steps = Double(min(comboLevel, 12))
        let frequency = baseFrequency * pow(2.0, steps / 12.0)
        play(frequency: frequency, duration: 0.09, amplitude: 0.18)
    }

    /// A low descending tone for a run ending.
    func playShatter() {
        guard isReady else { return }
        play(frequency: 130, duration: 0.35, amplitude: 0.22, descending: true)
    }

    private func play(frequency: Double, duration: Double, amplitude: Double, descending: Bool = false) {
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard
            let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)
        else { return }

        buffer.frameLength = frameCount
        guard let channel = buffer.floatChannelData?[0] else { return }

        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            let progress = t / duration
            let instantFrequency = descending ? frequency * (1.0 - 0.5 * progress) : frequency
            let envelope = sin(.pi * progress) // fades in, then out
            let sample = sin(2.0 * .pi * instantFrequency * t) * amplitude * envelope
            channel[frame] = Float(sample)
        }

        player.scheduleBuffer(buffer, at: nil, options: .interrupts)
        if !player.isPlaying {
            player.play()
        }
    }
}
