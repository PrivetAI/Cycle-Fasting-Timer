import SwiftUI

struct StatsView: View {
    @EnvironmentObject var store: FastingStore
    @State private var selectedPeriod: StatsPeriod = .week
    
    var body: some View {
        ZStack {
            NeonColors.base.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 16) {
                    Spacer().frame(height: 20)
                    
                    Text("Statistics")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(NeonColors.textWhite)
                    
                    // FREE: Basic stats
                    basicStatsSection
                    
                    // FREE: Insights cards
                    insightsSection
                    
                    // FREE: Motivational stats
                    motivationalSection
                    
                    // FREE: 30-day chart
                    chartCard
                    
                    // PREMIUM: Advanced analytics
                    if store.isPro {
                        advancedAnalyticsSection
                        
                        // Export button
                        exportButton
                        
                    } else {
                        premiumUpsell
                    }
                    
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Free: Basic Stats
    
    private var basicStatsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                metricCard(label: "Avg Duration", value: String(format: "%.1fh", store.averageFastDuration))
                metricCard(label: "Total Hours", value: String(format: "%.0fh", store.totalHoursAllTime))
            }
            HStack(spacing: 12) {
                metricCard(label: "Longest Streak", value: "\(store.longestStreak)d")
                metricCard(label: "Longest Fast", value: String(format: "%.1fh", store.longestFastHours))
            }
        }
    }
    
    // MARK: - Free: Insights
    
    private var insightsSection: some View {
        VStack(spacing: 10) {
            Text("Insights")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(NeonColors.textWhite)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            insightCard(
                text: store.fastsBetterOnWeekdays ? "You fast best on weekdays" : "You fast best on weekends"
            )
            
            insightCard(
                text: String(format: "Average eating window: %.1fh", store.averageEatingWindowHours)
            )
            
            insightCard(
                text: "Most common plan: \(store.mostCommonPlanName)"
            )
        }
        .padding(16)
        .background(NeonColors.card)
        .cornerRadius(14)
    }
    
    private func insightCard(text: String) -> some View {
        HStack(spacing: 10) {
            StarShape()
                .fill(NeonColors.primary.opacity(0.6))
                .frame(width: 14, height: 14)
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(NeonColors.textWhite)
            Spacer()
        }
        .padding(10)
        .background(NeonColors.cardLight)
        .cornerRadius(10)
    }
    
    // MARK: - Free: Motivational
    
    private var motivationalSection: some View {
        HStack(spacing: 12) {
            VStack(spacing: 6) {
                Text("\(store.daysFastedThisMonth)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(NeonColors.primary)
                Text("Days fasted\nthis month")
                    .font(.system(size: 11))
                    .foregroundColor(NeonColors.dimText)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(NeonColors.card)
            .cornerRadius(14)
            
            VStack(spacing: 6) {
                Text(String(format: "%.1fh", store.longestFastHours))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(NeonColors.primary)
                Text("Longest fast\never")
                    .font(.system(size: 11))
                    .foregroundColor(NeonColors.dimText)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(NeonColors.card)
            .cornerRadius(14)
        }
    }
    
    // MARK: - Free: Chart
    
    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last 30 Days")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(NeonColors.textWhite)
            
            NeonLineChart(data: store.last30DaysDurations())
                .frame(height: 150)
        }
        .padding(16)
        .background(NeonColors.card)
        .cornerRadius(14)
    }
    
    // MARK: - Premium: Advanced Analytics
    
    private var advancedAnalyticsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Advanced Analytics")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(NeonColors.textWhite)
                Spacer()
                Text("PRO")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(NeonColors.base)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(NeonColors.primary)
                    .cornerRadius(6)
            }
            
            // Period selector
            HStack(spacing: 0) {
                ForEach(StatsPeriod.allCases, id: \.rawValue) { period in
                    Button(action: { selectedPeriod = period }) {
                        Text(period.rawValue)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(selectedPeriod == period ? NeonColors.base : NeonColors.dimText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(selectedPeriod == period ? NeonColors.primary : Color.clear)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(4)
            .background(NeonColors.cardLight)
            .cornerRadius(10)
            
            // Total hours for period
            VStack(alignment: .leading, spacing: 8) {
                Text("Total Fasting Hours")
                    .font(.system(size: 14))
                    .foregroundColor(NeonColors.dimText)
                Text(String(format: "%.1f hours", store.totalFastingHours(period: selectedPeriod)))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(NeonColors.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(NeonColors.cardLight)
            .cornerRadius(10)
            
            // Detailed breakdown
            VStack(alignment: .leading, spacing: 8) {
                Text("Breakdown")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(NeonColors.dimText)
                
                detailRow("Fasts completed", "\(store.history.filter { $0.endDate != nil }.count)")
                detailRow("Avg eating window", String(format: "%.1fh", store.averageEatingWindowHours))
                detailRow("Success rate", successRate)
                detailRow("Best plan", store.mostCommonPlanName)
            }
            .padding(12)
            .background(NeonColors.cardLight)
            .cornerRadius(10)
            
            // Correlation card
            VStack(alignment: .leading, spacing: 8) {
                Text("Correlations")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(NeonColors.dimText)
                
                Text(store.fastsBetterOnWeekdays ? "Weekday fasts average longer than weekends" : "Weekend fasts average longer than weekdays")
                    .font(.system(size: 13))
                    .foregroundColor(NeonColors.textWhite)
                
                if !store.weightEntries.isEmpty {
                    Text("Weight data: \(store.weightEntries.count) entries logged")
                        .font(.system(size: 13))
                        .foregroundColor(NeonColors.textWhite)
                }
            }
            .padding(12)
            .background(NeonColors.cardLight)
            .cornerRadius(10)
        }
        .padding(16)
        .background(NeonColors.card)
        .cornerRadius(14)
    }
    
    private var successRate: String {
        let completed = store.history.filter { $0.endDate != nil }
        guard !completed.isEmpty else { return "0%" }
        let successful = completed.filter { $0.isCompleted }
        let rate = Double(successful.count) / Double(completed.count) * 100
        return String(format: "%.0f%%", rate)
    }
    
    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(NeonColors.dimText)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(NeonColors.textWhite)
        }
    }
    
    private var exportButton: some View {
        Button(action: {}) {
            HStack(spacing: 8) {
                ExportIconShape()
                    .stroke(NeonColors.base, lineWidth: 2)
                    .frame(width: 18, height: 18)
                Text("Export Data")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(NeonColors.base)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(NeonColors.primary)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Premium Upsell
    
    private var premiumUpsell: some View {
        VStack(spacing: 16) {
            HStack {
                LockIconShape()
                    .fill(NeonColors.dimText)
                    .frame(width: 24, height: 24)
                Text("Premium Features")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(NeonColors.textWhite)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                featureRow("Advanced analytics and breakdowns")
                featureRow("Export all data to text file")
                featureRow("2 additional UI themes")
            }
            
            Button(action: { store.isPro = true }) {
                Text("Unlock Premium - $2.99")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(NeonColors.base)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(NeonColors.primary)
                    .cornerRadius(12)
            }
            
            Text("One-time purchase")
                .font(.system(size: 11))
                .foregroundColor(NeonColors.dimText)
        }
        .padding(16)
        .background(NeonColors.card)
        .cornerRadius(14)
    }
    
    private func featureRow(_ text: String) -> some View {
        HStack(spacing: 10) {
            CheckmarkShape()
                .stroke(NeonColors.primary, lineWidth: 2)
                .frame(width: 14, height: 14)
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(NeonColors.textWhite)
        }
    }
    
    private func metricCard(label: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(NeonColors.primary)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(NeonColors.dimText)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(NeonColors.card)
        .cornerRadius(14)
    }
}

struct NeonLineChart: View {
    let data: [(Date, Double)]
    
    var body: some View {
        GeometryReader { geo in
            let maxVal = max(data.map(\.1).max() ?? 1, 1)
            let w = geo.size.width
            let h = geo.size.height
            let stepX = w / CGFloat(max(data.count - 1, 1))
            
            ZStack(alignment: .bottomLeading) {
                ForEach(0..<4, id: \.self) { i in
                    let y = h * CGFloat(i) / 3
                    Path { p in
                        p.move(to: CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: w, y: y))
                    }
                    .stroke(NeonColors.cardLight, lineWidth: 0.5)
                }
                
                Path { p in
                    for (i, item) in data.enumerated() {
                        let x = CGFloat(i) * stepX
                        let y = h - (CGFloat(item.1 / maxVal) * h)
                        if i == 0 { p.move(to: CGPoint(x: x, y: y)) }
                        else { p.addLine(to: CGPoint(x: x, y: y)) }
                    }
                }
                .stroke(NeonColors.primary, lineWidth: 2)
                
                ForEach(Array(data.enumerated()), id: \.offset) { i, item in
                    if item.1 > 0 {
                        Circle()
                            .fill(NeonColors.primary)
                            .frame(width: 4, height: 4)
                            .position(
                                x: CGFloat(i) * stepX,
                                y: h - (CGFloat(item.1 / maxVal) * h)
                            )
                    }
                }
            }
        }
    }
}
