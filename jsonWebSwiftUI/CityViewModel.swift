//
//  CityViewModel.swift
//  jsonWebSwiftUI
//
//  Created by Daniel on 4/1/25.
//

import SwiftUI
import MapKit
import CoreLocation

class CityViewModel: ObservableObject {
    @Published var cities: [City] = []
    
    func fetchCities(lat: Double, lon: Double) {
        guard let url = buildCityURL(lat: lat, lon: lon) else {
            return
        }
        fetchCityData(url)
    }
    
    private func buildCityURL(lat: Double, lon: Double) -> URL? {
        let boundingBox = "north=\(lat + 1.0)&south=\(lat - 1.0)&east=\(lon + 1.0)&west=\(lon - 1.0)"
        let urlString = "http://api.geonames.org/citiesJSON?\(boundingBox)&maxRows=10&lang=en&username=aweoifn1"
        return URL(string: urlString)
    }
    
    private func fetchCityData(_ url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            self.parseCityData(data)
        }.resume()
    }
    
    private func parseCityData(_ data: Data) {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let geonames = jsonObject["geonames"] as? [[String: Any]] else { return }
        
        let cities = geonames.compactMap { self.createCity(from: $0) }
        
        DispatchQueue.main.async {
            self.cities = cities
        }
    }
    
    private func createCity(from cityDict: [String: Any]) -> City? {
        guard let name = cityDict["name"] as? String,
              let country = cityDict["countrycode"] as? String,
              let population = cityDict["population"] as? Int,
              let lat = cityDict["lat"] as? Double,
              let lon = cityDict["lng"] as? Double else { return nil }
        
        return City(name: name, country: country, population: population, latitude: lat, longitude: lon)
    }
}
