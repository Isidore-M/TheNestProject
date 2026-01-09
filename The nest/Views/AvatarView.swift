import SwiftUI

struct AvatarView: View {
    let name: String
    let size: CGFloat
    
    // Generates a consistent color based on the name hash
    private var backgroundColor: Color {
        let colors: [Color] = [.purple, .blue, .orange, .pink, .teal, .indigo]
        // Using hashValue to pick a color, abs() to ensure it's positive
        let index = abs(name.hashValue) % colors.count
        return colors[index]
    }
    
    var body: some View {
        ZStack {
            // 1. The Background Circle
            Circle()
                .fill(backgroundColor.opacity(0.15))
            
            // 2. The "Masked" Ant Mascot
            // This treats the image as a stencil to cut out the color
            backgroundColor
                .mask(
                    Image("placeholder") // Ensure this matches your Asset name
                        .resizable()
                        .scaledToFit()
                        .padding(size * 0.22) // White space around the ant
                )
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Dummy Previews
// This section only runs inside Xcode, not on the actual app
#Preview {
    VStack(spacing: 30) {
        Text("Avatar Variations")
            .font(.custom("Poppins-Bold", size: 18))
        
        // 1. Testing different colors based on names
        HStack(spacing: 20) {
            VStack {
                AvatarView(name: "Alex", size: 60)
                Text("Alex")
            }
            VStack {
                AvatarView(name: "Sarah", size: 60)
                Text("Sarah")
            }
            VStack {
                AvatarView(name: "Nest", size: 60)
                Text("Nest")
            }
        }
        
        Divider()
        
        // 2. Testing different sizes (Page 16 List size vs Profile size)
        HStack(alignment: .bottom, spacing: 30) {
            VStack {
                AvatarView(name: "Size Test", size: 40)
                Text("Small")
            }
            VStack {
                AvatarView(name: "Size Test", size: 80)
                Text("Medium")
            }
            VStack {
                AvatarView(name: "Size Test", size: 120)
                Text("Large")
            }
        }
    }
    .font(.custom("Poppins-Regular", size: 12))
    .padding()
}
