//
//  MainViewModel.swift
//  ConcurrencyForExistingApp
//
//  Created by satoutakeshi on 2022/04/02.
//

import UIKit

final class MainViewModel {

    let apiClient: APIClient

    var updateData: (NSDiffableDataSourceSnapshot<Section, RepositoryItem>) -> Void = { _ in }

    var showError: (APIClientError) -> Void = { _ in }

    var currentSnapshot = NSDiffableDataSourceSnapshot<Section, RepositoryItem>() {
        didSet {
            updateData(currentSnapshot)
        }
    }

    init(apiClient: APIClient = APIClient(session: URLSession.shared)) {
        self.apiClient = apiClient
    }

    func fetchData() {
        let request = SearchRepositoryRequest(query: "swift")
        apiClient.request(with: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let response):
                    guard let response = response else {
                        self.showError(.noData)
                        return
                    }
                    self.makeRepositories(repositories: response.items)

                case .failure(let error):
                    self.showError(error)
            }
        }
    }

    func makeRepositories(repositories: [Repository]) {

        let items = repositories.map {
            RepositoryItem(repository: $0, image: nil)
        }

        var snapshot = NSDiffableDataSourceSnapshot<Section, RepositoryItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)

        currentSnapshot = snapshot
    }

    func fetchImage(item: RepositoryItem, completion: @escaping (UIImage?) -> Void) {

        guard let url = URL(string: item.repository.owner.avatarUrl) else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        let request = URLRequest(url: url)

        apiClient.requestData(with: request) { result in
            switch result {
                case .success(let data):
                    guard let data = data else {
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                        return
                    }
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        completion(image)
                    }
                case .failure:
                    DispatchQueue.main.async {
                        completion(nil)
                    }
            }
        }
    }
}
