import SwiftUI

struct DesktopContentView: View {
    @ObservedObject var subway: SubwayManager
    var height: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(subway.stationName)
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.white)
                
                Text("UPDATED: \(subway.lastUpdated)")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding([.top, .leading], 10)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 15) {
                    
                    let destinations = Array(Set(subway.arrivals.map { $0.destination })).sorted()
                    
                    ForEach(destinations, id: \.self) { dest in
                        let trains = subway.arrivals.filter { $0.destination == dest }
                        if !trains.isEmpty {
                            DirectionSection(title: dest, trains: trains)
                        }
                    }
                }
                .padding(.leading, 10)
                .padding(.bottom, 20)
            }
            Spacer()
        }
        .frame(width: 240, height: height, alignment: .topLeading)
    }
}

struct DirectionSection: View {
    let title: String
    let trains: [SubwayArrival]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 8, weight: .black))
                .foregroundColor(.white)
            
            ForEach(trains) { train in
                HStack(spacing: 8) {
                    ZStack {
                        Circle().fill(train.color).frame(width: 22, height: 22)
                        Text(train.route)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Text(train.time)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }
}
