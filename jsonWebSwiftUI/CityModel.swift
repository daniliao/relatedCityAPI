//
//  CityModel.swift
//  jsonWebSwiftUI
//
//  Created by Daniel on 4/1/25.
//
import SwiftUI



struct City: Identifiable {
    let id = UUID()
    let name: String
    let country: String
    let population: Int
    let latitude: Double
    let longitude: Double
}
