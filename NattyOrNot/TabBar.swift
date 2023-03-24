//
//  TabBarView2.swift
//  NattyOrNot
//
//  Created by Roman Liukevich on 2/24/23.
//

import SwiftUI

struct TabBar: View {
    let bgColor: Color = .init(white: 0.9)
    var number: Int = 9
    let backgroundColor = Color.offWhite
    
   
    
    
    
    
    var body: some View {
        ZStack {
            backgroundView
 
            TabsLayoutView()
                .frame(height: 90, alignment: .center)
                .clipped()
        }
        .frame(height: 90, alignment: .center)
        .padding(.horizontal, 60)
        
        
        //        ZStack (alignment: .bottom) {
        //            backgroundColor
        //                .ignoresSafeArea()
        //            VStack(spacing: 70) {
        //
        //            }
        //            .padding(.horizontal)
        //        }
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
}


struct TabsLayoutView: View {
    @State var selectedTab: Tab = .home
    @Namespace var namespace
    //@Binding var selected2 = "home"
    
    var body: some View {
        
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
        //            if selectedTab == .home {
        //                //HomeView()
        //                ContentView()
        //            }
        
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
                    
                    selectTab2 = "\(tab)"
                    print(selectTab2)
                    
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
                    
                    Image(systemName: tab.icon)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
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
    
    case home, game, apps
    
    internal var id: Int { rawValue }
    
    var icon: String {
        switch self {
        case .home:
            return "house.fill"
        case .game:
            return "gamecontroller.fill"
        case .apps:
            return "square.stack.3d.up.fill"
            
        }
    }
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .game:
            return "Games"
        case .apps:
            return "Apps"
            
        }
    }
    
    var color: Color {
        switch self {
        case .home:
            return .indigo
        case .game:
            return .pink
        case .apps:
            return .orange
            
        }
    }
}
