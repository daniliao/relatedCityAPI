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
    @State private var selectedCity: City?
    @ObservedObject var vm = CityViewModel()
    @State private var region: MKCoordinateRegion?

    var body: some View {
        VStack {
            searchField
                .padding(.horizontal)
                .padding(.top, 50)

            mapView
                .padding(.vertical, 10)

            cityList
                .padding(.top, 10)
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
        .edgesIgnoringSafeArea(.all)
    }

    private func updateRegion(lat: Double, lon: Double) {
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    }

    private func choseCity(_ city: City) {
        updateRegion(lat: city.latitude, lon: city.longitude)
    }
    
    private var searchField: some View {
        TextField("Enter city name", text: $cityName)
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: Color.gray.opacity(0.2), radius: 8, x: 0, y: 4)
            .font(.system(size: 16))
            .autocapitalization(.words)
            .padding(.horizontal, 20)
            .onSubmit {
                fetchCoordinates()
            }
    }

    private var mapView: some View {
        Group {
            if let unwrappedRegion = region {
                Map(coordinateRegion: Binding(
                    get: { unwrappedRegion },
                    set: { newRegion in
                        region = newRegion
                    }
                ))
                .frame(height: 300)
                .cornerRadius(20)
                .shadow(radius: 10)
            } else {
                Text("Search to visit a city")
                    .foregroundColor(.gray)
                    .font(.headline)
                    .padding()
            }
        }
    }

    private func fetchCoordinates() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(cityName) { (placemarks, error) in
            if let placemark = placemarks?.first,
               let location = placemark.location {
                let lat = location.coordinate.latitude
                let lon = location.coordinate.longitude
                vm.fetchCities(lat: lat, lon: lon)
                updateRegion(lat: lat, lon: lon)
            }
        }
    }

    private var cityList: some View {
        List(vm.cities) { city in
            Button(action: {
                choseCity(city)
            }) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(city.name)
                            .font(.headline)
                            .foregroundColor(.black)
                        Text(city.country)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("Pop: \(city.population)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.gray.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .listStyle(PlainListStyle())
    }
}
