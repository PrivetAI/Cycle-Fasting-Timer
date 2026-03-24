import SwiftUI

struct TimerView: View {
    @EnvironmentObject var store: FastingStore
    @State private var timer: Timer? = nil
    @State private var displayProgress: Double = 0
    @State private var displayTimeRemaining: TimeInterval = 0
    @State private var showPlanPicker = false
    
    var body: some View {
        ZStack {
            CycleColors.base.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 20)
                    
                    Text("Cycle: Fasting Timer")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(CycleColors.textWhite)
                    
                    // Plan selector
                    planSelector
                    
                    // Timer ring
                    timerRing
                        .frame(width: 260, height: 260)
                    
                    // Status
                    Text(store.isFasting ? "Fasting" : "Eating Window")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(store.isFasting ? CycleColors.primary : CycleColors.dimText)
                    
                    // Action button
                    actionButton
                    
                    Spacer().frame(height: 40)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear { startDisplayTimer() }
        .onDisappear { timer?.invalidate() }
    }
    
    private var planSelector: some View {
        Button(action: { showPlanPicker.toggle() }) {
            HStack {
                Text(store.selectedPlan.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(CycleColors.textWhite)
                
                ArrowRightShape()
                    .stroke(CycleColors.dimText, lineWidth: 2)
                    .frame(width: 12, height: 12)
                    .rotationEffect(.degrees(showPlanPicker ? -90 : 90))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(CycleColors.card)
            .cornerRadius(10)
        }
        .sheet(isPresented: $showPlanPicker) {
            PlanPickerSheet()
                .environmentObject(store)
        }
    }
    
    private var timerRing: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(CycleColors.card, lineWidth: 12)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: CGFloat(displayProgress))
                .stroke(
                    CycleColors.primary,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.5), value: displayProgress)
            
            // Center text
            VStack(spacing: 6) {
                if store.isFasting {
                    Text(formatTime(displayTimeRemaining))
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                        .foregroundColor(CycleColors.textWhite)
                    
                    Text("remaining")
                        .font(.system(size: 13))
                        .foregroundColor(CycleColors.dimText)
                } else {
                    Text("00:00:00")
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                        .foregroundColor(CycleColors.dimText)
                    
                    Text("tap to start")
                        .font(.system(size: 13))
                        .foregroundColor(CycleColors.dimText)
                }
            }
        }
    }
    
    private var actionButton: some View {
        Button(action: {
            if store.isFasting {
                store.endFast()
            } else {
                store.startFast()
            }
        }) {
            Text(store.isFasting ? "End Fast" : "Start Fast")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(store.isFasting ? CycleColors.textWhite : CycleColors.base)
                .frame(width: 200, height: 52)
                .background(store.isFasting ? Color.red.opacity(0.8) : CycleColors.primary)
                .cornerRadius(26)
        }
    }
    
    private func startDisplayTimer() {
        updateDisplay()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            updateDisplay()
        }
    }
    
    private func updateDisplay() {
        displayProgress = store.currentProgress
        displayTimeRemaining = store.timeRemaining
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let total = Int(interval)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}

struct PlanPickerSheet: View {
    @EnvironmentObject var store: FastingStore
    @Environment(\.presentationMode) var presentationMode
    @State private var customHours: String = "14"
    
    private let allPlans = FastingPlan.presets
    
    var body: some View {
        ZStack {
            CycleColors.base.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                HStack {
                    Text("Select Plan")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(CycleColors.textWhite)
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("Done")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(CycleColors.primary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(allPlans) { plan in
                            Button(action: {
                                store.selectedPlan = plan
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack {
                                    Text(plan.name)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(CycleColors.textWhite)
                                    Spacer()
                                    Text("\(plan.fastingHours)h / \(plan.eatingHours)h")
                                        .font(.system(size: 14))
                                        .foregroundColor(CycleColors.dimText)
                                    if store.selectedPlan.id == plan.id {
                                        CheckmarkShape()
                                            .stroke(CycleColors.primary, lineWidth: 2)
                                            .frame(width: 16, height: 16)
                                    }
                                }
                                .padding(14)
                                .background(CycleColors.card)
                                .cornerRadius(10)
                            }
                        }
                        
                        // Custom
                        VStack(spacing: 8) {
                            HStack {
                                Text("Custom")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(CycleColors.textWhite)
                                Spacer()
                                TextField("", text: $customHours)
                                    .keyboardType(.numberPad)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(CycleColors.primary)
                                    .frame(width: 40)
                                    .multilineTextAlignment(.center)
                                    .padding(4)
                                    .background(CycleColors.cardLight)
                                    .cornerRadius(6)
                                Text("hours")
                                    .font(.system(size: 14))
                                    .foregroundColor(CycleColors.dimText)
                            }
                            
                            Button(action: {
                                let hrs = max(1, min(23, Int(customHours) ?? 14))
                                let plan = FastingPlan(id: "custom", name: "Custom \(hrs):\(24 - hrs)", fastingHours: hrs, eatingHours: 24 - hrs)
                                store.selectedPlan = plan
                                store.customFastingHours = hrs
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("Set Custom")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(CycleColors.base)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 36)
                                    .background(CycleColors.primary)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(14)
                        .background(CycleColors.card)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}
