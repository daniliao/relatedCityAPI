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
    private let apiKey = "aweoifn1"
    
    func fetchCities(lat: Double, lon: Double) {
        // Define the bounding box (north, south, east, west)
        let boundingBox = "north=\(lat + 1.0)&south=\(lat - 1.0)&east=\(lon + 1.0)&west=\(lon - 1.0)"
        
        let url = URL(string: "http://api.geonames.org/citiesJSON?\(boundingBox)&maxRows=10&lang=en&username=\(apiKey)")!
        
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(CityResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.cities = decodedResponse.geonames.map {
                            City(name: $0.name, country: $0.countrycode, population: $0.population, latitude: $0.lat, longitude: $0.lng)
                        }
                    }
                }
            }
        }
        task.resume()
    }
}

struct CityResponse: Codable {
    let geonames: [CityData]
}

struct CityData: Codable {
    let name: String
    let countrycode: String
    let population: Int
    let lat: Double
    let lng: Double
}
