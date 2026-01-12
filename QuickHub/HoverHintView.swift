import SwiftUI

struct HoverHintView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 32))
                .foregroundColor(.blue)
            
            Text("QuickHub")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            Text("Drop files here")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 140, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.windowBackgroundColor))
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.5), lineWidth: 2)
        )
    }
}
