//
//  RepositoryItem.swift
//  ConcurrencyForExistingApp
//
//  Created by satoutakeshi on 2022/04/02.
//

import UIKit

struct RepositoryItem: Hashable {
    let repository: Repository
    let image: UIImage?

    func update(image: UIImage?) -> Self {
        RepositoryItem(repository: self.repository, image: image)
    }
}
