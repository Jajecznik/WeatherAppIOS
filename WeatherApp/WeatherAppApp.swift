import SwiftUI

@main
struct WeatherAppApp: App {
    @StateObject var temperatureSettings = TemperatureSettings()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(LocationManager()).environmentObject(temperatureSettings)
        }
    }
}
