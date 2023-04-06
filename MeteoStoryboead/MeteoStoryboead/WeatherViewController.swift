//
//  ViewController.swift
//  MeteoStoryboead
//
//  Created by Kateřina Černá on 06.04.2023.
//

import UIKit

class WeatherViewController: UIViewController, UITableViewDataSource {

    let apiUrl = "https://api.open-meteo.com/v1/forecast?latitude=48.9841611&longitude=14.4727092&current_weather=true&hourly=temperature_2m,relativehumidity_2m,windspeed_10m"

    var weatherData: [Weather] = []

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.bounds)
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)

        fetchData()
    }

    func fetchData() {
        guard let url = URL(string: apiUrl) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let result = try JSONDecoder().decode(WeatherData.self, from: data)
                self.weatherData = result.data
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch let error {
                print(error)
            }
        }.resume()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let weather = weatherData[indexPath.row]

        cell.textLabel?.text = "\(weather.hour):00 - Temperature: \(weather.temperature)°C, Humidity: \(weather.humidity)% , Wind speed: \(weather.windSpeed) m/s"

        if indexPath.row == 0 {
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        } else {
            cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        }

        return cell
    }
}

struct WeatherData: Codable {
    let data: [Weather]
}

struct Weather: Codable {
    let hour: Int
    let temperature: Double
    let humidity: Double
    let windSpeed: Double

    enum CodingKeys: String, CodingKey {
        case hour = "time_local"
        case temperature = "temperature_2m"
        case humidity = "relativehumidity_2m"
        case windSpeed = "windspeed_10m"
    }
}

