import Foundation
import Combine
import MapKit

struct Place: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let mapItem: MKMapItem
}

final class LocalSearchService: ObservableObject {
    @Published var results: [Place] = []
    @Published var isSearching = false
    @Published var errorMessage: String?
    
    func searchGroceryStores(near coordinate: CLLocationCoordinate2D) {
        isSearching = true
        errorMessage = nil
        results = []
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Grocery Store"
        request.resultTypes = .pointOfInterest
        request.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            DispatchQueue.main.async {
                self?.isSearching = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                guard let response = response else { return }
                self?.results = response.mapItems.compactMap { item in
                    let coordinate = item.location.coordinate
                    let displayName: String = {
                        if let name = item.name, !name.isEmpty { return name }
                        if let address = item.address { return address.description }
                        return "Unknown"
                    }()
                    
                    return Place(name: displayName, coordinate: coordinate, mapItem: item)
                }
            }
        }
    }
}

