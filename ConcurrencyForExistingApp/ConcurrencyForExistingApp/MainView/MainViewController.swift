//
//  MainViewController.swift
//  ConcurrencyForExistingApp
//
//  Created by satoutakeshi on 2022/04/02.
//

import UIKit

final class MainViewController: UIViewController {

    private static let cellIdentifier = "CellIdentifier"

    @IBOutlet private weak var tableView: UITableView!

    // Expression requiring global actor 'MainActor' cannot appear in default-value expression of property 'viewModel'; this is an error in Swift 6
    //private let viewModel = MainViewModel()

    private let viewModel: MainViewModel

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.viewModel = MainViewModel()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = MainViewModel()
        super.init(coder: coder)
    }

    private lazy var dataSource: UITableViewDiffableDataSource<Section, RepositoryItem> = {
        let dataSource = UITableViewDiffableDataSource<Section, RepositoryItem>(tableView: tableView) { [weak self] (tableView, indexPath, item) -> UITableViewCell? in
            guard let self = self else { return nil }
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier, for: indexPath) as? SubtitleTableCell else {
                return nil
            }

            cell.selectionStyle = .none
            cell.textLabel?.text = item.repository.name
            cell.detailTextLabel?.text = item.repository.description

            Task {
                let image = try await self.viewModel.fetchImageByCuncurrency(item: item)
                cell.imageView?.image = image
            }

//            self.viewModel.fetchImage(item: item) { image in
//                cell.imageView?.image = image
//            }

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
        // viewModel.fetchData()
        viewModel.update()
    }
}

