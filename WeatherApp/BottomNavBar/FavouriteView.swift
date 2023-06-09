import SwiftUI
import CoreLocation
import UIKit
import Network

extension String {
    func cutSpaces(using chRcterSet: CharacterSet = .whitespacesAndNewlines) -> String {
        return trimmingCharacters(in: chRcterSet)
    }
}

struct FavouriteView: View {
    @State private var locationName = ""
    @StateObject private var favouriteLocationManager = FavouriteLocationManager()
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject var sharedText: SharedText
    @FocusState private var isFocused: Bool
    @Binding var selection: Int
    @State private var showAlert = false

    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            if(showAlert == false) {
                Text("Locations")
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 70 : 40))
                    .fontWeight(.bold)
                    .padding(UIDevice.current.userInterfaceIdiom == .pad ? 80 : 20)
                
                List {
                    ForEach(favouriteLocationManager.locations) { location in
                        
                        Text(location.name)
                            .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 30 : 20))
                            .fontWeight(.medium)
                            .padding(UIDevice.current.userInterfaceIdiom == .pad ? 30 : 10)
                            .foregroundColor(Color(hue: 0.333, saturation: 1, brightness: 1))
                            .onTapGesture {
                                Task { await selectLocation(city: location.name) }
                                print(location.name)
                                sharedText.text = location.name
                                selection = 1 // Switch to WeatherView
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    removeLocation(location: location)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                    }
                    .onDelete(perform: removeLocations)
                }
                .listStyle(.insetGrouped)
                .background(Color(hue: 1, saturation: 1, brightness: 1))
                .preferredColorScheme(.dark)
                
                Divider()
                
                HStack {
                    TextField("Enter city name", text: $locationName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isFocused)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .foregroundColor(Color.white)
                    Button(action: {
                        var replaced = locationName.cutSpaces()
                        replaced = (replaced as NSString).replacingOccurrences(of: " ", with: "+")
                        print (replaced+"dasdas")
                        let correct = replaced.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                        favouriteLocationManager.addLocation(correct)
                        locationName = ""
                        isFocused = false
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .frame(width: 50, height: 50)
                    .background(Color.black)
                    .clipShape(Circle())
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                }
                .background(Color(hue: 0.333, saturation: 1, brightness: 1))
                .preferredColorScheme(.dark)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom)
                
            }
            else {
                ZStack {
                    Text("Error while loading weather")
                }
                .background(Color.black)
            }
        }
        .onAppear{checkInternetConnection()}
        .navigationBarItems(trailing: EditButton())
        .background(Color.black)
        .preferredColorScheme(.dark)
        .foregroundColor(Color(hue: 0.333, saturation: 1, brightness: 1))
    }

    func selectLocation(city: String) async {
        var cityName = city
        if cityName == "Łódź Voivodeship" {
            cityName = "Łódź"
        }
        sharedText.text = cityName
        print (cityName)

        do {
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
               let hostingController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                
                try await locationManager.requestLocationByCity(city: cityName, presentingViewController: hostingController)
            }
        } catch let error as CLError {
            if error.code == .locationUnknown {
                print("Error: Invalid location provided")
                showAlert = true
            } else {
                print("Error \(error)")
            }
        } catch {
            print("Error: \(error)")
        }
    }

    func removeLocation(location: Location) {
        if let index = favouriteLocationManager.locations.firstIndex(where: { $0.id == location.id }) {
            favouriteLocationManager.locations.remove(at: index)
            favouriteLocationManager.saveLocations()
        }
    }

    func removeLocations(at offsets: IndexSet) {
        favouriteLocationManager.locations.remove(atOffsets: offsets)
        favouriteLocationManager.saveLocations()
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
