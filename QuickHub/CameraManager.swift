import AVFoundation
import AppKit

class CameraManager: NSObject, ObservableObject {
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var isCameraOn = false
    @Published var isMirrored = true
    @Published var hasCamera = true
    @Published var errorMessage: String?
    
    private var captureSession: AVCaptureSession?
    private var videoDevice: AVCaptureDevice?
    
    override init() {
        super.init()
        checkCameraAvailability()
    }
    
    // MARK: - Check Camera
    func checkCameraAvailability() {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .external],
            mediaType: .video,
            position: .unspecified
        )
        
        hasCamera = !discoverySession.devices.isEmpty
        
        if !hasCamera {
            errorMessage = "No camera detected"
        }
    }
    
    // MARK: - Request Permission
    func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.errorMessage = "Camera access denied. Enable in System Settings > Privacy & Security > Camera"
                completion(false)
            }
        @unknown default:
            completion(false)
        }
    }
    
    // MARK: - Start Camera
    func startCamera() {
        requestCameraPermission { [weak self] granted in
            guard granted else { return }
            self?.setupCaptureSession()
        }
    }
    
    private func setupCaptureSession() {
        let session = AVCaptureSession()
        session.sessionPreset = .medium
        
        // Get default video device
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) ??
                                AVCaptureDevice.default(for: .video) else {
            errorMessage = "Could not access camera"
            return
        }
        
        self.videoDevice = videoDevice
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            }
            
            // Create preview layer
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            
            DispatchQueue.main.async {
                self.previewLayer = previewLayer
                self.captureSession = session
                
                // Start session on background thread
                DispatchQueue.global(qos: .userInitiated).async {
                    session.startRunning()
                    
                    DispatchQueue.main.async {
                        self.isCameraOn = true
                        self.updateMirrorMode()
                    }
                }
            }
            
        } catch {
            errorMessage = "Failed to setup camera: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Stop Camera
    func stopCamera() {
        captureSession?.stopRunning()
        previewLayer = nil
        isCameraOn = false
    }
    
    // MARK: - Toggle Camera
    func toggleCamera() {
        if isCameraOn {
            stopCamera()
        } else {
            startCamera()
        }
    }
    
    // MARK: - Toggle Mirror
    func toggleMirror() {
        isMirrored.toggle()
        updateMirrorMode()
    }
    
    private func updateMirrorMode() {
        guard let connection = previewLayer?.connection else { return }
        
        if connection.isVideoMirroringSupported {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = isMirrored
        }
    }
    
    // MARK: - Cleanup
    deinit {
        stopCamera()
    }
}
