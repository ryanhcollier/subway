import SwiftUI

struct MenuView: View {
    @ObservedObject var subway: SubwayManager
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool

    var filteredStations: [SubwayManager.StationReference] {
        if searchText.isEmpty { return [] }
        return subway.allStations.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.id.localizedCaseInsensitiveContains(searchText)
        }.prefix(6).map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CURRENT: \(subway.stationName)")
                .font(.system(size: 10, weight: .bold))

            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search stations...", text: $searchText)
                    .textFieldStyle(.plain)
                    .focused($isSearchFocused)
            }
            .padding(6)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(4)

            if !filteredStations.isEmpty {
                Divider()
                ForEach(filteredStations) { station in
                    Button(action: {
                        // FIX: Access function directly without '$' prefix
                        subway.changeStation(to: station.id, name: station.name)
                        searchText = ""
                        NSApp.sendAction(#selector(NSMenu.cancelTracking), to: nil, from: nil)
                    }) {
                        HStack {
                            Text(station.name).font(.system(size: 11))
                            Spacer()
                            Text(station.id).opacity(0.4).font(.system(size: 9))
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            Divider()
            Button("Quit") { NSApplication.shared.terminate(nil) }
                .buttonStyle(.plain).font(.system(size: 11))
        }
        .padding(12)
        .frame(width: 260)
        .onAppear { isSearchFocused = true }
    }
}
