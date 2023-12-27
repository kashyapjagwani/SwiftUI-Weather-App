# SwiftUI Weather App

This SwiftUI-based weather app fetches a list of cities, displaying them in a list view. Once a city is selected, it retrieves the city's individual details and uses its latitude and longitude coordinates to fetch the real-time weather data for that city. The initial list of cities is limited to 25, but users can utilize the search functionality to look for any city globally.

## Screenshots
![Simulator Screen Shot - iPhone 14 Pro - 2023-12-26 at 18 08 03](https://github.com/kashyapjagwani/SwiftUI-Weather-App/assets/34401678/6ff1e3c1-f583-4596-b97b-ee63325a4549)

![Simulator Screen Shot - iPhone 14 Pro - 2023-12-26 at 18 08 28](https://github.com/kashyapjagwani/SwiftUI-Weather-App/assets/34401678/0982d837-a663-4b27-a598-b3e3f7b83a57)

![Simulator Screen Shot - iPhone 14 Pro - 2023-12-26 at 18 08 50](https://github.com/kashyapjagwani/SwiftUI-Weather-App/assets/34401678/eaacedac-7fb9-4ec5-a7e5-c1b90e206765)

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
