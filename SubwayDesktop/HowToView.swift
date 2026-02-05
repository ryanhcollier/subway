import SwiftUI

struct HowToView: View {
    @State private var helpText: String = "Loading..."
    
    var body: some View {
        ScrollView {
            Text(helpText)
                .font(.system(.body, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minWidth: 400, minHeight: 300)
        .navigationTitle("How To Use")
        .onAppear(perform: loadHelpText)
    }
    
    private func loadHelpText() {
        guard let path = Bundle.main.path(forResource: "howto", ofType: "txt") else {
            helpText = "Could not find howto.txt"
            return
        }
        
        do {
            helpText = try String(contentsOfFile: path)
        } catch {
            helpText = "Error loading help: \(error.localizedDescription)"
        }
    }
}
