import SwiftUI

struct StatsView: View {
    @EnvironmentObject var store: FastingStore
    @State private var selectedPeriod: StatsPeriod = .week
    
    var body: some View {
        ZStack {
            CycleColors.base.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 16) {
                    Spacer().frame(height: 20)
                    
                    Text("Statistics")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(CycleColors.textWhite)
                    
                    // FREE: Basic stats
                    basicStatsSection
                    
                    // FREE: Insights cards
                    insightsSection
                    
                    // FREE: Motivational stats
                    motivationalSection
                    
                    // FREE: 30-day chart
                    chartCard
                    
                    // Advanced analytics
                    advancedAnalyticsSection
                    
                    // Export button
                    exportButton
                    
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
                .foregroundColor(CycleColors.textWhite)
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
        .background(CycleColors.card)
        .cornerRadius(14)
    }
    
    private func insightCard(text: String) -> some View {
        HStack(spacing: 10) {
            StarShape()
                .fill(CycleColors.primary.opacity(0.6))
                .frame(width: 14, height: 14)
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(CycleColors.textWhite)
            Spacer()
        }
        .padding(10)
        .background(CycleColors.cardLight)
        .cornerRadius(10)
    }
    
    // MARK: - Free: Motivational
    
    private var motivationalSection: some View {
        HStack(spacing: 12) {
            VStack(spacing: 6) {
                Text("\(store.daysFastedThisMonth)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(CycleColors.primary)
                Text("Days fasted\nthis month")
                    .font(.system(size: 11))
                    .foregroundColor(CycleColors.dimText)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(CycleColors.card)
            .cornerRadius(14)
            
            VStack(spacing: 6) {
                Text(String(format: "%.1fh", store.longestFastHours))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(CycleColors.primary)
                Text("Longest fast\never")
                    .font(.system(size: 11))
                    .foregroundColor(CycleColors.dimText)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(CycleColors.card)
            .cornerRadius(14)
        }
    }
    
    // MARK: - Free: Chart
    
    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last 30 Days")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(CycleColors.textWhite)
            
            CycleLineChart(data: store.last30DaysDurations())
                .frame(height: 150)
        }
        .padding(16)
        .background(CycleColors.card)
        .cornerRadius(14)
    }
    
    // MARK: - Premium: Advanced Analytics
    
    private var advancedAnalyticsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Advanced Analytics")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(CycleColors.textWhite)
                Spacer()
            }
            
            // Period selector
            HStack(spacing: 0) {
                ForEach(StatsPeriod.allCases, id: \.rawValue) { period in
                    Button(action: { selectedPeriod = period }) {
                        Text(period.rawValue)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(selectedPeriod == period ? CycleColors.base : CycleColors.dimText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(selectedPeriod == period ? CycleColors.primary : Color.clear)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(4)
            .background(CycleColors.cardLight)
            .cornerRadius(10)
            
            // Total hours for period
            VStack(alignment: .leading, spacing: 8) {
                Text("Total Fasting Hours")
                    .font(.system(size: 14))
                    .foregroundColor(CycleColors.dimText)
                Text(String(format: "%.1f hours", store.totalFastingHours(period: selectedPeriod)))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(CycleColors.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(CycleColors.cardLight)
            .cornerRadius(10)
            
            // Detailed breakdown
            VStack(alignment: .leading, spacing: 8) {
                Text("Breakdown")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(CycleColors.dimText)
                
                detailRow("Fasts completed", "\(store.history.filter { $0.endDate != nil }.count)")
                detailRow("Avg eating window", String(format: "%.1fh", store.averageEatingWindowHours))
                detailRow("Success rate", successRate)
                detailRow("Best plan", store.mostCommonPlanName)
            }
            .padding(12)
            .background(CycleColors.cardLight)
            .cornerRadius(10)
            
            // Correlation card
            VStack(alignment: .leading, spacing: 8) {
                Text("Correlations")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(CycleColors.dimText)
                
                Text(store.fastsBetterOnWeekdays ? "Weekday fasts average longer than weekends" : "Weekend fasts average longer than weekdays")
                    .font(.system(size: 13))
                    .foregroundColor(CycleColors.textWhite)
                
                if !store.weightEntries.isEmpty {
                    Text("Weight data: \(store.weightEntries.count) entries logged")
                        .font(.system(size: 13))
                        .foregroundColor(CycleColors.textWhite)
                }
            }
            .padding(12)
            .background(CycleColors.cardLight)
            .cornerRadius(10)
        }
        .padding(16)
        .background(CycleColors.card)
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
                .foregroundColor(CycleColors.dimText)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(CycleColors.textWhite)
        }
    }
    
    private var exportButton: some View {
        Button(action: {}) {
            HStack(spacing: 8) {
                ExportIconShape()
                    .stroke(CycleColors.base, lineWidth: 2)
                    .frame(width: 18, height: 18)
                Text("Export Data")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(CycleColors.base)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(CycleColors.primary)
            .cornerRadius(12)
        }
    }
    
    private func metricCard(label: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(CycleColors.primary)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(CycleColors.dimText)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(CycleColors.card)
        .cornerRadius(14)
    }
}

struct CycleLineChart: View {
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
                    .stroke(CycleColors.cardLight, lineWidth: 0.5)
                }
                
                Path { p in
                    for (i, item) in data.enumerated() {
                        let x = CGFloat(i) * stepX
                        let y = h - (CGFloat(item.1 / maxVal) * h)
                        if i == 0 { p.move(to: CGPoint(x: x, y: y)) }
                        else { p.addLine(to: CGPoint(x: x, y: y)) }
                    }
                }
                .stroke(CycleColors.primary, lineWidth: 2)
                
                ForEach(Array(data.enumerated()), id: \.offset) { i, item in
                    if item.1 > 0 {
                        Circle()
                            .fill(CycleColors.primary)
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
