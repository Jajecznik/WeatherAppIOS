import SwiftUI
import CoreLocation
import Network
import CoreLocationUI

func convertTimestamp(_ timestamp: Int) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
    let dateFormatter = DateFormatter()
    dateFormatter.timeStyle = .short
    dateFormatter.dateStyle = .none
    dateFormatter.timeZone = TimeZone.current
    let localDate = dateFormatter.string(from: date)
    return localDate
}

struct WeatherView: View {
    var weather: ResponseBody
    @EnvironmentObject var sharedText: SharedText
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var viewModel: WeatherViewModel
    @EnvironmentObject var temperatureSettings: TemperatureSettings
    @EnvironmentObject var speedSettings: SpeedSettings
    @State private var showAlert = false
    
    var body: some View {
        let weatherDescriptions = [
            "Clear": ("Clear", "sun.max.fill"),
            "Clouds": ("Cloudy", "cloud.fill"),
            "Drizzle": ("Drizzle", "cloud.drizzle.fill"),
            "Rain": ("Rain", "cloud.rain.fill"),
            "Thunderstorm": ("Thunderstorm", "cloud.bolt.fill"),
            "Snow": ("Snow", "cloud.snow.fill"),
            "Mist": ("Mist", "cloud.fog.fill"),
            "Smoke": ("Smoke", "smoke.fill"),
            "Haze": ("Haze", "sun.haze.fill"),
            "Dust": ("Dust", "sun.dust.fill"),
            "Fog": ("Fog", "cloud.fog.fill"),
            "Sand": ("Sandstorm", "cloud.hail.fill"),
            "Ash": ("Volcanic Ash", "smoke.fill"),
            "Squall": ("Squall", "wind.snow"),
            "Tornado": ("Tornado", "tornado"),
        ]

        let weatherCode = (sharedText.text == "no" ? weather.weather[0].main : viewModel.weather?.weather[0].main) ?? weather.weather[0].main
        let (weatherDescription, weatherIcon) = weatherDescriptions[weatherCode] ?? ("Nieznana", "questionmark")
            ScrollView{
                ZStack(alignment: .leading) {
                    VStack {
                        VStack(alignment: .leading, spacing: 5) {
                            if(sharedText.text == "no")
                            {
                                Text(weather.name)
                                    .bold()
                                
                                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 70 : 40))
                            } else {
                                Text(viewModel.weather?.name ?? "")
                                    .bold()
                                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 70 : 40))
                            }
                            Text("Today, \(Date().formatted(.dateTime.month().day().hour().minute()))")
                                .fontWeight(.light)
                                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 30 : 20))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                            .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 100 : 40)
                        
                        VStack {
                            HStack {
                                VStack(spacing: 30) {
                                    Image(systemName: weatherIcon)
                                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 120 : 50))
                                    Text(weatherDescription)
                                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 40 : 20))
                                }
                                .frame(width: 150, alignment: .leading)
                                
                                Spacer()
                                if(sharedText.text == "no") {
                                    Text(currentTemperature)
                                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 140 : 80))
                                        .fontWeight(.bold)
                                        .padding()
                                } else {
                                    Text(currentTemperature)
                                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 140 : 80))
                                        .fontWeight(.bold)
                                        .padding()
                                }
                            }
                            Spacer()
                                .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 100 : 40)
                            
                            VStack(alignment: .leading, spacing: 20) {
                                HStack {
                                    Text("Weather now")
                                        .bold()
                                        .padding(.bottom)
                                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 40 : 20))
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                               toggleTemperatureUnit()
                                           }) {
                                               Text(temperatureUnitSymbol)
                                                   .padding()
                                                   .foregroundColor(.white)
                                                   .background(Color.blue)
                                                   .cornerRadius(10)
                                           }
                                           .padding()
                                    
                                    Button(action: {
                                               toggleSpeedUnit()
                                           }) {
                                               Text(speedUnitSymbol)
                                                   .padding()
                                                   .foregroundColor(.white)
                                                   .background(Color.blue)
                                                   .cornerRadius(10)
                                           }
                                           .padding()
                                }
                    
                                HStack {
                                    if(sharedText.text == "no")
                                    {
                                        WeatherRow(logo: "thermometer", name: "Min temp", value: minTemperature)
                                        Spacer()
                                        WeatherRow(logo: "thermometer", name: "Max temp", value: maxTemperature)
                                    }
                                    else {
                                        WeatherRow(logo: "thermometer", name: "Min temp", value: minTemperature)
                                        Spacer()
                                        WeatherRow(logo: "thermometer", name: "Max temp", value: maxTemperature)
                                    }
                                }
                                
                                HStack {
                                    if(sharedText.text == "no")
                                    {
                                        WeatherRow(logo: "wind", name: "Wind speed", value: windSpeed)
                                        Spacer()
                                        WeatherRow(logo: "humidity", name: "Humidity", value: "\(weather.main.humidity.roundDouble())%")
                                    }
                                    else {
                                        WeatherRow(logo: "wind", name: "Wind speed", value: windSpeed)
                                        Spacer()
                                        WeatherRow(logo: "humidity", name: "Humidity", value: "\(viewModel.weather?.main.humidity.roundDouble() ?? "0")%")
                                    }
                                }
                                
                                HStack {
                                    if(sharedText.text == "no")
                                    {
                                        WeatherRow(logo: "barometer", name: "Pressure", value: (weather.main.pressure.roundDouble() + " hPa"))
                                        Spacer()
                                        WeatherRow(logo: "thermometer.sun", name: "Feels like", value: feelsTemperature)
                                    }
                                    else {
                                        WeatherRow(logo: "barometer", name: "Pressure", value: "\(viewModel.weather?.main.pressure.roundDouble() ?? "0") hPa")
                                        Spacer()
                                        WeatherRow(logo: "thermometer.sun", name: "Feels like", value: feelsTemperature)
                                    }
                                }
                                
                                HStack {
                                    if(sharedText.text == "no") {
                                        WeatherRow(logo: "sunrise", name: "Sunrise", value: convertTimestamp(weather.sys.sunrise))
                                        Spacer()
                                        WeatherRow(logo: "sunset", name: "Sunset", value: convertTimestamp(weather.sys.sunset))
                                    } else {
                                        WeatherRow(logo: "sunrise", name: "Sunrise", value: convertTimestamp(viewModel.weather?.sys.sunrise ?? 0))
                                        Spacer()
                                        WeatherRow(logo: "sunset", name: "Sunset", value: convertTimestamp(viewModel.weather?.sys.sunset ?? 0))
                                    }
                                }
                                
                                HStack {
                                    if(sharedText.text == "no")
                                    {
                                        WeatherRow(logo: "cloud.fill", name: "Chance of cloudiness", value: ("\(weather.clouds.all)%"))
                                        Spacer()
                                        WeatherRow(logo: "eye.fill", name: "Visibility", value: ("\(weather.visibility/1000) km"))
                                    }
                                    else {
                                        WeatherRow(logo: "cloud.fill", name: "Chance of cloudiness", value: "\(viewModel.weather?.clouds.all ?? 0)%")
                                        Spacer()
                                        WeatherRow(logo: "eye.fill", name: "Visibility", value: "\((viewModel.weather?.visibility ?? 0) / 1000) km")
                                    }
                                }
                                
                            }
                            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? .infinity : 400, alignment: .leading)
                            .padding()
                            .foregroundColor(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
                            .background(.white)
                            .cornerRadius(20)
                            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 80 : 0)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .edgesIgnoringSafeArea(.bottom)
                    .background(Color(hue: 0.333, saturation: 1, brightness: 1))
                    .preferredColorScheme(.dark)
                    .foregroundColor(Color.black)
                    
                    VStack {
                        HStack {
                            Spacer()
                            LocationButton() {
                                locationManager.requestLocation()
                                guard let location = locationManager.location else {
                                    print("Error getting current location")
                                    return
                                }
                                
                                Task {
                                    await viewModel.getWeatherForCoordinates(latitude: location.latitude, longitude: location.longitude)
                                }
                                
                                if let cityName = locationManager.cityName {
                                    print(cityName)
                                    sharedText.text = cityName
                                    locationManager.locationUpdated = true
                                }
                            }
                            .cornerRadius(30)
                            .symbolVariant(.fill)
                            .foregroundColor(.white)
                            .labelStyle(.iconOnly)
                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 30))
                            .padding(UIDevice.current.userInterfaceIdiom == .pad ? 60 : 20)
                        }
                        .padding(25)
                        Spacer()
                    }
                }
                
            }
            .onAppear {
                Task {
                    if(sharedText.text == "no")
                    {
                        print(sharedText.text+"model")
                        print(locationManager.location ?? "xd")
                    } else {
                        print(sharedText.text+"viewmodel")
                        await viewModel.getWeatherForCity(city: sharedText.text)
                    }
                }
            }
            .onReceive(locationManager.$locationUpdated) { updated in
                if updated {
                    Task {
                        if(sharedText.text == "no")
                        {
                            print(locationManager.location ?? "xd")
                        } else {
                            print(sharedText.text+"ONRECEIVE")
                            await viewModel.getWeatherForCity(city: sharedText.text)
                        }
                    }
                    locationManager.locationUpdated = false
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("No internet connection"),
                    message: Text("Setting default location."),
                    dismissButton: .default(Text("OK")) {
                        showAlert = false
                    }
                )
            }
            .onAppear {
                checkInternetConnection()
            }
        }
    
    private var speedUnitSymbol: String {
            switch speedSettings.speedUnit {
            case .meters:
                return "m/s"
            case .kilometers:
                return "km/h"
            }
        }
    
    private var windSpeed: String {
        let speed = (sharedText.text == "no" ? weather.wind.speed : viewModel.weather?.wind.speed) ?? weather.wind.speed
        let convertedSpeed = convertSpeed(speed)
        return "\(convertedSpeed) \(speedUnitSymbol)"
    }
    
    private var temperatureUnitSymbol: String {
            switch temperatureSettings.temperatureUnit {
            case .celsius:
                return "°C"
            case .fahrenheit:
                return "°F"
            }
        }
    
    private func convertSpeed(_ speed: Double) -> String {
        switch speedSettings.speedUnit {
        case .meters:
            return "\(speed.roundDouble())"
        case .kilometers:
            let convertedSpeed = speed * 3.6
            return "\(convertedSpeed.roundDouble())"
        }
    }

