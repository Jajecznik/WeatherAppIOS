import SwiftUI

enum TemperatureUnit: String {
    case celsius = "°C"
    case fahrenheit = "°F"
}

class TemperatureSettings: ObservableObject {
    @Published var temperatureUnit: TemperatureUnit = .celsius
}
