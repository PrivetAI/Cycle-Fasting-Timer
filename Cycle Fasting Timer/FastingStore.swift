import SwiftUI

struct FastingPlan: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let fastingHours: Int
    let eatingHours: Int
    
    static let presets: [FastingPlan] = [
        FastingPlan(id: "16_8", name: "16:8", fastingHours: 16, eatingHours: 8),
        FastingPlan(id: "18_6", name: "18:6", fastingHours: 18, eatingHours: 6),
        FastingPlan(id: "20_4", name: "20:4", fastingHours: 20, eatingHours: 4),
        FastingPlan(id: "23_1", name: "OMAD 23:1", fastingHours: 23, eatingHours: 1),
    ]
}

struct FastingRecord: Codable, Identifiable {
    let id: String
    let startDate: Date
    let endDate: Date?
    let planId: String
    let targetHours: Int
    
    var duration: TimeInterval {
        let end = endDate ?? Date()
        return end.timeIntervalSince(startDate)
    }
    
    var durationHours: Double {
        return duration / 3600.0
    }
    
    var isCompleted: Bool {
        return endDate != nil && duration >= Double(targetHours) * 3600 * 0.8
    }
}

struct WeightEntry: Codable, Identifiable {
    let id: String
    let date: Date
    let weight: Double // in kg or lbs, user's choice
}

