import SwiftUI

struct WeatherSummaryView: View {
    var forecastEntries: [ForecastEntry] // Array of forecast entries
    
    var body: some View {
        VStack(spacing: 30) {
            VStack {
                Text("Max Temperature")
                    .font(.system(size: 24))
                    .font(.headline)
                    .padding(.bottom, 20)
                ScrollView(.vertical) {
                    BarChart(dataPoints: getChartData(for: \.maxTemp), barColor: .red)
                }
                .frame(height: 300)
            }
            
            VStack {
                Text("Min Temperature")
                    .font(.system(size: 24))
                    .font(.headline)
                    .padding(.bottom, 20)
                ScrollView(.vertical) {
                    BarChart(dataPoints: getChartData(for: \.minTemp), barColor: .blue)
                }
                .frame(height: 300)
            }
        }
        .padding()
    }
    
    private func getChartData(for keyPath: KeyPath<ForecastEntry, Double>) -> [ChartDataPoint] {
        return forecastEntries.map { (entry) in
            return ChartDataPoint(label: entry.weekday, value: entry[keyPath: keyPath])
        }
    }
}


struct ChartDataPoint: Identifiable {
    var id = UUID()
    var label: String
    var value: Double
}

struct BarChart: View {
    var dataPoints: [ChartDataPoint] // Array of chart data points
    var barColor: Color // Color of the chart bars
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(dataPoints) { dataPoint in
                HStack {
                    Text(dataPoint.label)
                        .frame(width: 80, alignment: .trailing)
                        .foregroundColor(Color(hue: 0.333, saturation: 1, brightness: 1))
                    RoundedRectangle(cornerRadius: 8)
                        .fill(barColor)
                        //.frame(height: CGFloat(dataPoint.value) * 2)
                        .frame(height: 50)
                    Text("\(Int(dataPoint.value))")
                        .foregroundColor(.white)
                }
            }
        }
    }
}

