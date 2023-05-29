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
            return ForecastEntry(weekday: entry.weekday,
                                 maxTemp: entry.main.temp_max,
                                 minTemp: entry.main.temp_min)
        }
    }
    
    var body: some View {
        //if (locationManager.location != nil && !locationManager.isLoading) {
        NavigationView {
            VStack {
                //if(forecast != nil && !isLoading) {
                    ZStack {
                        Color(hue: 0.333, saturation: 1, brightness: 1)
                        VStack{
                        Text("\(forecast?.city.name ?? "")")
                            .bold()
                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 70 : 30))
                            .foregroundColor(Color.black)
                        }
                    }
                    .frame(maxHeight: UIDevice.current.userInterfaceIdiom == .pad ? 200 : 80, alignment: .leading)
                ZStack {
                    //Color(hue: 0.333, saturation: 1, brightness: 1)
                        VStack{
                        Button(action: {
                            showWeatherSummary = true
                        }){
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
                if(forecast != nil && !isLoading) {
                    ForecastListView(forecast: forecast!)
                        //.navigationBarItems(trailing: Button(action: {
                          //      showWeatherSummary = true
                            //}){
                              //  Image(systemName: "info.circle")
                            //})
                    //.sheet(isPresented: $showWeatherSummary) {
                      //  WeatherSummaryView(forecastEntries: forecastEntries)
                    //}
                }
                else if (isLoading) {
                    LoadingView()
                }
                else {
                    Text("Error while loading weather")
                }
            }.onAppear {
                Task { await loadWeatherForecast(location: locationManager.location!) }
            }
            .toolbar{
                Button(action: {
                showWeatherSummary = true
                }) {
                    Text("Temperature Graph")
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showWeatherSummary) {
            WeatherSummaryView(forecastEntries: forecastEntries)
        }
        //else if (locationManager.isLoading) {
            //LoadingView()
        //}
        //else {
            //Text("Error while loading location")
        //}
    }
}

struct ForecastView_Previews: PreviewProvider {
    static var previews: some View {
        ForecastView()
    }
}

