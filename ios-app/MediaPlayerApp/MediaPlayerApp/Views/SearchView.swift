import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.04, green: 0.04, blue: 0.05).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerSection
                    
                    searchBar
                    
                    filterSelector
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            if viewModel.isLoading {
                                loadingView
                            } else if viewModel.searchText.isEmpty {
                                recentSearchesSection
                            } else if viewModel.filteredResults.isEmpty {
                                emptyStateView
                            } else {
                                resultsList
                            }
                        }
                        .padding(.bottom, 100)
                    }
                    .refreshable {
                        if !viewModel.searchText.isEmpty {
                            await viewModel.performSearch(query: viewModel.searchText)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var headerSection: some View {
        HStack {
            Text("Search")
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search for music or videos", text: $viewModel.searchText)
                .foregroundColor(.white)
                .focused($isSearchFieldFocused)
                .submitLabel(.search)
            
            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
    
    private var filterSelector: some View {
        HStack(spacing: 12) {
            ForEach(SearchViewModel.SearchFilter.allCases, id: \.self) { filter in
                Button(action: {
                    withAnimation(.spring()) { viewModel.selectedFilter = filter }
                }) {
                    Text(filter.rawValue)
                        .font(.system(size: 14, weight: .bold))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(viewModel.selectedFilter == filter ? Color(red: 0.6, green: 0.4, blue: 1.0) : Color.white.opacity(0.05))
                        .foregroundColor(viewModel.selectedFilter == filter ? .white : .gray)
                        .cornerRadius(20)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 15)
        .padding(.bottom, 10)
    }
    
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            if !viewModel.recentSearches.isEmpty {
                HStack {
                    Text("Recent Searches")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button("Clear") { viewModel.clearRecentSearches() }
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                }
                .padding(.horizontal, 24)
                
                VStack(spacing: 0) {
                    ForEach(viewModel.recentSearches, id: \.self) { search in
                        Button(action: { viewModel.searchText = search }) {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.gray)
                                Text(search)
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "arrow.up.left")
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                            .padding()
                            .background(Color.white.opacity(0.02))
                        }
                        Divider().background(Color.white.opacity(0.05))
                    }
                }
                .cornerRadius(15)
                .padding(.horizontal, 24)
            }
        }
        .padding(.top, 20)
    }
    
    private var resultsList: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.filteredResults) { item in
                NavigationLink(destination: PlayerView(mediaItem: item)) {
                    HStack(spacing: 15) {
                        if let thumbUrl = item.thumbnailUrl, let url = URL(string: thumbUrl) {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(12)
                                } else {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 60, height: 60)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            highlightedText(item.title, query: viewModel.searchText)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text(item.type.rawValue.capitalized)
                                .font(.system(size: 12))
                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    .padding()
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(18)
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.05), lineWidth: 1))
                }
                .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
    }
    
    private func highlightedText(_ text: String, query: String) -> Text {
        guard !query.isEmpty else { return Text(text) }
        
        let lowerText = text.lowercased()
        let lowerQuery = query.lowercased()
        
        if let range = lowerText.range(of: lowerQuery) {
            let prefix = String(text[..<range.lowerBound])
            let match = String(text[range])
            let suffix = String(text[range.upperBound...])
            
            return Text(prefix) + 
                   Text(match).foregroundColor(Color(red: 0.6, green: 0.4, blue: 1.0)) + 
                   Text(suffix)
        }
        
        return Text(text)
    }
    
    private var loadingView: some View {
        VStack(spacing: 15) {
            ProgressView()
                .tint(Color(red: 0.6, green: 0.4, blue: 1.0))
            Text("Searching...")
                .foregroundColor(.gray)
                .font(.system(size: 14))
        }
        .padding(.top, 50)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 15) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.3))
            
            VStack(spacing: 5) {
                Text("No results found")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Text("Try searching with another keyword")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
        .padding(.top, 100)
    }
}
