//
//  ViewController.swift
//  ConcurrencyForExistingApp
//
//  Created by satoutakeshi on 2022/04/02.
//

import UIKit

final class MainViewController: UIViewController {

    private static let cellIdentifier = "CellIdentifier"

    @IBOutlet private weak var tableView: UITableView!

    private let viewModel = MainViewModel()

    private lazy var dataSource: UITableViewDiffableDataSource<Section, RepositoryItem> = {
        let dataSource = UITableViewDiffableDataSource<Section, RepositoryItem>(tableView: tableView) { [weak self] (tableView, indexPath, item) -> UITableViewCell? in
            guard let self = self else { return nil }
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier, for: indexPath) as? SubtitleTableCell else {
                return nil
            }

            cell.selectionStyle = .none
            cell.textLabel?.text = item.repository.name
            cell.detailTextLabel?.text = item.repository.description

            self.viewModel.fetchImage(item: item) { image in
                cell.imageView?.image = image
            }

            return cell

        }
        return dataSource
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        bind()
        fetchData()
    }

    private func setup() {
        tableView.register(SubtitleTableCell.self, forCellReuseIdentifier: Self.cellIdentifier)
        tableView.dataSource = dataSource

        title = "GitHubリポジトリー"
    }

    private func bind() {
        viewModel.updateData = { [weak self] snapshot in
            guard let self = self else { return }
            self.dataSource.apply(snapshot)
        }
    }

    private func fetchData() {
        viewModel.fetchData()
    }
}

