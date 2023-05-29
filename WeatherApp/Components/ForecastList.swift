import SwiftUI

struct ForecastListView: View {
    var forecast: ForecastList
    var forecastEntries: [ForecastEntry] // dodano
    
    init(forecast: ForecastList) {
            self.forecast = forecast
            
    // Create forecast entries from the forecast list
    forecastEntries = forecast.list.map { entry in
        return ForecastEntry(weekday: entry.weekday,
                maxTemp: entry.main.temp_max,
                minTemp: entry.main.temp_min)
            }
        }
    
    var body: some View {
        List {
            ForEach(forecast.list) { entry in
                NavigationLink(destination: ForecastDetailView(element: entry)) {
                    ForecastRow(element: entry)
                }
            }
        }
    }
}
