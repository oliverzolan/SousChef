//
//  ScannedIngredientsView.swift
//  SousChef
//
//  Created by Bennet Rau on 11/25/24.
//

import UIKit
import SwiftUI

class ScannedIngredientsViewController: UIViewController {
    var scannedItems: [String] = ["Apple", "Banana", "Carrot"] // Dummy data for debugging

    private let tableView = UITableView()
    private let titleView = UIView()
    private let titleLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "Background") ?? .systemBackground
        setupTitleView()
        setupTableView()
    }

    private func setupTitleView() {
        titleView.backgroundColor = UIColor(named: "GradientStart") ?? .systemBlue
        titleView.layer.cornerRadius = 30
        titleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        titleView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleView)
        
        titleLabel.text = "Scanned Ingredients"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: view.topAnchor),
            titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleView.heightAnchor.constraint(equalToConstant: 120),
            
            titleLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor)
        ])
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 20
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension ScannedIngredientsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scannedItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        let containerView = UIView()
        containerView.layer.cornerRadius = 10
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.backgroundColor = UIColor(named: "CardBackground") ?? .white
        
        cell.contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = scannedItems[indexPath.row]
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor(named: "CardText") ?? .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8),
            
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16)
        ])
        
        return cell
    }
}


struct ScannedIngredientsPreview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ScannedIngredientsViewController {
        return ScannedIngredientsViewController()
    }

    func updateUIViewController(_ uiViewController: ScannedIngredientsViewController, context: Context) {
        // No updates needed for this simple preview
    }
}

struct ScannedIngredientsViewController_Previews: PreviewProvider {
    static var previews: some View {
        ScannedIngredientsPreview()
            .previewDevice("iPhone 14") // Specify a device for preview
    }
}
