import SwiftUI

struct MainView: View {
    @State private var selectedTab = 0
    
    init() {
        // App-wide styling for premium feel
        UITabBar.appearance().backgroundColor = UIColor(red: 0.04, green: 0.04, blue: 0.05, alpha: 1)
        UITabBar.appearance().unselectedItemTintColor = .gray
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Explore", systemImage: "play.circle.fill")
                }
                .tag(0)
            
            AdminView()
                .tabItem {
                    Label("Admin", systemImage: "lock.shield.fill")
                }
                .tag(1)
        }
        .accentColor(.purple)
        .preferredColorScheme(.dark)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