func toggleSpeedUnit() {
        if speedSettings.speedUnit == .meters {
            speedSettings.speedUnit = .kilometers
        } else {
            speedSettings.speedUnit = .meters
        }
    }
    
        private var currentTemperature: String {
            let temperature = (sharedText.text == "no" ? weather.main.temp : viewModel.weather?.main.temp) ?? weather.main.temp
            let convertedTemperature = convertTemperature(temperature)
            return "\(convertedTemperature) \(temperatureUnitSymbol)"
        }

        private var minTemperature: String {
            let temperature = (sharedText.text == "no" ? weather.main.tempMin : viewModel.weather?.main.tempMin) ?? weather.main.tempMin
            let convertedTemperature = convertTemperature(temperature)
            return "\(convertedTemperature) \(temperatureUnitSymbol)"
        }

        private var maxTemperature: String {
            let temperature = (sharedText.text == "no" ? weather.main.tempMax : viewModel.weather?.main.tempMax) ?? weather.main.tempMax
            let convertedTemperature = convertTemperature(temperature)
            return "\(convertedTemperature) \(temperatureUnitSymbol)"
        }

        private var feelsTemperature: String {
            let temperature = (sharedText.text == "no" ? weather.main.feelsLike : viewModel.weather?.main.feelsLike) ?? weather.main.feelsLike
            let convertedTemperature = convertTemperature(temperature)
            return "\(convertedTemperature) \(temperatureUnitSymbol)"
        }

        private func convertTemperature(_ temperature: Double) -> String {
            switch temperatureSettings.temperatureUnit {
            case .celsius:
                return "\(temperature.roundDouble())"
            case .fahrenheit:
                let convertedTemperature = (temperature * 9/5) + 32
                return "\(convertedTemperature.roundDouble())"
            }
        }
    
    func toggleTemperatureUnit() {
            if temperatureSettings.temperatureUnit == .celsius {
                temperatureSettings.temperatureUnit = .fahrenheit
            } else {
                temperatureSettings.temperatureUnit = .celsius
            }
        }
    
    func checkInternetConnection() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                showAlert = false
            } else {
                showAlert = true
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
}
