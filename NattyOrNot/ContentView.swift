import SwiftUI


struct ContentView: View {
    let gradient = LinearGradient(gradient: Gradient(colors: [.yellow, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
    let backgroundColor = Color.offWhite
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.offWhite.edgesIgnoringSafeArea(.all)
                VStack {
                    HomeView()
                    TabBar()
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        
                        Text("NattyOrNot")
                            .font(.largeTitle)
                            .fontWeight(.black)
                        
                            .foregroundStyle(gradient)
                            .padding()
                        
                        
                    }
                }
            }
        }
        
        
        
        
        
        ////        NavigationView {
        //
        //
        //            ZStack (alignment: .bottom) {
        //                backgroundColor
        //                    .ignoresSafeArea()
        //                VStack(spacing: 70) {
        //                    ZStack {
        //                        //backgroundView
        //                        TabBar()
        //
        //                    }
        //                    .frame(height: 90, alignment: .center)
        //                    .padding(.horizontal, 60)
        //                }
        //                .padding(.horizontal)
        //            }
        //
        //
        //
        //        }
        
        
        
        
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MainView: View {
    var body: some View {
        VStack {
            HomeView()
            TabBar()
        }
    }
}
