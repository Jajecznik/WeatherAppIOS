import SwiftUI



struct WeatherSummaryView: View {
    var forecastEntries: [ForecastEntry] // Array of forecast entries
    
    var body: some View {
        VStack {
            ForEach(forecastEntries) { entry in
                VStack {
                    Text(entry.weekday)
                    Text("Max Temp: \(entry.maxTemp)°")
                    Text("Min Temp: \(entry.minTemp)°")
                    Divider()
                }
            }
        }
    }
}


struct WeatherSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        let forecastEntries=[
            ForecastEntry(weekday: "Monday", maxTemp: 25.0, minTemp: 20.0)
        ]
        return WeatherSummaryView(forecastEntries: forecastEntries)
    }
}
