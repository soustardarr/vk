//
//  ProfileController.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 17.04.2024.
//

import UIKit
import Combine

class ProfileController: UIViewController {


    private var profileView: ProfileNewsTableView?
    private var headerView: HeaderView?
    private var cancellable: Set<AnyCancellable> = []
    private var profileViewModel: ProfileViewModel?
    private var publications: [Publication]?
    private var user: User?
    private weak var createViewModel: CreatePublicationViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }


    private func setup() {
        profileView = ProfileNewsTableView()
        view = profileView
        profileView?.newsFeedTable.delegate = self
        profileView?.newsFeedTable.dataSource = self
        profileView?.newsFeedTable.register(NewsFeedTableViewCell.self, forCellReuseIdentifier: NewsFeedTableViewCell.reuseIdentifier)
        headerView = HeaderView()
        headerView?.delegate = self
        profileViewModel = ProfileViewModel()
        profileViewModel?.obtainProfile()
        setupData()
    }

    private func setupData() {
        profileViewModel?.getProfile = { [ weak self ] profile in
            DispatchQueue.main.async {
                self?.headerView?.avatarImageView.image = UIImage(data: profile?.profilePicture ?? Data())
                self?.headerView?.nameLabel.text = profile?.name
                self?.user = profile
            }
        }
        profileViewModel?.getPublications = { [ weak self ] publications in
            DispatchQueue.main.async {
                self?.publications = publications
                self?.profileView?.newsFeedTable.reloadData()
            }
        }
    }
}

extension ProfileController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        260
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        520
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

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

extension ProfileController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return headerView
        case 1:
            return nil
        default:
            return nil
        }
    }

}


extension ProfileController: HeaderViewDelegate {


    func didTappedCreatePublication() {
        let createPublicationVC = CreatePublicationController(user: user ?? nil)
        createPublicationVC.delegate = self
        let navVC = UINavigationController(rootViewController: createPublicationVC)
        present(navVC, animated: true)
    }
    
    func didTappedSignOutButton() {
        let controller = UIAlertController(title: "выход из аккаунта", message: "хотите выйти?", preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "да", style: .destructive, handler: { [ weak self ] _ in
            guard let strongSelf = self else { return }
            strongSelf.profileViewModel?.signOut()

        }))
        controller.addAction(UIAlertAction(title: "нет", style: .default))
        present(controller, animated: true)
    }
}


extension ProfileController: CreatePublicationControllerDelegate {

    func publicationHasBeenCreated(publication: Publication) {
        if publications != nil {
            publications?.append(publication)
        } else {
            publications = []
            publications?.append(publication)
        }
        publications = StorageManager.sortPublicationsByDate(publications: publications ?? [])
        profileView?.newsFeedTable.reloadData()
    }
}
