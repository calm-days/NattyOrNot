import SwiftUI

struct TabBar: View {
    var body: some View {
        TabsLayoutView() 
    }
}

struct TabsLayoutView: View {
    @State private var selectedTab: Tab = .home
    @Namespace private var namespace
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.offWhite.edgesIgnoringSafeArea(.all)
                VStack {
                    selectedView
                    customTabBar
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
    
    @ViewBuilder private var selectedView: some View {
        switch selectedTab {
        case .home:
            HomeView()
        case .second:
            SecondaryView()
        }
    }
    
    @ViewBuilder private var customTabBar: some View {
        ZStack {
            backgroundView
            HStack {
                Spacer(minLength: 0)
                ForEach(Tab.allCases) { tab in
                    TabButton(tab: tab, selectedTab: $selectedTab, namespace: namespace)
                        .frame(width: 55, height: 55, alignment: .center)
                    Spacer(minLength: 0)
                }
            }
            .frame(height: 90, alignment: .center)
            .clipped()
        }
        .frame(height: 90, alignment: .center)
        .padding(.horizontal, 100)
    }
}

struct TabBarView2_Previews: PreviewProvider {
    static var previews: some View {
        TabBar()
    }
}

