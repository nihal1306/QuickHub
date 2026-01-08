import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // Background
            Color(NSColor.windowBackgroundColor)
                .ignoresSafeArea()
            
            // Content
            VStack(spacing: 20) {
                Text("🎉 QuickHub")
                    .font(.system(size: 32, weight: .bold))
                
                Text("Your menu bar app is working!")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                
                Text("Day 1 Complete ✅")
                    .font(.system(size: 14))
                    .padding()
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
                
                Text("Click outside or press ESC to close")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .italic()
            }
            .padding()
        }
        .frame(width: 900, height: 400)
    }
}

#Preview {
    ContentView()
}
