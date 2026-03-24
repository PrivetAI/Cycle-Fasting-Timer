import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: FastingStore
    @State private var showWebView = false
    @State private var showResetConfirm = false
    @State private var showPlanPicker = false
    
    var body: some View {
        ZStack {
            CycleColors.base.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 16) {
                    Spacer().frame(height: 20)
                    
                    Text("Settings")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(CycleColors.textWhite)
                    
                    // Current Plan
                    settingsCard(title: "Current Plan") {
                        Button(action: { showPlanPicker = true }) {
                            HStack {
                                Text(store.selectedPlan.name)
                                    .font(.system(size: 15))
                                    .foregroundColor(CycleColors.textWhite)
                                Spacer()
                                ArrowRightShape()
                                    .stroke(CycleColors.dimText, lineWidth: 2)
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
                                    .foregroundColor(CycleColors.textWhite)
                                Spacer()
                                ArrowRightShape()
                                    .stroke(CycleColors.dimText, lineWidth: 2)
                                    .frame(width: 14, height: 14)
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
                        Text("Cycle: Fasting Timer")
                            .font(.system(size: 13))
                            .foregroundColor(CycleColors.dimText)
                        Text("Version 1.0")
                            .font(.system(size: 12))
                            .foregroundColor(CycleColors.dimText.opacity(0.6))
                    }
                    .padding(.top, 20)
                    
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .sheet(isPresented: $showWebView) {
            ZStack {
                CycleColors.base.edgesIgnoringSafeArea(.all)
                VStack(spacing: 0) {
                    HStack {
                        Button(action: { showWebView = false }) {
                            Text("Close")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(CycleColors.primary)
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(CycleColors.card)
                    
                    CycleWebPanel(urlString: "https://cyclefastingtimer.org/click.php")
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
    }
    
    private func settingsCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(CycleColors.dimText)
                .textCase(.uppercase)
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CycleColors.card)
        .cornerRadius(14)
    }
}
