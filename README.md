# SwiftUI Weather App

This SwiftUI-based weather app fetches a list of cities, displaying them in a list view. Once a city is selected, it retrieves the city's individual details and uses its latitude and longitude coordinates to fetch the real-time weather data for that city. The initial list of cities is limited to 25, but users can utilize the search functionality to look for any city globally.

## Screenshots
![WeatherApp Screenshot](https://github.com/kashyapjagwani/SwiftUI-Weather-App/assets/34401678/54c14b66-f3f8-4f32-b2cc-21b55d15511e)


## Features

- City List View: Displays a list of cities limited to 25 items initially.
- Search Bar: Allows users to search for cities across the globe.
- Weather Details: Shows real-time weather information for a selected city.

## Functionality

### Weather Symbols
The app displays various weather symbols (SF Symbols) based on the real-time weather conditions fetched from the OpenWeather API.

### Fetching Data

1. Cities

- The app fetches city data using the Teleport API based on the user's search query. It populates the city list and allows users to select a specific city for more details.

2. Weather

- It fetches weather information from the OpenWeather API using the latitude and longitude coordinates of the selected city. This data includes temperature, humidity, wind speed, and more.

## Technologies Used

- SwiftUI
- URLSession for API interactions
- JSONDecoder for data parsing

## How to Use

To run this app on your local machine:
1. Clone this repository.
2. Open the project in Xcode.
3. Build and run the project on a simulator or a physical device.

## Requirements

1. Xcode 13 or later
2. Swift 5.5 or later

## License

This project is licensed under the [MIT License](LICENSE).

---

Feel free to modify this README to suit your specific requirements or update it with additional sections or details about the project.
