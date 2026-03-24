import SwiftUI

struct CycleLoadingScreen: View {
    @State private var pulse = false
    @State private var ringRotation: Double = 0
    
    var body: some View {
        ZStack {
            Color(red: 10/255, green: 10/255, blue: 10/255)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 28) {
                ZStack {
                    Circle()
                        .stroke(Color(red: 42/255, green: 42/255, blue: 42/255), lineWidth: 4)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: 0.3)
                        .stroke(Color(red: 0, green: 230/255, blue: 118/255), lineWidth: 4)
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(ringRotation))
                    
                    CycleClockIcon()
                        .fill(Color(red: 0, green: 230/255, blue: 118/255))
                        .frame(width: 36, height: 36)
                        .scaleEffect(pulse ? 1.1 : 0.9)
                }
                
                Text("Cycle: Fasting Timer")
                    .font(.title2).fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            pulse = true
            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                ringRotation = 360
            }
            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

struct CycleClockIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let cx = rect.midX
        let cy = rect.midY
        let r = min(rect.width, rect.height) / 2
        p.addEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
        // hour hand
        p.move(to: CGPoint(x: cx, y: cy))
        p.addLine(to: CGPoint(x: cx, y: cy - r * 0.5))
        // minute hand
        p.move(to: CGPoint(x: cx, y: cy))
        p.addLine(to: CGPoint(x: cx + r * 0.4, y: cy))
        return p
    }
}
