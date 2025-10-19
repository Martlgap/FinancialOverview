import Foundation
import SwiftUI
import Observation

@Observable
class PrivacyModeManager {
    var isPrivacyModeEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isPrivacyModeEnabled, forKey: "privacyModeEnabled")
        }
    }
    
    var isValuesCurrentlyHidden: Bool = false
    private var hideTimer: Timer?
    
    init() {
        self.isPrivacyModeEnabled = UserDefaults.standard.bool(forKey: "privacyModeEnabled")
        // Start with values hidden if privacy mode is enabled
        self.isValuesCurrentlyHidden = isPrivacyModeEnabled
        
        // Listen for app lifecycle notifications
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.hideValuesIfNeeded()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.hideValuesIfNeeded()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        hideTimer?.invalidate()
    }
    
    func toggleValuesVisibility() {
        guard isPrivacyModeEnabled else { return }
        
        isValuesCurrentlyHidden.toggle()
        
        // If values are now visible, start the auto-hide timer
        if !isValuesCurrentlyHidden {
            startAutoHideTimer()
        } else {
            // If values are hidden, cancel the timer
            hideTimer?.invalidate()
        }
    }
    
    func hideValuesIfNeeded() {
        if isPrivacyModeEnabled {
            isValuesCurrentlyHidden = true
            hideTimer?.invalidate()
        }
    }
    
    private func startAutoHideTimer() {
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { _ in
            self.isValuesCurrentlyHidden = true
        }
    }
    
    var shouldBlurValues: Bool {
        return isPrivacyModeEnabled && isValuesCurrentlyHidden
    }
}