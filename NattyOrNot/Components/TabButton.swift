import SwiftUI

struct TabButton: View {
    let tab: Tab
    @Binding var selectedTab: Tab
    var namespace: Namespace.ID
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0.6)) {
                selectedTab = tab
            }
        } label: {
            buttonContent
        }
    }
    
    @ViewBuilder private var buttonContent: some View {
        ZStack {
            if isSelected {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(Color.white)
                    .overlay(content: {
                        LinearGradient(colors: [.white.opacity(0.0001), tab.color.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                    })
                    .shadow(color: .white, radius: 10, x: -7, y: -7)
                    .shadow(color: tab.color.opacity(0.7), radius: 10, x: 8, y: 8)
                    .matchedGeometryEffect(id: "Selected Tab", in: namespace)
            }
            
            Image(tab.icon)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(isSelected ? tab.color : .gray)
                .scaleEffect(isSelected ? 1 : 0.9)
                .animation(isSelected ? .spring(response: 0.5, dampingFraction: 0.3, blendDuration: 1) : .spring(), value: selectedTab)
        }
    }
    
    private var isSelected: Bool {
        selectedTab == tab
    }
}
