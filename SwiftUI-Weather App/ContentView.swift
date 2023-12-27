//
//  ContentView.swift
//  SwiftUI-Weather App
//
//  Created by Kashyap Jagwani on 12/10/23.
//

import SwiftUI

let hour = Calendar.current.component(.hour, from: Date())

enum WeatherSymbols: String {
    case cloud = "cloud.fill"
    case sun = "sun.max.fill"
    case moon = "moon.fill"
    case smoke = "smoke.fill"
    case snow = "snowflake"
    case rain = "cloud.rain.fill"
    case thunder = "cloud.bolt.rain.fill"
}

func getWeatherSymbolName(for id: Int) -> WeatherSymbols {
    switch id {
    case 800...:
        return .cloud
    case 800:
        return hour < 5 && hour > 16 ? .moon : .sun
    case 700...800:
        return .smoke
    case 600...700:
        return .snow
    case 300...600:
        return .rain
    case 200...300:
        return .thunder
    default:
        return hour < 5 && hour > 16 ? .moon : .sun
    }
}

struct ContentView: View {
    
    @State private var isFetchingCities: Bool = false
    @State private var isFetchingWeather: Bool = false
    @State private var cities: Cities?
    @State private var cityResponse: CityDetails?
    @State private var openWeather: OpenWeather?
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            if let cities = cities {
                List {
                    Section {
                        ForEach(cities.embedded.citySearchResults, id: \.id) { city in
                            NavigationLink(value: city) {
                                let components = city.matchingFullName.components(separatedBy: ", ")
                                if let cityName = components.first, let countryName = components.last {
                                    Text("\(cityName), \(countryName)")
                                }
                                else
                                {
                                    Text(city.matchingFullName)
                                }
                            }
                        }
                    }
                }
                .searchable(text: $searchText)
                .onChange(of: searchText) { value in
                    Task {
                        if !value.isEmpty &&  value.count > 3 {
                            do {
                                self.cities = try await getCities(search: value)
                            } catch {
                                print(error)
                            }
                        } else {
                            self.cities = try await getCities(search: "")
                        }
                    }
                }
                .navigationTitle("Cities")
                .navigationDestination(for: CityItem.self) {city in
                    ZStack{
                        BackgroundView()
                        if(isFetchingWeather) {
                            VStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(2)
                            }
                        } else {
                            CityWeatherView(
                                city: city.matchingFullName,
                                id: openWeather?.weather[0].id ?? 0,
                                temp: openWeather?.main.temp ?? -99,
                                tempMin: openWeather?.main.tempMin ?? -99,
                                tempMax: openWeather?.main.tempMax ?? 99,
                                main: openWeather?.weather[0].main ?? "Weather not available",
                                windSpeed: openWeather?.wind.speed ?? 0,
                                humidity: openWeather?.main.humidity ?? 0
                            )
                        }
                    }
                    .task {
                        do {
                            cityResponse = try await getCity(endpoint: city.links.cityItem.href)
                            if let latitude = cityResponse?.location.latlon.latitude,
                               let longitude = cityResponse?.location.latlon.longitude {
                                do {
                                    openWeather = try await getWeather(lat: latitude, lng: longitude)
                                } catch {
                                    // Handle error from getWeather function
                                    print("Error fetching weather: \(error)")
                                }
                            } else {
                                // Handle the case where cityResponse or its latitude/longitude is nil
                            }
                            isFetchingWeather = false
                        } catch APIError.invalidUrl {
                            print("invalid URL")
                        } catch APIError.invalidResponse {
                            print("invalid response")
                        } catch APIError.invalidData {
                            print("invalid data")
                        } catch {
                            print("unexpected error")
                        }
                    }
                }
            } else {
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(2)
                }
            }
        }
        .task {
            do {
                cities = try await getCities()
                isFetchingCities = false
            } catch APIError.invalidUrl {
                print("invalid URL")
            } catch APIError.invalidResponse {
                print("invalid response")
            } catch APIError.invalidData {
                print("invalid data")
            } catch {
                print("unexpected error")
            }
        }
        .accentColor(.white)
    }
    
    func getCities(search: String = "") async throws -> Cities {
        isFetchingCities = true
//        let endpoint = "https://api.teleport.org/api/cities?search=\(search)"
        
        var components = URLComponents(string: "https://api.teleport.org/api/cities/")!
        components.queryItems = [
            URLQueryItem(name: "search", value: search)
        ]
        
        guard let URL = components.url else {
            throw APIError.invalidUrl
        }
        
        let (data, response) = try await URLSession.shared.data(from: URL)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(Cities.self, from: data)
        } catch {
            print(error)
            throw APIError.invalidData
        }
    }
    
    func getCity(endpoint: String) async throws -> CityDetails {
        print(endpoint)
        isFetchingWeather = true
        
        guard let URL = URL(string: endpoint) else {
            throw APIError.invalidUrl
        }
        
        let (data, response) = try await URLSession.shared.data(from: URL)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        do {
            print(response)
            let decoder = JSONDecoder()
            return try decoder.decode(CityDetails.self, from: data)
        } catch {
            print("\(error)")
            throw APIError.invalidData
        }
    }
    
    func getWeather(lat: Double, lng: Double) async throws -> OpenWeather {
        isFetchingWeather = true
        print(lat, lng)
        let endpoint = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lng)&appid=e6348f6d5135065c505e600a56f91f39&units=metric"
        
        guard let URL = URL(string: endpoint) else {
            throw APIError.invalidUrl
        }
        
        let (data, response) = try await URLSession.shared.data(from: URL)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(OpenWeather.self, from: data)
        } catch {
            print("\(error)")
            throw APIError.invalidData
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct WeatherDayView: View {
    var day: String
    var img: String
    var temp: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(day)
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundColor(.white)
            Image(systemName: img)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            Text("\(temp)°")
                .font(.system(size: 32, weight: .medium, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

struct BackgroundView: View {
    var topCol: Color {
        hour < 5 || hour > 16 ? Color("darkBlue") : Color(.blue)
    }
    var bottomCol: Color {
        hour < 5 || hour > 16 ? Color(.darkGray) : Color("lightBlue");
    }
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [topCol, bottomCol]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ).edgesIgnoringSafeArea(.all)
    }
}

struct CityWeatherView: View {
    var city: String
    var id: Int
    var temp: Double
    var tempMin: Double
    var tempMax: Double
    var main: String
    var windSpeed: Double
    var humidity: Double
    
    var body: some View {
        VStack {
            VStack{
                Text(city.components(separatedBy: ", ").first ?? city)
                    .font(.system(size: 32, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack() {
                    VStack {
                        Image(systemName: getWeatherSymbolName(for: id).rawValue)
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                        Text(main)
                            .font(.system(size: 22, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("\(String(format: "%.0f", temp))°")
                        .font(.system(size: 84, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            Spacer()
            AsyncImage(url: URL(string: "https://cdn.pixabay.com/photo/2020/01/24/21/33/city-4791269_960_720.png")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 350)
            } placeholder: {
                ProgressView()
            }
            Spacer()
            VStack(spacing: 16) {
                Text("Weather now")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                HStack {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "thermometer.low")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color("darkBlue"))
                        }
                        VStack(alignment: .leading) {
                            Text("Min Temp")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                            Text("\(String(format: "%.0f", tempMin))°")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                    }
                    Spacer()
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "thermometer.high")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color("darkBlue"))
                        }
                        VStack(alignment: .leading) {
                            Text("Max Temp")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                            Text("\(String(format: "%.0f", tempMax))°")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                    }
                }
                HStack {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "wind")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color("darkBlue"))
                        }
                        VStack(alignment: .leading) {
                            Text("Wind Speed")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                            Text("\(String(format: "%.0f", windSpeed)) m/s")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                    }
                    Spacer()
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "humidity")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color("darkBlue"))
                        }
                        VStack(alignment: .leading) {
                            Text("Humidity")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                            Text("\(String(format: "%.0f", humidity))%")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity,  alignment: .leading)
            .padding(.all)
            .background(Color.white)
            .foregroundColor(Color("darkBlue"))
        }
    }
}

