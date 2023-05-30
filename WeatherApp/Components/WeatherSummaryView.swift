import SwiftUI

struct WeatherSummaryView: View {
    var forecastEntries: [ForecastEntry] // Array of forecast entries
    
    var body: some View {
        VStack(spacing: 40) {
            VStack {
                Text("Max Temperature")
                    .font(.headline)
                    .padding(.bottom, 20)
                BarChart(dataPoints: getChartData(for: \.maxTemp), barColor: .red)
            }
            
            VStack {
                Text("Min Temperature")
                    .font(.headline)
                    .padding(.bottom, 20)
                BarChart(dataPoints: getChartData(for: \.minTemp), barColor: .blue)
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
                    RoundedRectangle(cornerRadius: 8)
                        .fill(barColor)
                        .frame(height: CGFloat(dataPoint.value) * 2)
                }
            }
        }
    }
}

