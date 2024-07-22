//
//  ViewController.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 17.04.2024.
//

import UIKit
import JGProgressHUD

class NewsFeedController: UIViewController {


    private var newsFeedTableView: NewsFeedTableView?
    private var viewModel: NewsFeedViewModel?
    private var publications: [Publication]?
    private var hud = JGProgressHUD(style: .light)


    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupDataBindings()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }

    private func setup() {
        newsFeedTableView = NewsFeedTableView()
        newsFeedTableView?.delegate = self
        view = newsFeedTableView
        viewModel = NewsFeedViewModel()
        viewModel?.getFriendEmails()
        newsFeedTableView?.newsFeedTable.delegate = self
        newsFeedTableView?.newsFeedTable.dataSource = self
        newsFeedTableView?.newsFeedTable.register(NewsFeedTableViewCell.self, forCellReuseIdentifier: NewsFeedTableViewCell.reuseIdentifier)
        newsFeedTableView?.newsFeedTable.reloadData()
    }

    private func setupDataBindings() {
        hud.show(in: view, animated: true)
        viewModel?.getNewsPublications = { [ weak self ] posts in
            DispatchQueue.main.async {
                self?.publications = posts
                self?.hud.dismiss()
                self?.newsFeedTableView?.newsFeedTable.reloadData()
            }
        }
    }
}

extension NewsFeedController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        510
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension NewsFeedController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        publications?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsFeedTableViewCell.reuseIdentifier, for: indexPath) as? NewsFeedTableViewCell
        if let posts = publications {
            cell?.configure(with: posts[indexPath.row])
            return cell ?? UITableViewCell()
        }
        return UITableViewCell()
    }
}



extension NewsFeedController: NewsFeedTableViewDelegate {
    func didReloadDataButtonTapped() {
        viewModel?.getFriendEmails()
        hud.show(in: view, animated: true)
        viewModel?.getNewsPublications = { [ weak self ] posts in
            DispatchQueue.main.async {
                self?.publications = posts
                self?.hud.dismiss()
                self?.newsFeedTableView?.newsFeedTable.reloadData()
                let topIndex = IndexPath(row: 0, section: 0)
                self?.newsFeedTableView?.newsFeedTable.scrollToRow(at: topIndex, at: .top, animated: true)
            }
        }
    }
}
