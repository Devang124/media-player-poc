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
                .tabItem { Label("Explore", systemImage: "play.circle.fill") }
                .tag(0)
            
            SearchView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
                .tag(1)
            
            AdminView()
                .tabItem { Label("Add Media", systemImage: "plus.square.fill") }
                .tag(2)
                
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                .tag(3)
        }
        .accentColor(Color(red: 0.6, green: 0.4, blue: 1.0))
        .preferredColorScheme(.dark)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