// structs

struct Cities: Codable {
    let embedded: Embedded
    
    private enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
    }
}

struct Embedded: Codable {
    let citySearchResults: [CityItem]
    
    private enum CodingKeys: String, CodingKey {
        case citySearchResults = "city:search-results"
    }
}

struct CityItem: Codable, Identifiable {
    let id = UUID()
    let links: CityLinks
    let matchingFullName: String
    
    private enum CodingKeys: String, CodingKey {
        case links = "_links"
        case matchingFullName = "matching_full_name"
    }
}

extension CityItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CityItem, rhs: CityItem) -> Bool {
        return lhs.id == rhs.id
    }
}

struct CityLinks: Codable {
    let cityItem: CityItemLink
    
    private enum CodingKeys: String, CodingKey {
        case cityItem = "city:item"
    }
}

struct CityItemLink: Codable {
    let href: String
}

struct CityDetails: Codable {
    let location: Location

    struct Location: Codable {
        let geohash: String
        let latlon: LatLon
        
        struct LatLon: Codable {
            let latitude: Double
            let longitude: Double
        }
    }
}

struct OpenWeather: Codable {
    let main: Main
    let weather: [Weather]
    let wind: Wind
}

struct Main: Codable {
    let temp: Double
    let humidity: Double
    let tempMin: Double
    let tempMax: Double
    
    private enum CodingKeys: String, CodingKey {
        case temp, humidity
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
}

struct Wind: Codable {
    let speed: Double
}

enum APIError: Error {
    case invalidUrl
    case invalidResponse
    case invalidData
}
