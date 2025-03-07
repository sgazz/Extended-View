import CoreMotion
import SwiftUI

class TiltController: ObservableObject {
    // Core Motion manager
    private let motionManager = CMMotionManager()
    
    // Published properties
    @Published var isTiltActive = false
    @Published var isCalibrating = false
    @Published var offset = CGSize.zero
    @Published var tiltAngle = CGSize.zero // За визуелни индикатор
    @Published var sensitivity: Double = 1.0 {
        didSet {
            hapticFeedback.impactOccurred(intensity: 0.3)
        }
    }
    
    // Configuration
    private let calibrationDuration: TimeInterval = 0.5
    private let deadZoneAngle: Double = 5.0
    private let maxTiltAngle: Double = 45.0
    private let inertiaFactor: Double = 0.92 // Фактор успоравања за инерцију
    private let progressiveSensitivityFactor: Double = 1.5 // Фактор за прогресивну осетљивост
    private let baseMovementMultiplier: CGFloat = 5.0 // Базни множилац за померање
    
    // Image properties
    private var imageSize: CGSize = .zero
    private var viewSize: CGSize = .zero
    private var currentScale: CGFloat = 1.0
    
    // Movement state
    private var targetOffset = CGSize.zero
    private var lastUpdateTime: TimeInterval = 0
    private var displayLink: CADisplayLink?
    
    // Calibration data
    private var calibrationStartTime: Date?
    private var calibrationSamples: [(pitch: Double, roll: Double)] = []
    private var referenceAttitude: CMAttitude?
    
    // Movement lock
    @Published var isHorizontalLocked = false {
        didSet {
            hapticFeedback.impactOccurred()
        }
    }
    @Published var isVerticalLocked = false {
        didSet {
            hapticFeedback.impactOccurred()
        }
    }
    
    // Haptic feedback
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    init() {
        setupMotionManager()
        setupDisplayLink()
    }
    
    private func setupMotionManager() {
        // Проверавамо да ли уређај подржава потребне сензоре
        guard motionManager.isDeviceMotionAvailable else {
            print("Device motion is not available")
            return
        }
        
        // Подешавамо учесталост ажурирања (60Hz)
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
    }
    
    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updatePosition))
        displayLink?.add(to: .main, forMode: .common)
        displayLink?.isPaused = true
    }
    
    @objc private func updatePosition() {
        guard isTiltActive else { return }
        
        let maxOffset = getMaxOffset()
        
        withAnimation(.linear(duration: 0.1)) {
            offset = CGSize(
                width: min(max(-maxOffset.width, targetOffset.width), maxOffset.width),
                height: min(max(-maxOffset.height, targetOffset.height), maxOffset.height)
            )
        }
    }
    
    func startTilt() {
        hapticFeedback.impactOccurred()
        isTiltActive = true
        startCalibration()
        displayLink?.isPaused = false
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self,
                  let motion = motion,
                  self.isTiltActive else { return }
            
            if self.isCalibrating {
                self.handleCalibration(motion)
            } else {
                self.handleTilt(motion)
            }
        }
    }
    
    func stopTilt() {
        isTiltActive = false
        isCalibrating = false
        motionManager.stopDeviceMotionUpdates()
        displayLink?.isPaused = true
        hapticFeedback.impactOccurred(intensity: 0.5)
        
        // Заустављамо померање одмах
        withAnimation(.linear(duration: 0.1)) {
            offset = targetOffset
        }
    }
    
    func resetPosition() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            offset = .zero
            targetOffset = .zero
            tiltAngle = .zero
        }
        hapticFeedback.impactOccurred(intensity: 0.7)
    }
    
    private func startCalibration() {
        isCalibrating = true
        calibrationStartTime = Date()
        calibrationSamples.removeAll()
    }
    
    private func handleCalibration(_ motion: CMDeviceMotion) {
        guard let startTime = calibrationStartTime else { return }
        
        // Додајемо нови узорак
        calibrationSamples.append((
            pitch: motion.attitude.pitch,
            roll: motion.attitude.roll
        ))
        
        // Проверавамо да ли је калибрација завршена
        if Date().timeIntervalSince(startTime) >= calibrationDuration {
            finishCalibration(motion)
        }
    }
    
    private func finishCalibration(_ motion: CMDeviceMotion) {
        // Чувамо референтни став
        referenceAttitude = motion.attitude
        
        isCalibrating = false
        hapticFeedback.impactOccurred(intensity: 0.7)
    }
    
    private func handleTilt(_ motion: CMDeviceMotion) {
        guard let referenceAttitude = referenceAttitude else { return }
        
        let currentAttitude = motion.attitude
        currentAttitude.multiply(byInverseOf: referenceAttitude)
        
        var xTilt = currentAttitude.pitch * 180.0 / .pi
        var yTilt = currentAttitude.roll * 180.0 / .pi
        
        // Ажурирамо углове за визуелни индикатор
        tiltAngle = CGSize(width: yTilt, height: xTilt)
        
        // Примењујемо мртву зону
        xTilt = abs(xTilt) < deadZoneAngle ? 0 : xTilt
        yTilt = abs(yTilt) < deadZoneAngle ? 0 : yTilt
        
        // Ограничавамо максимални нагиб
        xTilt = min(max(xTilt, -maxTiltAngle), maxTiltAngle)
        yTilt = min(max(yTilt, -maxTiltAngle), maxTiltAngle)
        
        // Примењујемо прогресивну осетљивост
        let xFactor = pow(abs(xTilt) / maxTiltAngle, progressiveSensitivityFactor)
        let yFactor = pow(abs(yTilt) / maxTiltAngle, progressiveSensitivityFactor)
        
        xTilt *= xFactor
        yTilt *= yFactor
        
        // Примењујемо закључавање оса
        if isHorizontalLocked { yTilt = 0 }
        if isVerticalLocked { xTilt = 0 }
        
        let maxOffset = getMaxOffset()
        let movementMultiplier = baseMovementMultiplier * currentScale
        
        // Постављамо циљни офсет са ограничењима
        targetOffset = CGSize(
            width: isHorizontalLocked ? targetOffset.width : min(max(-maxOffset.width, CGFloat(yTilt) * movementMultiplier * CGFloat(sensitivity)), maxOffset.width),
            height: isVerticalLocked ? targetOffset.height : min(max(-maxOffset.height, CGFloat(xTilt) * movementMultiplier * CGFloat(sensitivity)), maxOffset.height)
        )
    }
    
    func increaseSensitivity() {
        sensitivity = min(sensitivity * 1.2, 3.0)
    }
    
    func decreaseSensitivity() {
        sensitivity = max(sensitivity / 1.2, 0.5)
    }
    
    deinit {
        motionManager.stopDeviceMotionUpdates()
        displayLink?.invalidate()
    }
    
    // Нова функција за ажурирање димензија
    func updateDimensions(imageSize: CGSize, viewSize: CGSize, scale: CGFloat) {
        self.imageSize = imageSize
        self.viewSize = viewSize
        self.currentScale = scale
    }
    
    private func getMaxOffset() -> CGSize {
        let scaledImageWidth = imageSize.width * currentScale
        let scaledImageHeight = imageSize.height * currentScale
        
        let maxHorizontalOffset = max(0, (scaledImageWidth - viewSize.width) / 2)
        let maxVerticalOffset = max(0, (scaledImageHeight - viewSize.height) / 2)
        
        return CGSize(width: maxHorizontalOffset, height: maxVerticalOffset)
    }
} 