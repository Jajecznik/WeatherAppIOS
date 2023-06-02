import SwiftUI

enum SpeedUnit: String {
    case meters = "m/s"
    case kilometers = "km/h"
}

class SpeedSettings: ObservableObject {
    @Published var speedUnit: SpeedUnit = .meters
}
