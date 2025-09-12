import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var navigationPath = NavigationPath()
    
    private var currentTitle: String {
        switch selectedTab {
        case 0: return "Poem Catalog"
        case 1: return "My Library"
        case 2: return "Today's Review"
        default: return "Meletao"
        }
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                // Custom header with title and tab buttons
                VStack {
                    HStack {
                        Text(currentTitle)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            TabButton(title: "Catalog", 
                                    systemImage: "books.vertical",
                                    isSelected: selectedTab == 0) {
                                selectedTab = 0
                            }
                            
                            TabButton(title: "Library", 
                                    systemImage: "book",
                                    isSelected: selectedTab == 1) {
                                selectedTab = 1
                            }
                            
                            TabButton(title: "Review", 
                                    systemImage: "clock",
                                    isSelected: selectedTab == 2) {
                                selectedTab = 2
                            }
                        }
                    }
                    .padding()
                    
                    Divider()
                }
                .background(Color.staticMeletaoSurface)
                
                // Content area - full screen
                Group {
                    switch selectedTab {
                    case 0:
                        CatalogView()
                    case 1:
                        LibraryView()
                    case 2:
                        ReviewView()
                    default:
                        CatalogView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.staticMeletaoBackground)
            }
            .navigationDestination(for: Poem.self) { poem in
                MemorizationView(poem: poem)
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .background(Color.staticMeletaoBackground)
    }
}

struct TabButton: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                Text(title)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.staticMeletaoPrimary : Color.clear)
            .foregroundColor(isSelected ? .white : Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
                switch appearance.name {
                case .darkAqua, .vibrantDark, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark:
                    return NSColor.white // White text in dark mode for visibility
                default:
                    return NSColor(Color.staticMeletaoPrimary) // Original teal color in light mode
                }
            })))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContentView()
}