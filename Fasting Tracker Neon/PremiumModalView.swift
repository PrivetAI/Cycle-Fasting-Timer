import SwiftUI

struct PremiumModalView: View {
    @EnvironmentObject var store: FastingStore
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dark background matching app theme
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Lock icon at top
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 100, height: 100)
                            
                            // Custom lock icon shape
                            LockIconShape()
                                .fill(Color(hex: "00E676"))
                                .frame(width: 50, height: 50)
                        }
                        .padding(.top, 40)
                        
                        // Title
                        VStack(spacing: 12) {
                            Text("Premium Feature")
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)
                            
                            Text("Unlock Full Version")
                                .font(.title2)
                                .foregroundColor(Color(hex: "00E676"))
                        }
                        
                        // Features list
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Upgrade to unlock:")
                                .font(.headline)
                                .foregroundColor(Color(hex: "00E676"))
                            
                            PremiumFeatureRow(text: "Advanced analytics view")
                            PremiumFeatureRow(text: "Data export")
                            PremiumFeatureRow(text: "2 additional themes")
                            PremiumFeatureRow(text: "Weight correlation insights")
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        
                        // Purchase button
                        Button(action: {
                            store.isPro = true
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Unlock Full Version")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("One-time purchase • Lifetime access")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Spacer()
                                
                                Text("$2.99")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "00E676"), Color(hex: "00893A")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        
                        // Restore button
                        Button(action: {
                            store.isPro = true
                        }) {
                            Text("Restore Purchases")
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "00E676"))
                        }
                        .padding(.bottom, 40)
                    }
                    .padding()
                }
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Close")
                            .foregroundColor(Color(hex: "00E676"))
                    }
                }
            }
        }
        .onChange(of: store.isPro) { newValue in
            if newValue {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct PremiumFeatureRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: "00E676"))
                .frame(width: 8, height: 8)
            
            Text(text)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

struct LockIconShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        // Lock body
        let bodyRect = CGRect(x: center.x - 15, y: center.y - 5, width: 30, height: 20)
        path.addRoundedRect(in: bodyRect, cornerSize: CGSize(width: 4, height: 4))
        
        // Lock shackle (arc at top)
        path.addArc(center: CGPoint(x: center.x, y: center.y - 5), radius: 10, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        
        return path
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.hasPrefix("#") ? hex.index(after: hex.startIndex) : hex.startIndex
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}
