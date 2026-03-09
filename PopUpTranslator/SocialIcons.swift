import SwiftUI

struct GitHubIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.primary.opacity(0.35))
            Text("G")
                .font(.system(size: 7.5, weight: .bold, design: .rounded))
                .foregroundStyle(Color(nsColor: .windowBackgroundColor))
        }
    }
}
