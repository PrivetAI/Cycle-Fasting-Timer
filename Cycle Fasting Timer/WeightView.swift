import SwiftUI

struct WeightView: View {
    @EnvironmentObject var store: FastingStore
    @State private var weightInput: String = ""
    @State private var showAdded = false
    
    private let timeFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f
    }()
    
    var body: some View {
        ZStack {
            CycleColors.base.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    Spacer().frame(height: 20)
                    
                    Text("Weight Tracker")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(CycleColors.textWhite)
                    
                    // Log weight card
                    logWeightCard
                    
                    // Current weight display
                    if let latest = store.weightEntries.last {
                        currentWeightCard(entry: latest)
                    }
                    
                    // 30-day chart
                    weightChartCard
                    
                    // Fasting correlation card
                    correlationCard
                    
                    // Recent entries
                    recentEntriesCard
                    
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var logWeightCard: some View {
        VStack(spacing: 12) {
            Text("Log Today's Weight")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(CycleColors.textWhite)
            
            HStack(spacing: 12) {
                TextField("", text: $weightInput)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(CycleColors.primary)
                    .multilineTextAlignment(.center)
                    .padding(10)
                    .background(CycleColors.cardLight)
                    .cornerRadius(10)
                    .frame(width: 120)
                    .placeholder(when: weightInput.isEmpty) {
                        Text("0.0")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(CycleColors.dimText.opacity(0.4))
                    }
                
                Text("kg")
                    .font(.system(size: 16))
                    .foregroundColor(CycleColors.dimText)
                
                Spacer()
                
                Button(action: logWeight) {
                    Text(showAdded ? "Saved" : "Log")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(CycleColors.base)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(showAdded ? CycleColors.dimText : CycleColors.primary)
                        .cornerRadius(10)
                }
                .disabled(showAdded)
            }
        }
        .padding(16)
        .background(CycleColors.card)
        .cornerRadius(14)
    }
    
    private func currentWeightCard(entry: WeightEntry) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Weight")
                    .font(.system(size: 13))
                    .foregroundColor(CycleColors.dimText)
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(String(format: "%.1f", entry.weight))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(CycleColors.primary)
                    Text("kg")
                        .font(.system(size: 15))
                        .foregroundColor(CycleColors.dimText)
                }
            }
            Spacer()
            
            // Trend indicator
            if store.weightEntries.count >= 2 {
                let prev = store.weightEntries[store.weightEntries.count - 2].weight
                let diff = entry.weight - prev
                VStack(spacing: 2) {
                    if diff < 0 {
                        ArrowUpShape()
                            .stroke(CycleColors.primary, lineWidth: 2)
                            .frame(width: 16, height: 16)
                            .rotationEffect(.degrees(180))
                    } else if diff > 0 {
                        ArrowUpShape()
                            .stroke(Color(red: 1, green: 0.4, blue: 0.4), lineWidth: 2)
                            .frame(width: 16, height: 16)
                    }
                    Text(String(format: "%+.1f", diff))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(diff < 0 ? CycleColors.primary : (diff > 0 ? Color(red: 1, green: 0.4, blue: 0.4) : CycleColors.dimText))
                }
            }
        }
        .padding(16)
        .background(CycleColors.card)
        .cornerRadius(14)
    }
    
    private var weightChartCard: some View {
        let weightData = store.last30DaysWeights()
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Weight Trend - 30 Days")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(CycleColors.textWhite)
            
            if weightData.count >= 2 {
                CycleWeightChart(data: weightData)
                    .frame(height: 160)
            } else {
                Text("Log at least 2 days to see the trend")
                    .font(.system(size: 13))
                    .foregroundColor(CycleColors.dimText)
                    .frame(height: 80)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .background(CycleColors.card)
        .cornerRadius(14)
    }
    
    private var correlationCard: some View {
        let fastData = store.last30DaysDurations()
        let weightData = store.last30DaysWeights()
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Fasting vs Weight")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(CycleColors.textWhite)
            
            if weightData.count >= 2 && !fastData.isEmpty {
                CycleDualChart(fastData: fastData, weightData: weightData)
                    .frame(height: 140)
                
                HStack(spacing: 16) {
                    HStack(spacing: 6) {
                        Circle().fill(CycleColors.primary).frame(width: 8, height: 8)
                        Text("Fasting hours")
                            .font(.system(size: 11))
                            .foregroundColor(CycleColors.dimText)
                    }
                    HStack(spacing: 6) {
                        Circle().fill(Color(red: 0.4, green: 0.6, blue: 1.0)).frame(width: 8, height: 8)
                        Text("Weight")
                            .font(.system(size: 11))
                            .foregroundColor(CycleColors.dimText)
                    }
                }
            } else {
                Text("Log weight and fasts to see correlation")
                    .font(.system(size: 13))
                    .foregroundColor(CycleColors.dimText)
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .background(CycleColors.card)
        .cornerRadius(14)
    }
    
    private var recentEntriesCard: some View {
        let recent = Array(store.weightEntries.suffix(7).reversed())
        
        return VStack(alignment: .leading, spacing: 10) {
            Text("Recent Entries")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(CycleColors.textWhite)
            
            if recent.isEmpty {
                Text("No weight entries yet")
                    .font(.system(size: 13))
                    .foregroundColor(CycleColors.dimText)
            } else {
                ForEach(recent) { entry in
                    HStack {
                        Text(timeFmt.string(from: entry.date))
                            .font(.system(size: 14))
                            .foregroundColor(CycleColors.dimText)
                        Spacer()
                        Text(String(format: "%.1f kg", entry.weight))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(CycleColors.textWhite)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(16)
        .background(CycleColors.card)
        .cornerRadius(14)
    }
    
    private func logWeight() {
        guard let val = Double(weightInput.replacingOccurrences(of: ",", with: ".")), val > 0, val < 500 else { return }
        store.addWeightEntry(weight: val)
        weightInput = ""
        showAdded = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showAdded = false
        }
    }
}

struct ArrowUpShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.height * 0.2))
        p.addLine(to: CGPoint(x: rect.width * 0.3, y: rect.height * 0.5))
        p.move(to: CGPoint(x: rect.midX, y: rect.height * 0.2))
        p.addLine(to: CGPoint(x: rect.width * 0.7, y: rect.height * 0.5))
        p.move(to: CGPoint(x: rect.midX, y: rect.height * 0.2))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.height * 0.8))
        return p
    }
}

