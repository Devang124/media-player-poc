import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.04, green: 0.04, blue: 0.05).ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Custom Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search music, videos...", text: $searchText)
                            .foregroundColor(.white)
                            .accentColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    if searchText.isEmpty {
                        // Recent Searches / Suggestions
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Recent Searches")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            ForEach(["Chill Vibes", "Workout Playlist", "Tech Review Video"], id: \.self) { term in
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 14))
                                    Text(term)
                                        .font(.system(size: 16, design: .rounded))
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer()
                    } else {
                        // Search Results Placeholder
                        VStack {
                            Spacer()
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                                .padding(.bottom, 8)
                            Text("Searching for '\(searchText)'...")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
