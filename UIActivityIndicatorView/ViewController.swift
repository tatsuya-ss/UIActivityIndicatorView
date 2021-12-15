//
//  ViewController.swift
//  UIActivityIndicatorView
//
//  Created by 坂本龍哉 on 2021/12/15.
//

import UIKit

final class ViewController: UIViewController {

    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var resultLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        stopIndicator()
    }
    
    private func startIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        view.alpha = 0.5
    }
    
    private func stopIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        view.alpha = 1.0
    }
}

// MARK: -
extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text,
              !text.isEmpty,
              let url = URL(string: "https://api.github.com/users/\(text)") else { return }
        startIndicator()
        Task {
            do {
                let result = try await GitHubModel().fetch(url: url)
                resultLabel.text = result.name
                locationLabel.text = result.location
                stopIndicator()
            } catch {
                print(error)
                stopIndicator()
            }
        }
    }
    
}

// MARK: - model

enum GitHubError: Error {
    case fetchError
}

struct GitHub: Decodable {
    let name: String
    let location: String?
}

struct GitHubModel {
    func fetch(url: URL) async throws -> GitHub {
            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                      throw GitHubError.fetchError
                  }
            do {
                let result = try JSONDecoder().decode(GitHub.self, from: data)
                sleep(2)
                return result
            } catch {
                throw GitHubError.fetchError
            }
    }
}
