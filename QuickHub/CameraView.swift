import SwiftUI
import AVFoundation

struct CameraView: NSViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true
        
        previewLayer.frame = view.bounds
        view.layer?.addSublayer(previewLayer)
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        // Update frame when view size changes
        DispatchQueue.main.async {
            previewLayer.frame = nsView.bounds
        }
    }
}
