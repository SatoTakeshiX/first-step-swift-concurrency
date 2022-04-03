//
//  MainViewModel.swift
//  ConcurrencyForExistingApp
//
//  Created by satoutakeshi on 2022/04/02.
//

import UIKit

@MainActor
final class MainViewModel {

    let apiClient: APIClient

    var updateData: (NSDiffableDataSourceSnapshot<Section, RepositoryItem>) -> Void = { _ in }

    var showError: (APIClientError) -> Void = { _ in }

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
                    let newSnapshot = self.makeSnapshot(repositories: response.items)
                    self.updateData(newSnapshot)

                case .failure(let error):
                    self.showError(error)
            }
        }
    }

    func update() {
        Task {
            let newSnapshot = try await fetchDataByConcurrency()
            updateData(newSnapshot)
        }
    }

    nonisolated
    func fetchDataByConcurrency() async throws -> NSDiffableDataSourceSnapshot<Section, RepositoryItem> {

        let request = SearchRepositoryRequest(query: "swift")
        do {
            let response = try await apiClient.asyncRequest(with: request)
            guard let response = response else {
                throw APIClientError.noData
            }
            return await makeSnapshot(repositories: response.items)
        } catch {
            throw error
        }
    }

    func makeSnapshot(repositories: [Repository]) -> NSDiffableDataSourceSnapshot<Section, RepositoryItem> {

        let items = repositories.map {
            RepositoryItem(repository: $0, image: nil)
        }

        var snapshot = NSDiffableDataSourceSnapshot<Section, RepositoryItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        return snapshot
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

    nonisolated
    func fetchImageByCuncurrency(item: RepositoryItem) async throws -> UIImage? {
        guard let url = URL(string: item.repository.owner.avatarUrl) else {
            return nil
        }
        let request = URLRequest(url: url)

        do {
            let data = try await apiClient.asyncRequestData(with: request)
            guard let data = data else { throw APIClientError.noData }
            return UIImage(data: data)
        } catch {
            throw error
        }
    }
}
