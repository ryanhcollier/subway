import SwiftUI

struct MenuView: View {
    @ObservedObject var subway: SubwayManager
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    @Environment(\.openWindow) var openWindow

    var filteredStations: [SubwayManager.StationReference] {
        if searchText.isEmpty { return [] }
        
        // Normalize search text (e.g., "14th" -> "14") to match "14 St"
        let normalized = searchText.replacingOccurrences(
            of: "(\\d+)(st|nd|rd|th)", 
            with: "$1", 
            options: .regularExpression, 
            range: nil
        )
        
        return subway.allStations.filter {
            let name = $0.name
            let id = $0.id
            
            // Check original search text
            if name.localizedCaseInsensitiveContains(searchText) || id.localizedCaseInsensitiveContains(searchText) {
                return true
            }
            // Check normalized text if different
            if normalized != searchText {
                if name.localizedCaseInsensitiveContains(normalized) || id.localizedCaseInsensitiveContains(normalized) {
                    return true
                }
            }
            return false
        }
        .sorted { s1, s2 in
            // Priority 1: Name starts with search text/normalized
            let s1Starts = s1.name.localizedStandardContains(searchText) && s1.name.lowercased().hasPrefix(searchText.lowercased())
            let s2Starts = s2.name.localizedStandardContains(searchText) && s2.name.lowercased().hasPrefix(searchText.lowercased())
            
            if s1Starts && !s2Starts { return true }
            if !s1Starts && s2Starts { return false }
            
            // Priority 2: Normalized starts with
            let s1NormStarts = s1.name.localizedStandardContains(normalized) && s1.name.lowercased().hasPrefix(normalized.lowercased())
            let s2NormStarts = s2.name.localizedStandardContains(normalized) && s2.name.lowercased().hasPrefix(normalized.lowercased())
            
            if s1NormStarts && !s2NormStarts { return true }
            if !s1NormStarts && s2NormStarts { return false }
            
            return s1.name < s2.name
        }
        .prefix(15).map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CURRENT: \(subway.stationName)")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search stations...", text: $searchText)
                    .textFieldStyle(.plain)
                    .focused($isSearchFocused)
            }
            .padding(6)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )

            if !filteredStations.isEmpty {
                Divider()
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(filteredStations) { station in
                            Button(action: {
                                subway.changeStation(to: station.id, name: station.name)
                                searchText = ""
                                NSApp.sendAction(#selector(NSMenu.cancelTracking), to: nil, from: nil)
                            }) {
                                HStack {
                                    Text(station.name)
                                        .font(.system(size: 11))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(station.id)
                                        .font(.system(size: 9))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 4)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.borderless) // Standard hover effect behavior in menus
                        }
                    }
                }
                .frame(maxHeight: 200)
            }

            Divider()
            VStack(alignment: .leading, spacing: 6) {
                Button("How To") {
                    openWindow(id: "howto")
                    NSApp.sendAction(#selector(NSMenu.cancelTracking), to: nil, from: nil)
                }
                .buttonStyle(.plain)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button("Screen Swap") {
                    print("DEBUG: Screen Swap clicked")
                    // Try to find the DesktopWindow directly from running windows
                    if let window = NSApp.windows.first(where: { $0 is DesktopWindow }) as? DesktopWindow {
                        print("DEBUG: Found DesktopWindow in NSApp.windows")
                        window.moveToNextScreen()
                    } else {
                        print("DEBUG: Could not find DesktopWindow")
                    }
                    NSApp.sendAction(#selector(NSMenu.cancelTracking), to: nil, from: nil)
                }
                .buttonStyle(.plain)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button("Quit Subway") { NSApplication.shared.terminate(nil) }
                    .buttonStyle(.plain)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(12)
        .frame(width: 280)
        .onAppear { isSearchFocused = true }
    }
}
