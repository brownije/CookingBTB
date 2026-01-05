import SwiftUI
import MapKit
import CoreLocation
import Combine

struct ShoppingMapView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var searchService = LocalSearchService()
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    private func distanceString(from userLocation: CLLocation?, to coordinate: CLLocationCoordinate2D) -> String {
        guard let userLocation = userLocation else { return "" }
        let placeLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let meters = userLocation.distance(from: placeLocation)
        let miles = meters / 1609.344
        if miles < 0.1 {
            // Show feet for very short distances
            let feet = meters * 3.28084
            return String(format: "%.0f ft away", feet)
        } else {
            return String(format: "%.1f mi away", miles)
        }
    }
    
    var body: some View {
        VStack {
            if let coordinate = locationManager.currentLocation?.coordinate {
                Map(initialPosition: .region(region)) {
                    // Show the user's location
                    UserAnnotation()
                    
                    // Annotations for search results
                    ForEach(searchService.results) { place in
                        Annotation(place.name, coordinate: place.coordinate) {
                            ZStack {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 24, height: 24)
                                Image(systemName: "cart")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 12, weight: .bold))
                            }
                        }
                    }
                }
                .onAppear {
                    region.center = coordinate
                }
                
                if searchService.isSearching {
                    ProgressView("Searching nearby grocery stores…")
                        .padding(.top, 8)
                } else if let message = searchService.errorMessage {
                    Text("Error: \(message)")
                        .foregroundStyle(.red)
                        .padding(.top, 8)
                } else {
                    List(searchService.results) { place in
                        Button {
                            place.mapItem.openInMaps(launchOptions: [
                                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
                            ])
                        } label: {
                            VStack(alignment: .leading) {
                                Text(place.name).font(.headline)
                                Text(distanceString(from: locationManager.currentLocation, to: place.coordinate))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            } else {
                VStack(spacing: 12) {
                    Text("We need your location to find nearby grocery stores.")
                        .multilineTextAlignment(.center)
                    Button("Allow Location") {
                        locationManager.requestAuthorization()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        .onReceive(locationManager.$currentLocation.compactMap { $0 }) { location in
            if searchService.results.isEmpty {
                searchService.searchGroceryStores(near: location.coordinate)
            }
            // Keep the map centered on the latest user location
            region.center = location.coordinate
        }
        .navigationTitle("Nearby Grocery Stores")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            locationManager.requestAuthorization()
        }
    }
}

#Preview {
    NavigationView { ShoppingMapView() }
}
