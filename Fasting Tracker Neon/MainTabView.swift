import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var store: FastingStore
    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            NeonColors.base.edgesIgnoringSafeArea(.all)
            
            Group {
                switch selectedTab {
                case 0: TimerView()
                case 1: HistoryView()
                case 2: WeightView()
                case 3: StatsView()
                case 4: SettingsView()
                default: TimerView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 70)
            
            tabBar
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(index: 0, label: "Timer", icon: AnyView(
                TimerIconShape()
                    .fill(selectedTab == 0 ? NeonColors.primary : NeonColors.dimText)
                    .frame(width: 22, height: 22)
            ))
            tabButton(index: 1, label: "History", icon: AnyView(
                HistoryIconShape()
                    .fill(selectedTab == 1 ? NeonColors.primary : NeonColors.dimText)
                    .frame(width: 22, height: 22)
            ))
            tabButton(index: 2, label: "Weight", icon: AnyView(
                ScaleIconShape()
                    .fill(selectedTab == 2 ? NeonColors.primary : NeonColors.dimText)
                    .frame(width: 22, height: 22)
            ))
            tabButton(index: 3, label: "Stats", icon: AnyView(
                ChartIconShape()
                    .fill(selectedTab == 3 ? NeonColors.primary : NeonColors.dimText)
                    .frame(width: 22, height: 22)
            ))
            tabButton(index: 4, label: "Settings", icon: AnyView(
                GearIconShape()
                    .fill(selectedTab == 4 ? NeonColors.primary : NeonColors.dimText)
                    .frame(width: 22, height: 22)
            ))
        }
        .padding(.top, 10)
        .padding(.bottom, 24)
        .background(NeonColors.card)
    }
    
    private func tabButton(index: Int, label: String, icon: AnyView) -> some View {
        Button(action: { selectedTab = index }) {
            VStack(spacing: 3) {
                icon
                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(selectedTab == index ? NeonColors.primary : NeonColors.dimText)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
