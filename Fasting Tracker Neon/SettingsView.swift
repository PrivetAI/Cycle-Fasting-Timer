import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: FastingStore
    @State private var showWebView = false
    @State private var showResetConfirm = false
    @State private var showPlanPicker = false
    @State private var showingPremiumModal = false
    
    var body: some View {
        ZStack {
            NeonColors.base.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 16) {
                    Spacer().frame(height: 20)
                    
                    Text("Settings")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(NeonColors.textWhite)
                    
                    // Current Plan
                    settingsCard(title: "Current Plan") {
                        Button(action: { showPlanPicker = true }) {
                            HStack {
                                Text(store.selectedPlan.name)
                                    .font(.system(size: 15))
                                    .foregroundColor(NeonColors.textWhite)
                                Spacer()
                                ArrowRightShape()
                                    .stroke(NeonColors.dimText, lineWidth: 2)
                                    .frame(width: 14, height: 14)
                            }
                        }
                    }
                    
                    // Privacy
                    settingsCard(title: "Privacy Policy") {
                        Button(action: { showWebView = true }) {
                            HStack {
                                Text("View Privacy Policy")
                                    .font(.system(size: 15))
                                    .foregroundColor(NeonColors.textWhite)
                                Spacer()
                                ArrowRightShape()
                                    .stroke(NeonColors.dimText, lineWidth: 2)
                                    .frame(width: 14, height: 14)
                            }
                        }
                    }
                    
                    // Pro status
                    settingsCard(title: "Pro Status") {
                        HStack {
                            Text(store.isPro ? "Active" : "Free")
                                .font(.system(size: 15))
                                .foregroundColor(store.isPro ? NeonColors.primary : NeonColors.dimText)
                            Spacer()
                            if !store.isPro {
                                Button(action: { showingPremiumModal = true }) {
                                    Text("Upgrade")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(NeonColors.base)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .background(NeonColors.primary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    // Reset
                    settingsCard(title: "Data") {
                        Button(action: { showResetConfirm = true }) {
                            HStack {
                                Text("Reset All Data")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.red)
                                Spacer()
                            }
                        }
                    }
                    
                    // App info
                    VStack(spacing: 4) {
                        Text("Fasting Tracker Neon")
                            .font(.system(size: 13))
                            .foregroundColor(NeonColors.dimText)
                        Text("Version 1.0")
                            .font(.system(size: 12))
                            .foregroundColor(NeonColors.dimText.opacity(0.6))
                    }
                    .padding(.top, 20)
                    
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .sheet(isPresented: $showWebView) {
            ZStack {
                NeonColors.base.edgesIgnoringSafeArea(.all)
                VStack(spacing: 0) {
                    HStack {
                        Button(action: { showWebView = false }) {
                            Text("Close")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(NeonColors.primary)
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(NeonColors.card)
                    
                    NeonWebPanel(urlString: "https://example.com")
                }
            }
        }
        .sheet(isPresented: $showPlanPicker) {
            PlanPickerSheet()
                .environmentObject(store)
        }
        .alert(isPresented: $showResetConfirm) {
            Alert(
                title: Text("Reset All Data"),
                message: Text("This will delete all fasting history and settings. This cannot be undone."),
                primaryButton: .destructive(Text("Reset")) {
                    store.resetAllData()
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showingPremiumModal) {
            PremiumModalView()
                .environmentObject(store)
        }
    }
    
    private func settingsCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(NeonColors.dimText)
                .textCase(.uppercase)
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NeonColors.card)
        .cornerRadius(14)
    }
}
