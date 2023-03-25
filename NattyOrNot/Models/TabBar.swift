import SwiftUI

struct TabBar: View {
    var body: some View {
        TabsLayoutView() 
    }
}


struct TabsLayoutView: View {
    @State var selectedTab: Tab = .home
    @Namespace var namespace
    
    let bgColor: Color = .init(white: 0.9)
    let backgroundColor = Color.offWhite

    let gradient = LinearGradient(gradient: Gradient(colors: [.yellow, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        
        NavigationView {
            ZStack {
                Color.offWhite.edgesIgnoringSafeArea(.all)
                VStack {
                    if selectedTab == .home {
                        HomeView()
                    } else if selectedTab == .second {
                        SecondaryView()
                    }
                    
                    ZStack {
                        backgroundView
                        
                        
                        HStack {
                            Spacer(minLength: 0)
                            ForEach(Tab.allCases) { tab in
                                
                                TabButton(tab: tab, selectedTab: $selectedTab, namespace: namespace)
                                    .frame(width: 55, height: 55, alignment: .center)
                                
                                Spacer(minLength: 0)
                            }
                            .onTapGesture {
                                print(namespace)
                            }
                        }
                        .frame(height: 90, alignment: .center)
                        .clipped()
                    }
                    .frame(height: 90, alignment: .center)
                    .padding(.horizontal, 100)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        
                        Text("Natty Or Not")
                            .font(.largeTitle)
                            .fontWeight(.black)
                        
                            .foregroundStyle(Color.gray)
                            .padding()
                        
                        
                    }
                }
            }
        }
        
        
        
        
        
    }
    
    @ViewBuilder private var backgroundView: some View {
        LinearGradient(colors: [.init(white: 0.9), .white], startPoint: .top, endPoint: .bottom)
            .mask {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .stroke(lineWidth: 6)
            }
            .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 8)
            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
    }
    
    
    
    struct TabButton: View {
        let tab: Tab
        @Binding var selectedTab: Tab
        var namespace: Namespace.ID
        @State public var selectTab2 = "home"
        
        var body: some View {
            Button {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0.6)) {
                    selectedTab = tab
                    
                }
            } label: {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .fill(
                                Color.white
                            )
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
        }
        
        private var isSelected: Bool {
            selectedTab == tab
        }
    }
}

struct TabBarView2_Previews: PreviewProvider {
    static var previews: some View {
        TabBar()
    }
}


enum Tab: Int, Identifiable, CaseIterable, Comparable {
    static func < (lhs: Tab, rhs: Tab) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    case home, second
    
    internal var id: Int { rawValue }
    
    var icon: String {
        switch self {
        case .home:
            return "pills"
        case .second:
            return "syringe"
            
        }
    }
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .second:
            return "Games"
            
        }
    }
    
    var color: Color {
        switch self {
        case .home:
            return .indigo
        case .second:
            return .orange
            
        }
    }
}
