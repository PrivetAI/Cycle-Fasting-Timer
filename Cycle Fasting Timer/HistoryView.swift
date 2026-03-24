import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var store: FastingStore
    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date? = nil
    @State private var editingNoteForFastId: String? = nil
    @State private var noteText: String = ""
    @State private var filterStartDate: Date? = nil
    @State private var filterEndDate: Date? = nil
    @State private var showDateFilter = false
    
    private let calendar = Calendar.current
    private let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f
    }()
    private let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f
    }()
    private let timeFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()
    private let dateFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f
    }()
    
    var body: some View {
        ZStack {
            CycleColors.base.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    Spacer().frame(height: 20)
                    
                    Text("History")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(CycleColors.textWhite)
                    
                    // Streak card
                    streakCard
                    
                    // Calendar
                    calendarView
                    
                    // Selected date details
                    if let date = selectedDate {
                        dateDetailCard(date: date)
                    }
                    
                    // Date filter toggle
                    filterSection
                    
                    // Monthly summary
                    monthlySummaryCard
                    
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 20)
            }
            
            // Note editor overlay
            if editingNoteForFastId != nil {
                noteEditorOverlay
            }
        }
    }
    
    private var streakCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Streak")
                    .font(.system(size: 13))
                    .foregroundColor(CycleColors.dimText)
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(store.currentStreak)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(CycleColors.primary)
                    Text("days")
                        .font(.system(size: 15))
                        .foregroundColor(CycleColors.dimText)
                }
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(CycleColors.primary.opacity(0.15))
                    .frame(width: 50, height: 50)
                StarShape()
                    .fill(CycleColors.primary)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(16)
        .background(CycleColors.card)
        .cornerRadius(14)
    }
    
    private var calendarView: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: { changeMonth(-1) }) {
                    ArrowLeftShape()
                        .stroke(CycleColors.textWhite, lineWidth: 2)
                        .frame(width: 20, height: 20)
                }
                Spacer()
                Text(monthFormatter.string(from: currentMonth))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(CycleColors.textWhite)
                Spacer()
                Button(action: { changeMonth(1) }) {
                    ArrowRightShape()
                        .stroke(CycleColors.textWhite, lineWidth: 2)
                        .frame(width: 20, height: 20)
                }
            }
            
            let dayNames = ["S", "M", "T", "W", "T", "F", "S"]
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { i in
                    Text(dayNames[i])
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(CycleColors.dimText)
                        .frame(maxWidth: .infinity)
                }
            }
            
            let days = daysInMonth()
            let columns = 7
            let rows = (days.count + columns - 1) / columns
            
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<columns, id: \.self) { col in
                        let index = row * columns + col
                        if index < days.count, let day = days[index] {
                            dayCell(date: day)
                        } else {
                            Color.clear.frame(maxWidth: .infinity, minHeight: 40)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(CycleColors.card)
        .cornerRadius(14)
    }
    
    private func dayCell(date: Date) -> some View {
        let records = store.recordsForDate(date)
        let hasCompleted = records.contains(where: { $0.endDate != nil })
        let isSelected = selectedDate != nil && calendar.isDate(date, inSameDayAs: selectedDate!)
        let isToday = calendar.isDateInToday(date)
        
        return Button(action: { selectedDate = date }) {
            VStack(spacing: 2) {
                Text(dayFormatter.string(from: date))
                    .font(.system(size: 14, weight: isToday ? .bold : .regular))
                    .foregroundColor(isSelected ? CycleColors.base : (isToday ? CycleColors.primary : CycleColors.textWhite))
                
                Circle()
                    .fill(hasCompleted ? CycleColors.primary : Color.clear)
                    .frame(width: 6, height: 6)
            }
            .frame(maxWidth: .infinity, minHeight: 40)
            .background(isSelected ? CycleColors.primary : Color.clear)
            .cornerRadius(8)
        }
    }
    
    private func dateDetailCard(date: Date) -> some View {
        let records = store.recordsForDate(date).filter { $0.endDate != nil }
        let dayWeight = store.weightForDate(date)
        
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(dateFmt.string(from: date))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(CycleColors.textWhite)
                Spacer()
                if let w = dayWeight {
                    Text(String(format: "%.1f kg", w))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1.0))
                }
            }
            
            if records.isEmpty {
                Text("No completed fasts")
                    .font(.system(size: 14))
                    .foregroundColor(CycleColors.dimText)
            } else {
                ForEach(records) { record in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(String(format: "%.1f hours", record.durationHours))
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(CycleColors.primary)
                                
                                HStack(spacing: 4) {
                                    Text(timeFmt.string(from: record.startDate))
                                        .font(.system(size: 12))
                                        .foregroundColor(CycleColors.dimText)
                                    Text("-")
                                        .font(.system(size: 12))
                                        .foregroundColor(CycleColors.dimText)
                                    if let end = record.endDate {
                                        Text(timeFmt.string(from: end))
                                            .font(.system(size: 12))
                                            .foregroundColor(CycleColors.dimText)
                                    }
                                }
                            }
                            Spacer()
                            
                            // Edit note button
                            Button(action: {
                                editingNoteForFastId = record.id
                                noteText = store.noteForFast(record.id)
                            }) {
                                PencilIconShape()
                                    .fill(CycleColors.dimText)
                                    .frame(width: 18, height: 18)
                            }
                        }
                        
                        // Note preview
                        let note = store.noteForFast(record.id)
                        if !note.isEmpty {
                            Text(note)
                                .font(.system(size: 12))
                                .foregroundColor(CycleColors.dimText)
                                .lineLimit(2)
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(CycleColors.cardLight)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    if record.id != records.last?.id {
                        Divider().background(CycleColors.cardLight)
                    }
                }
            }
        }
        .padding(16)
        .background(CycleColors.card)
        .cornerRadius(14)
    }
    
    private var filterSection: some View {
        VStack(spacing: 10) {
            Button(action: { showDateFilter.toggle() }) {
                HStack {
                    Text("Filter by Date Range")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(CycleColors.textWhite)
                    Spacer()
                    ArrowRightShape()
                        .stroke(CycleColors.dimText, lineWidth: 2)
                        .frame(width: 12, height: 12)
                        .rotationEffect(.degrees(showDateFilter ? 90 : 0))
                }
                .padding(14)
                .background(CycleColors.card)
                .cornerRadius(12)
            }
            
            if showDateFilter {
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("From")
                                .font(.system(size: 11))
                                .foregroundColor(CycleColors.dimText)
                            DatePicker("", selection: Binding(
                                get: { filterStartDate ?? calendar.date(byAdding: .month, value: -1, to: Date())! },
                                set: { filterStartDate = $0 }
                            ), displayedComponents: .date)
                            .labelsHidden()
                            .colorScheme(.dark)
                            .accentColor(CycleColors.primary)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("To")
                                .font(.system(size: 11))
                                .foregroundColor(CycleColors.dimText)
                            DatePicker("", selection: Binding(
                                get: { filterEndDate ?? Date() },
                                set: { filterEndDate = $0 }
                            ), displayedComponents: .date)
                            .labelsHidden()
                            .colorScheme(.dark)
                            .accentColor(CycleColors.primary)
                        }
                    }
                    
                    let filtered = filteredRecords
                    if !filtered.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(filtered.count) fasts found")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(CycleColors.primary)
                            
                            let totalH = filtered.reduce(0.0) { $0 + $1.durationHours }
                            Text(String(format: "Total: %.1f hours", totalH))
                                .font(.system(size: 12))
                                .foregroundColor(CycleColors.dimText)
                        }
                    } else {
                        Text("No fasts in this range")
                            .font(.system(size: 13))
                            .foregroundColor(CycleColors.dimText)
                    }
                    
                    Button(action: {
                        filterStartDate = nil
                        filterEndDate = nil
                        showDateFilter = false
                    }) {
                        Text("Clear Filter")
                            .font(.system(size: 13))
                            .foregroundColor(CycleColors.primary)
                    }
                }
                .padding(14)
                .background(CycleColors.card)
                .cornerRadius(12)
            }
        }
    }
    
    private var filteredRecords: [FastingRecord] {
        let start = filterStartDate ?? calendar.date(byAdding: .month, value: -1, to: Date())!
        let end = filterEndDate ?? Date()
        return store.history.filter { $0.endDate != nil && $0.startDate >= start && $0.startDate <= end }
    }
    
    private var monthlySummaryCard: some View {
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)!
        let monthRecords = store.history.filter { $0.endDate != nil && $0.startDate >= monthStart && $0.startDate < monthEnd }
        let totalHours = monthRecords.reduce(0.0) { $0 + $1.durationHours }
        let fastDays = Set(monthRecords.map { calendar.startOfDay(for: $0.startDate) }).count
        
        return VStack(alignment: .leading, spacing: 10) {
            Text("Monthly Summary")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(CycleColors.textWhite)
            
            HStack {
                summaryItem(label: "Fasts", value: "\(monthRecords.count)")
                Spacer()
                summaryItem(label: "Days", value: "\(fastDays)")
                Spacer()
                summaryItem(label: "Hours", value: String(format: "%.0f", totalHours))
            }
        }
        .padding(16)
        .background(CycleColors.card)
        .cornerRadius(14)
    }
    
    private func summaryItem(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(CycleColors.primary)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(CycleColors.dimText)
        }
    }
    
    // MARK: - Note Editor Overlay
    
    private var noteEditorOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture { saveAndCloseNote() }
            
            VStack(spacing: 16) {
                HStack {
                    Text("Fast Note")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(CycleColors.textWhite)
                    Spacer()
                    Button(action: { saveAndCloseNote() }) {
                        Text("Save")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(CycleColors.primary)
                    }
                }
                
                Text("How did this fast go? How did you feel?")
                    .font(.system(size: 13))
                    .foregroundColor(CycleColors.dimText)
                
                ZStack(alignment: .topLeading) {
                    if noteText.isEmpty {
                        Text("Write your note here...")
                            .font(.system(size: 14))
                            .foregroundColor(CycleColors.dimText.opacity(0.5))
                            .padding(12)
                    }
                    TextEditor(text: $noteText)
                        .font(.system(size: 14))
                        .foregroundColor(CycleColors.textWhite)
                        .padding(8)
                        .frame(minHeight: 120)
                        .onAppear {
                            UITextView.appearance().backgroundColor = .clear
                        }
                        .background(Color.clear)
                }
                .background(CycleColors.cardLight)
                .cornerRadius(10)
                
                if !noteText.isEmpty {
                    Button(action: {
                        noteText = ""
                    }) {
                        Text("Clear Note")
                            .font(.system(size: 13))
                            .foregroundColor(Color.red.opacity(0.8))
                    }
                }
            }
            .padding(20)
            .background(CycleColors.card)
            .cornerRadius(16)
            .padding(.horizontal, 24)
        }
    }
    
    private func saveAndCloseNote() {
        if let fastId = editingNoteForFastId {
            store.setNote(for: fastId, text: noteText)
        }
        editingNoteForFastId = nil
        noteText = ""
    }
    
    private func changeMonth(_ delta: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: delta, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func daysInMonth() -> [Date?] {
        let comps = calendar.dateComponents([.year, .month], from: currentMonth)
        guard let monthStart = calendar.date(from: comps),
              let range = calendar.range(of: .day, in: .month, for: monthStart) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: monthStart) - 1
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(date)
            }
        }
        
        return days
    }
}
