//
//  Search.swift
//  jsonWebSwiftUI
//
//  Created by Daniel on 4/1/25.
//


import SwiftUI
import MapKit
import CoreLocation

struct CitySearchView: View {
    @State private var cityName = ""
    @State private var city: City?
    @ObservedObject var viewModel = CityViewModel()
    @State private var region: MKCoordinateRegion?

    var body: some View {
        VStack {
            TextField("Enter city name", text: $cityName)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    fetchCityCoordinates()
                }
            
            List(viewModel.cities) { city in
                Button(action: {
                    self.selectCity(city)
                }) {
                    VStack(alignment: .leading) {
                        Text(city.name)
                        Text(city.country).font(.subheadline).foregroundColor(.gray)
                        Text("Population: \(city.population)").font(.subheadline)
                    }
                }
            }
            
            // Use a conditional statement to unwrap the region
            if let unwrappedRegion = region {
                Map(coordinateRegion: Binding(
                    get: { unwrappedRegion },
                    set: { newRegion in
                        region = newRegion
                    }
                ))
                .frame(height: 300)
            }
        }
        .padding()
    }

    func fetchCityCoordinates() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(cityName) { (placemarks, error) in
            if let placemark = placemarks?.first,
               let location = placemark.location {
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
                viewModel.fetchCities(lat: latitude, lon: longitude)
                self.region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                )
            }
        }
    }

    func selectCity(_ city: City) {
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: city.latitude, longitude: city.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    }
}