class FastingStore: ObservableObject {
    @Published var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "neon_onboarding_done") }
    }
    @Published var selectedPlan: FastingPlan {
        didSet { savePlan() }
    }
    @Published var currentFast: FastingRecord? {
        didSet { saveCurrentFast() }
    }
    @Published var history: [FastingRecord] {
        didSet { saveHistory() }
    }
    @Published var isPro: Bool {
        didSet { UserDefaults.standard.set(isPro, forKey: "neon_is_pro") }
    }
    @Published var customFastingHours: Int {
        didSet { UserDefaults.standard.set(customFastingHours, forKey: "neon_custom_hours") }
    }
    @Published var notes: [String: String] { // fastId -> note text
        didSet { saveNotes() }
    }
    @Published var weightEntries: [WeightEntry] {
        didSet { saveWeightEntries() }
    }
    @Published var selectedThemeIndex: Int {
        didSet { UserDefaults.standard.set(selectedThemeIndex, forKey: "neon_theme_index") }
    }
    
    var isFasting: Bool { currentFast != nil }
    
    var currentProgress: Double {
        guard let fast = currentFast else { return 0 }
        let elapsed = Date().timeIntervalSince(fast.startDate)
        let total = Double(fast.targetHours) * 3600
        return min(elapsed / total, 1.0)
    }
    
    var timeRemaining: TimeInterval {
        guard let fast = currentFast else { return 0 }
        let total = Double(fast.targetHours) * 3600
        let elapsed = Date().timeIntervalSince(fast.startDate)
        return max(total - elapsed, 0)
    }
    
    var timeElapsed: TimeInterval {
        guard let fast = currentFast else { return 0 }
        return Date().timeIntervalSince(fast.startDate)
    }
    
    var currentStreak: Int {
        let cal = Calendar.current
        var streak = 0
        var checkDate = cal.startOfDay(for: Date())
        
        let todayRecords = history.filter { rec in
            guard rec.endDate != nil else { return false }
            return cal.isDate(rec.startDate, inSameDayAs: checkDate)
        }
        
        if todayRecords.isEmpty {
            checkDate = cal.date(byAdding: .day, value: -1, to: checkDate)!
        }
        
        while true {
            let dayRecords = history.filter { rec in
                guard rec.endDate != nil else { return false }
                return cal.isDate(rec.startDate, inSameDayAs: checkDate)
            }
            if dayRecords.isEmpty { break }
            streak += 1
            checkDate = cal.date(byAdding: .day, value: -1, to: checkDate)!
        }
        
        return streak
    }
    
    var averageFastDuration: Double {
        let completed = history.filter { $0.endDate != nil }
        guard !completed.isEmpty else { return 0 }
        let total = completed.reduce(0.0) { $0 + $1.durationHours }
        return total / Double(completed.count)
    }
    
    var totalHoursAllTime: Double {
        return history.filter { $0.endDate != nil }.reduce(0.0) { $0 + $1.durationHours }
    }
    
    var longestFastHours: Double {
        return history.filter { $0.endDate != nil }.map { $0.durationHours }.max() ?? 0
    }
    
    var longestStreak: Int {
        let cal = Calendar.current
        let completed = history.filter { $0.endDate != nil }
            .sorted { $0.startDate < $1.startDate }
        
        guard !completed.isEmpty else { return 0 }
        
        var days = Set<String>()
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        for r in completed {
            days.insert(fmt.string(from: r.startDate))
        }
        
        let sortedDays = days.sorted()
        var maxStreak = 1
        var curStreak = 1
        
        for i in 1..<sortedDays.count {
            if let prev = fmt.date(from: sortedDays[i-1]),
               let cur = fmt.date(from: sortedDays[i]),
               cal.dateComponents([.day], from: prev, to: cur).day == 1 {
                curStreak += 1
                maxStreak = max(maxStreak, curStreak)
            } else {
                curStreak = 1
            }
        }
        
        return maxStreak
    }
    
    var daysFastedThisMonth: Int {
        let cal = Calendar.current
        let now = Date()
        let comps = cal.dateComponents([.year, .month], from: now)
        guard let monthStart = cal.date(from: comps) else { return 0 }
        let completed = history.filter { $0.endDate != nil && $0.startDate >= monthStart }
        let uniqueDays = Set(completed.map { cal.startOfDay(for: $0.startDate) })
        return uniqueDays.count
    }
    
    var mostCommonPlanName: String {
        let completed = history.filter { $0.endDate != nil }
        guard !completed.isEmpty else { return "N/A" }
        var counts: [String: Int] = [:]
        for r in completed {
            counts[r.planId, default: 0] += 1
        }
        let topId = counts.max(by: { $0.value < $1.value })?.key ?? ""
        if let plan = FastingPlan.presets.first(where: { $0.id == topId }) {
            return plan.name
        }
        return topId
    }
    
    var averageEatingWindowHours: Double {
        let completed = history.filter { $0.endDate != nil }
        guard !completed.isEmpty else { return 0 }
        let avgFast = averageFastDuration
        return max(0, 24.0 - avgFast)
    }
    
    var fastsBetterOnWeekdays: Bool {
        let cal = Calendar.current
        let completed = history.filter { $0.endDate != nil }
        var weekdayTotal = 0.0
        var weekdayCount = 0
        var weekendTotal = 0.0
        var weekendCount = 0
        for r in completed {
            let wd = cal.component(.weekday, from: r.startDate)
            if wd == 1 || wd == 7 {
                weekendTotal += r.durationHours
                weekendCount += 1
            } else {
                weekdayTotal += r.durationHours
                weekdayCount += 1
            }
        }
        let wdAvg = weekdayCount > 0 ? weekdayTotal / Double(weekdayCount) : 0
        let weAvg = weekendCount > 0 ? weekendTotal / Double(weekendCount) : 0
        return wdAvg >= weAvg
    }
    
    func totalFastingHours(period: StatsPeriod) -> Double {
        let cal = Calendar.current
        let now = Date()
        let completed = history.filter { $0.endDate != nil }
        
        switch period {
        case .week:
            let weekAgo = cal.date(byAdding: .day, value: -7, to: now)!
            return completed.filter { $0.startDate >= weekAgo }.reduce(0) { $0 + $1.durationHours }
        case .month:
            let monthAgo = cal.date(byAdding: .month, value: -1, to: now)!
            return completed.filter { $0.startDate >= monthAgo }.reduce(0) { $0 + $1.durationHours }
        case .allTime:
            return completed.reduce(0) { $0 + $1.durationHours }
        }
    }
    
    func recordsForDate(_ date: Date) -> [FastingRecord] {
        let cal = Calendar.current
        return history.filter { rec in
            cal.isDate(rec.startDate, inSameDayAs: date)
        }
    }
    
    func last30DaysDurations() -> [(Date, Double)] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        var result: [(Date, Double)] = []
        
        for i in (0..<30).reversed() {
            let day = cal.date(byAdding: .day, value: -i, to: today)!
            let recs = recordsForDate(day).filter { $0.endDate != nil }
            let totalHrs = recs.reduce(0.0) { $0 + $1.durationHours }
            result.append((day, totalHrs))
        }
        return result
    }
    
    func weightForDate(_ date: Date) -> Double? {
        let cal = Calendar.current
        return weightEntries.first(where: { cal.isDate($0.date, inSameDayAs: date) })?.weight
    }
    
    func last30DaysWeights() -> [(Date, Double)] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        var result: [(Date, Double)] = []
        
        for i in (0..<30).reversed() {
            let day = cal.date(byAdding: .day, value: -i, to: today)!
            if let w = weightForDate(day) {
                result.append((day, w))
            }
        }
        return result
    }
    
    func addWeightEntry(weight: Double) {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        // Remove existing entry for today
        weightEntries.removeAll { cal.isDate($0.date, inSameDayAs: today) }
        let entry = WeightEntry(id: UUID().uuidString, date: today, weight: weight)
        weightEntries.append(entry)
        weightEntries.sort { $0.date < $1.date }
    }
    
    func noteForFast(_ fastId: String) -> String {
        return notes[fastId] ?? ""
    }
    
    func setNote(for fastId: String, text: String) {
        if text.isEmpty {
            notes.removeValue(forKey: fastId)
        } else {
            notes[fastId] = text
        }
    }
    
    init() {
        let defaults = UserDefaults.standard
        
        let onboarding = defaults.bool(forKey: "neon_onboarding_done")
        let pro = defaults.bool(forKey: "neon_is_pro")
        var custHrs = defaults.integer(forKey: "neon_custom_hours")
        if custHrs == 0 { custHrs = 14 }
        let themeIdx = defaults.integer(forKey: "neon_theme_index")
        
        let loadedPlan: FastingPlan
        if let data = defaults.data(forKey: "neon_plan"),
           let plan = try? JSONDecoder().decode(FastingPlan.self, from: data) {
            loadedPlan = plan
        } else {
            loadedPlan = FastingPlan.presets[0]
        }
        
        let loadedFast: FastingRecord?
        if let data = defaults.data(forKey: "neon_current_fast"),
           let fast = try? JSONDecoder().decode(FastingRecord.self, from: data) {
            loadedFast = fast
        } else {
            loadedFast = nil
        }
        
        let loadedHistory: [FastingRecord]
        if let data = defaults.data(forKey: "neon_history"),
           let records = try? JSONDecoder().decode([FastingRecord].self, from: data) {
            loadedHistory = records
        } else {
            loadedHistory = []
        }
        
        let loadedNotes: [String: String]
        if let data = defaults.data(forKey: "neon_notes"),
           let n = try? JSONDecoder().decode([String: String].self, from: data) {
            loadedNotes = n
        } else {
            loadedNotes = [:]
        }
        
        let loadedWeights: [WeightEntry]
        if let data = defaults.data(forKey: "neon_weights"),
           let w = try? JSONDecoder().decode([WeightEntry].self, from: data) {
            loadedWeights = w
        } else {
            loadedWeights = []
        }
        
        self.hasCompletedOnboarding = onboarding
        self.isPro = true
        self.customFastingHours = custHrs
        self.selectedPlan = loadedPlan
        self.currentFast = loadedFast
        self.history = loadedHistory
        self.notes = loadedNotes
        self.weightEntries = loadedWeights
        self.selectedThemeIndex = themeIdx
    }
    
    func startFast() {
        let record = FastingRecord(
            id: UUID().uuidString,
            startDate: Date(),
            endDate: nil,
            planId: selectedPlan.id,
            targetHours: selectedPlan.fastingHours
        )
        currentFast = record
    }
    
    func endFast() {
        guard let fast = currentFast else { return }
        let completed = FastingRecord(
            id: fast.id,
            startDate: fast.startDate,
            endDate: Date(),
            planId: fast.planId,
            targetHours: fast.targetHours
        )
        history.insert(completed, at: 0)
        currentFast = nil
    }
    
    func resetAllData() {
        history = []
        currentFast = nil
        notes = [:]
        weightEntries = []
        hasCompletedOnboarding = false
        isPro = true
    }
    
    private func savePlan() {
        if let data = try? JSONEncoder().encode(selectedPlan) {
            UserDefaults.standard.set(data, forKey: "neon_plan")
        }
    }
    
    private func saveCurrentFast() {
        if let fast = currentFast, let data = try? JSONEncoder().encode(fast) {
            UserDefaults.standard.set(data, forKey: "neon_current_fast")
        } else {
            UserDefaults.standard.removeObject(forKey: "neon_current_fast")
        }
    }
    
    private func saveHistory() {
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: "neon_history")
        }
    }
    
    private func saveNotes() {
        if let data = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(data, forKey: "neon_notes")
        }
    }
    
    private func saveWeightEntries() {
        if let data = try? JSONEncoder().encode(weightEntries) {
            UserDefaults.standard.set(data, forKey: "neon_weights")
        }
    }
}

enum StatsPeriod: String, CaseIterable {
    case week = "This Week"
    case month = "This Month"
    case allTime = "All Time"
}
