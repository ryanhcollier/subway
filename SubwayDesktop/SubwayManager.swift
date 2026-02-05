import Foundation
import Combine
import SwiftUI

enum APIStatus { case loading, connected, error }

// Define outside class for global visibility
struct SubwayArrival: Identifiable {
    let id = UUID()
    let route: String
    let destination: String
    let time: String
    let sortTime: Int
    let color: Color
}

class SubwayManager: ObservableObject {
    @Published var arrivals: [SubwayArrival] = []
    @Published var lastUpdated: String = "--:--"
    @Published var stationName: String = "CARROLL ST"
    @Published var allStations: [StationReference] = []
    
    // WTFT-style JSON endpoint
    private var feedURL = "https://api.wheresthefuckingtrain.com/by-id/F21"
    private var timer: AnyCancellable?

    // New Decoding Structs
    struct WTFTResponse: Decodable {
        let data: [WTFTStation]
        let updated: String
    }
    
    struct WTFTStation: Decodable {
        let id: String
        let name: String
        let N: [WTFTTrain]
        let S: [WTFTTrain]
    }
    
    struct WTFTTrain: Decodable {
        let route: String
        let time: String
    }

    struct StationReference: Identifiable {
        let id: String
        let name: String
    }

    static let shared = SubwayManager()

    init() {
        startTimer()
        loadStations()
        fetchSubwayTimes()
    }

    // UPDATED: Accepts id and name to fix "Missing argument" error
    func changeStation(to id: String, name: String) {
        self.stationName = name.uppercased()
        // API supports multiple IDs, for now assuming single ID logic
        self.feedURL = "https://api.wheresthefuckingtrain.com/by-id/\(id)"
        fetchSubwayTimes()
    }

    func fetchSubwayTimes() {
        guard let url = URL(string: feedURL) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            
            do {
                let decoded = try JSONDecoder().decode(WTFTResponse.self, from: data)
                
                var fetched: [SubwayArrival] = []
                let isoFormatter = ISO8601DateFormatter()
                // Enable fractional seconds if needed, but standard ISO usually fine. 
                // WTFT might return slightly different format, generally ISO8601.
                
                for station in decoded.data {
                    // Helper to process a direction
                    func process(trains: [WTFTTrain], direction: String) -> [SubwayArrival] {
                        var result: [SubwayArrival] = []
                        
                        // Parse dates first to allow sorting
                        let parsedTrains = trains.compactMap { t -> (train: WTFTTrain, date: Date)? in
                            guard let date = isoFormatter.date(from: t.time) else { return nil }
                            return (t, date)
                        }
                        
                        // Group by route
                        let grouped = Dictionary(grouping: parsedTrains, by: { $0.train.route })
                        
                        // Sort routes alphabetically to ensure consistent display order
                        let sortedRoutes = grouped.keys.sorted()
                        
                        for route in sortedRoutes {
                             // Sort by time and take top 2
                            let items = grouped[route] ?? []
                            let sorted = items.sorted { $0.date < $1.date }.prefix(2)
                            
                            for item in sorted {
                                let mins = Int(item.date.timeIntervalSinceNow / 60)
                                if mins >= 0 {
                                    result.append(SubwayArrival(
                                        route: route,
                                        destination: direction,
                                        time: mins == 0 ? "ARR" : "\(mins) MIN",
                                        sortTime: mins,
                                        color: self.colorFor(route: route)
                                    ))
                                }
                            }
                        }
                        return result
                    }
                    
                    fetched.append(contentsOf: process(trains: station.N, direction: "NORTHBOUND"))
                    fetched.append(contentsOf: process(trains: station.S, direction: "SOUTHBOUND"))
                }
                
                DispatchQueue.main.async {
                    self.arrivals = fetched.sorted { 
                        $0.sortTime < $1.sortTime
                    }
                    self.lastUpdated = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
                }
            } catch { print("JSON Error: \(error)") }
        }.resume()
    }
    
    private func colorFor(route: String) -> Color {
        switch route.uppercased() {
        case "G": return .green
        case "F", "D", "B", "M": return .orange
        case "A", "C", "E": return .blue
        case "1", "2", "3": return .red
        case "4", "5", "6": return .green
        case "7": return .purple
        case "N", "Q", "R", "W": return .yellow
        case "L": return .gray
        case "J", "Z": return .brown
        default: return .gray
        }
    }

    private func startTimer() {
        timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in self?.fetchSubwayTimes() }
    }

    private func loadStations() {
        guard let path = Bundle.main.path(forResource: "stations", ofType: "txt") else { return }
        if let content = try? String(contentsOfFile: path) {
            let lines = content.components(separatedBy: .newlines)
            
            self.allStations = lines.compactMap { line -> StationReference? in
                if line.isEmpty || line.hasPrefix("ID") { return nil }
                
                // Parse "101 - Van Cortlandt Park..."
                let parts = line.components(separatedBy: " - ")
                if parts.count >= 2 {
                    let id = parts[0].trimmingCharacters(in: .whitespaces)
                    let name = parts[1].trimmingCharacters(in: .whitespaces)
                    return StationReference(id: id, name: name)
                }
                return nil
            }
        }
    }
}