struct CycleWeightChart: View {
    let data: [(Date, Double)]
    
    var body: some View {
        GeometryReader { geo in
            let vals = data.map { $0.1 }
            let minW = (vals.min() ?? 0) - 1
            let maxW = (vals.max() ?? 1) + 1
            let range = max(maxW - minW, 1)
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
                        let y = h - (CGFloat((item.1 - minW) / range) * h)
                        if i == 0 { p.move(to: CGPoint(x: x, y: y)) }
                        else { p.addLine(to: CGPoint(x: x, y: y)) }
                    }
                }
                .stroke(Color(red: 0.4, green: 0.6, blue: 1.0), lineWidth: 2)
                
                ForEach(Array(data.enumerated()), id: \.offset) { i, item in
                    Circle()
                        .fill(Color(red: 0.4, green: 0.6, blue: 1.0))
                        .frame(width: 5, height: 5)
                        .position(
                            x: CGFloat(i) * stepX,
                            y: h - (CGFloat((item.1 - minW) / range) * h)
                        )
                }
            }
        }
    }
}

struct CycleDualChart: View {
    let fastData: [(Date, Double)]
    let weightData: [(Date, Double)]
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            let fastMax = max(fastData.map { $0.1 }.max() ?? 1, 1)
            let wVals = weightData.map { $0.1 }
            let wMin = (wVals.min() ?? 0) - 0.5
            let wMax = (wVals.max() ?? 1) + 0.5
            let wRange = max(wMax - wMin, 1)
            
            let fStepX = w / CGFloat(max(fastData.count - 1, 1))
            let wStepX = w / CGFloat(max(weightData.count - 1, 1))
            
            ZStack(alignment: .bottomLeading) {
                // Fasting line
                Path { p in
                    for (i, item) in fastData.enumerated() {
                        let x = CGFloat(i) * fStepX
                        let y = h - (CGFloat(item.1 / fastMax) * h)
                        if i == 0 { p.move(to: CGPoint(x: x, y: y)) }
                        else { p.addLine(to: CGPoint(x: x, y: y)) }
                    }
                }
                .stroke(CycleColors.primary.opacity(0.7), lineWidth: 1.5)
                
                // Weight line
                Path { p in
                    for (i, item) in weightData.enumerated() {
                        let x = CGFloat(i) * wStepX
                        let y = h - (CGFloat((item.1 - wMin) / wRange) * h)
                        if i == 0 { p.move(to: CGPoint(x: x, y: y)) }
                        else { p.addLine(to: CGPoint(x: x, y: y)) }
                    }
                }
                .stroke(Color(red: 0.4, green: 0.6, blue: 1.0), lineWidth: 1.5)
            }
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .center,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
