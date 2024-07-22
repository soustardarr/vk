//
//  NewsFeedTableView.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 20.04.2024.
//

import UIKit

protocol NewsFeedTableViewDelegate: AnyObject {
    func didReloadDataButtonTapped()
}

class NewsFeedTableView: UIView {

    weak var delegate: NewsFeedTableViewDelegate?

    var newsFeedTable: UITableView = {
        let newsFeedTableView = UITableView()
        newsFeedTableView.backgroundColor = .white
        newsFeedTableView.separatorStyle = .singleLine
        newsFeedTableView.translatesAutoresizingMaskIntoConstraints = false
        return newsFeedTableView
    }()

    var reloadDataButton: UIButton = {
        let reloadDataButton = UIButton()
        reloadDataButton.backgroundColor = .systemBlue
        reloadDataButton.clipsToBounds = true
        reloadDataButton.layer.cornerRadius = 10
        reloadDataButton.addTarget(nil, action: #selector(didReloadDataButtonTapped), for: .touchUpInside)
        reloadDataButton.setTitle("Обновить ленту", for: .normal)
        reloadDataButton.translatesAutoresizingMaskIntoConstraints = false
        return reloadDataButton
    }()

    @objc func didReloadDataButtonTapped() {
        delegate?.didReloadDataButtonTapped()
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(newsFeedTable)
        addSubview(reloadDataButton)

        NSLayoutConstraint.activate([
            reloadDataButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            reloadDataButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            reloadDataButton.widthAnchor.constraint(equalToConstant: 180),


            newsFeedTable.leadingAnchor.constraint(equalTo: leadingAnchor),
            newsFeedTable.trailingAnchor.constraint(equalTo: trailingAnchor),
            newsFeedTable.bottomAnchor.constraint(equalTo: bottomAnchor),
            newsFeedTable.topAnchor.constraint(equalTo: reloadDataButton.bottomAnchor, constant: 10)
        ])
    }

}
