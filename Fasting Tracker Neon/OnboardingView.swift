import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var store: FastingStore
    @State private var selectedIndex: Int = 0
    @State private var customHours: String = "14"
    @State private var showCustom = false
    
    private let plans = FastingPlan.presets
    
    var body: some View {
        ZStack {
            NeonColors.base.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                Spacer().frame(height: 60)
                
                // Title
                Text("Choose Your Plan")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(NeonColors.textWhite)
                    .padding(.bottom, 8)
                
                Text("Select a fasting schedule to get started")
                    .font(.system(size: 15))
                    .foregroundColor(NeonColors.dimText)
                    .padding(.bottom, 32)
                
                // Plan cards
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(plans.enumerated()), id: \.element.id) { index, plan in
                            planCard(plan: plan, index: index)
                        }
                        
                        // Custom option
                        customPlanCard()
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // Continue button
                Button(action: confirmSelection) {
                    Text("Continue")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(NeonColors.base)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(NeonColors.primary)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func planCard(plan: FastingPlan, index: Int) -> some View {
        let isSelected = !showCustom && selectedIndex == index
        return Button(action: {
            showCustom = false
            selectedIndex = index
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(NeonColors.textWhite)
                    Text("\(plan.fastingHours)h fasting / \(plan.eatingHours)h eating")
                        .font(.system(size: 13))
                        .foregroundColor(NeonColors.dimText)
                }
                Spacer()
                Circle()
                    .fill(isSelected ? NeonColors.primary : NeonColors.cardLight)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Group {
                            if isSelected {
                                CheckmarkShape()
                                    .stroke(NeonColors.base, lineWidth: 2)
                                    .frame(width: 14, height: 14)
                            }
                        }
                    )
            }
            .padding(16)
            .background(isSelected ? NeonColors.card.opacity(0.9) : NeonColors.card.opacity(0.5))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? NeonColors.primary : Color.clear, lineWidth: 1.5)
            )
        }
    }
    
    private func customPlanCard() -> some View {
        Button(action: { showCustom = true }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Custom")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(NeonColors.textWhite)
                    
                    if showCustom {
                        HStack(spacing: 8) {
                            Text("Fasting hours:")
                                .font(.system(size: 13))
                                .foregroundColor(NeonColors.dimText)
                            TextField("", text: $customHours)
                                .keyboardType(.numberPad)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(NeonColors.primary)
                                .frame(width: 40)
                                .multilineTextAlignment(.center)
                                .padding(4)
                                .background(NeonColors.cardLight)
                                .cornerRadius(6)
                        }
                    } else {
                        Text("Set your own schedule")
                            .font(.system(size: 13))
                            .foregroundColor(NeonColors.dimText)
                    }
                }
                Spacer()
                Circle()
                    .fill(showCustom ? NeonColors.primary : NeonColors.cardLight)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Group {
                            if showCustom {
                                CheckmarkShape()
                                    .stroke(NeonColors.base, lineWidth: 2)
                                    .frame(width: 14, height: 14)
                            }
                        }
                    )
            }
            .padding(16)
            .background(showCustom ? NeonColors.card.opacity(0.9) : NeonColors.card.opacity(0.5))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(showCustom ? NeonColors.primary : Color.clear, lineWidth: 1.5)
            )
        }
    }
    
    private func confirmSelection() {
        if showCustom {
            let hrs = Int(customHours) ?? 14
            let clamped = max(1, min(23, hrs))
            let plan = FastingPlan(id: "custom", name: "Custom \(clamped):\(24 - clamped)", fastingHours: clamped, eatingHours: 24 - clamped)
            store.selectedPlan = plan
            store.customFastingHours = clamped
        } else {
            store.selectedPlan = plans[selectedIndex]
        }
        store.hasCompletedOnboarding = true
    }
}
