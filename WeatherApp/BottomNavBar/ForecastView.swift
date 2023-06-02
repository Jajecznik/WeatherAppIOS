import SwiftUI
import CoreLocation

struct ForecastEntry: Identifiable {
    var id = UUID()
    var weekday: String
    var maxTemp: Double
    var minTemp: Double
}

struct ForecastView: View {
    @EnvironmentObject var locationManager: LocationManager
    var weatherManager = WeatherManager()
    @State var forecast: ForecastList?
    @State var isLoading = true;
    @State private var showWeatherSummary = false
    @EnvironmentObject var temperatureSettings: TemperatureSettings
    @EnvironmentObject var speedSettings: SpeedSettings
    
    func loadWeatherForecast(location: CLLocationCoordinate2D) async {
    isLoading = true
        defer { isLoading = false }
        do {
            forecast = try await weatherManager.getForecastWeather(latitude: location.latitude, longitude: location.longitude)
        }
        catch {
            print(error)
            print("Error while fetching weather forecast")
        }
    }
    
    var forecastEntries: [ForecastEntry] {
        guard let forecast = forecast else {
            return []
        }
        return forecast.list.map { entry in
            let maxTemp = maxTemperature(entry.main.temp_max)
            let minTemp = minTemperature(entry.main.temp_min)
            return ForecastEntry(weekday: entry.weekday,
                                 maxTemp: maxTemp,
                                 minTemp: minTemp)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Color(hue: 0.333, saturation: 1, brightness: 1)
                    VStack {
                        Text("\(forecast?.city.name ?? "")")
                            .bold()
                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 70 : 30))
                            .foregroundColor(Color.black)
                    }
                }
                .frame(maxHeight: UIDevice.current.userInterfaceIdiom == .pad ? 200 : 80, alignment: .leading)
                
                ZStack {
                    VStack {
                        Button(action: {
                            showWeatherSummary = true
                        }) {
                            Text("Temperature Graph")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color(hue: 0.333, saturation: 1, brightness: 1))
                                .cornerRadius(10)
                        }
                    }
                }
                .frame(maxHeight: UIDevice.current.userInterfaceIdiom == .pad ? 200 : 80, alignment: .leading)
                
                if forecast != nil && !isLoading {
                    ForecastListView(forecast: forecast!).environmentObject(temperatureSettings).environmentObject(speedSettings)
                } else if isLoading {
                    LoadingView()
                } else {
                    Text("Error while loading weather")
                }
            }
            .onAppear {
                Task {
                    await loadWeatherForecast(location: locationManager.location!)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showWeatherSummary) {
            WeatherSummaryView(forecastEntries: forecastEntries)
        }
    }
    
    private func maxTemperature(_ temperature: Double) -> Double {
        let convertedTemperature = convertTemperature(temperature)
        return convertedTemperature
    }

    private func minTemperature(_ temperature: Double) -> Double {
        let convertedTemperature = convertTemperature(temperature)
        return convertedTemperature
    }
    
    private func convertTemperature(_ temperature: Double) -> Double {
        switch temperatureSettings.temperatureUnit {
        case .celsius:
            return temperature.rounded()
        case .fahrenheit:
            let convertedTemperature = (temperature * 9/5) + 32
            return convertedTemperature.rounded()
        }
    }
    
    private var temperatureUnitSymbol: String {
        switch temperatureSettings.temperatureUnit {
        case .celsius:
            return "°C"
        case .fahrenheit:
            return "°F"
        }
    }
}

struct ForecastView_Previews: PreviewProvider {
    static var previews: some View {
        ForecastView()
    }
}
