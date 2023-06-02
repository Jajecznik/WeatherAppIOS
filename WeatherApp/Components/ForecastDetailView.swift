import SwiftUI

struct ForecastDetailView: View {
    var element: ForecastListElement
    @EnvironmentObject var temperatureSettings: TemperatureSettings
    @EnvironmentObject var speedSettings: SpeedSettings
    
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
        let weatherCode = element.weather[0].main
        let (weatherDescription, weatherIcon) = weatherDescriptions[weatherCode] ?? ("Nieznana", "questionmark")
        
        VStack {
            Text(element.weekday)
                .bold()
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 70 : 40))
            HStack {
                VStack(spacing: 30) {
                    Image(systemName: weatherIcon)
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 120 : 50))
                    Text(weatherDescription)
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 40 : 20))
                }
                .frame(width: 150, alignment: .leading)
                Spacer()
                    Text(currentTemperature)
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 140 : 80))
                        .fontWeight(.bold)
                        .padding()
            }
            HStack{
                WeatherRow(logo: "thermometer", name: "Min temp", value: minTemperature)
                Spacer()
                WeatherRow(logo: "thermometer", name: "Max temp", value: maxTemperature)
            }
            HStack {
                WeatherRow(logo: "wind", name: "Wind speed", value: windSpeed)
                Spacer()
                WeatherRow(logo: "humidity", name: "Humidity", value: "\(element.main.humidity.roundDouble())%")
            }
            HStack {
                WeatherRow(logo: "barometer", name: "Pressure", value: (element.main.pressure.roundDouble() + " hPa"))
                Spacer()
                WeatherRow(logo: "thermometer.sun", name: "Feels like", value: feelsTemperature)
            }
            HStack {
                WeatherRow(logo: "cloud.fill", name: "Cloudiness", value: ("\(element.clouds.all)%"))
                Spacer()
                WeatherRow(logo: "cloud.rain.fill", name: "Chance of rain", value: ("\(element.pop * 100)%"))
            }
        }
        .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? .infinity : 400, alignment: .leading)
        .padding()
        .foregroundColor(.black)
        .background(Color(hue: 0.333, saturation: 1, brightness: 1))
        .cornerRadius(20)
        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 80 : 0)
        .navigationBarTitle("More Details")
        Spacer()
    }
    
    private var windSpeed: String {
        let speed = element.wind.speed
        let convertedSpeed = convertSpeed(speed)
        return "\(convertedSpeed) \(speedUnitSymbol)"
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
    
    private var speedUnitSymbol: String {
        switch speedSettings.speedUnit {
        case .meters:
            return "m/s"
        case .kilometers:
            return "km/h"
        }
    }
    
    private var currentTemperature: String {
        let temperature = element.main.temp
        let convertedTemperature = convertTemperature(temperature)
        return "\(convertedTemperature) \(temperatureUnitSymbol)"
    }

    private var minTemperature: String {
        let temperature = element.main.temp_min
        let convertedTemperature = convertTemperature(temperature)
        return "\(convertedTemperature) \(temperatureUnitSymbol)"
    }

    private var maxTemperature: String {
        let temperature = element.main.temp_max
        let convertedTemperature = convertTemperature(temperature)
        return "\(convertedTemperature) \(temperatureUnitSymbol)"
    }
    
    private var feelsTemperature: String {
        let temperature = element.main.feelsLike
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
    
    private var temperatureUnitSymbol: String {
        switch temperatureSettings.temperatureUnit {
        case .celsius:
            return "°C"
        case .fahrenheit:
            return "°F"
        }
    }
}
