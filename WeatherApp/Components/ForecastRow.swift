import SwiftUI

struct ForecastRow: View {
    var element: ForecastListElement
    var weekdayFormatter = WeekdayFormatter()
    @EnvironmentObject var temperatureSettings: TemperatureSettings
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(element.weekday).font(.system(size: 28)).bold().padding([.trailing, .bottom, .top], 15)
            HStack {
                HStack {
                    Image(systemName: "thermometer")
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 80 : 40))
                    VStack(alignment: .leading, spacing: 8) {
                        Text("max/min temp")
                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 30 : 15))
                        
                        Text("\(maxTemperature)/\(minTemperature)")
                            .bold()
                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 40 : 25))
                    }
                }
                Spacer()
                HStack {
                    Image(systemName: "drop.fill")
                        .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 80 : 40))
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Chance of rain")
                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 30 : 15))
                        
                        Text("\((element.pop * 100).roundDouble())%")
                            .bold()
                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 40 : 25))
                    }
                }
            }.padding([.bottom], 15)
        }
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
