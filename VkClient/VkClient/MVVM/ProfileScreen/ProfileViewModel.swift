//
//  ProfileViewModel.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 20.04.2024.
//

import Foundation
import FirebaseAuth
import UIKit

class ProfileViewModel {

    var getProfile: ((User?) -> ())?
    var getPublications: (([Publication]?) -> ())?

    var profile: User? {
        didSet {
            getProfile?(profile)
            obtainPublications(user: profile ?? User(name: "", email: ""))
        }
    }

    var publications: [Publication]? {
        didSet {
            getPublications?(publications)
        }
    }


    func obtainProfile() {
        let email = UserDefaults.standard.string(forKey: "safeEmail") ?? ""
        RealTimeDataBaseManager.shared.getProfileInfo(safeEmail: email) { result in
            switch result {
            case .success(let profile):
                self.profile = profile
            case .failure(let error):
                print("ошибка получения профиля : \(RealTimeDataBaseError.failedProfile)")
            }
        }
    }

    func obtainPublications(user: User) {
        var publications: [Publication] = []
        let dispatchGroup = DispatchGroup()
        user.publiсations?.forEach { post in
            dispatchGroup.enter()
            StorageManager.shared.downloadImage(post.publiactionPictureFileName) { result in
                switch result {
                case .success(let data):
                    var publication = post
                    publication.publiactionImageData = data
                    publications.append(publication)
                case .failure(let error):
                    print("ошибка получения фото для поста \(error)")
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.publications = StorageManager.sortPublicationsByDate(publications: publications)
        }
    }

    func signOut() {
        UserDefaults.standard.removeObject(forKey: "email")
        do {
            try FirebaseAuth.Auth.auth().signOut()
            AppCoordinator.shared.start()
        } catch let error {
            print(error)
        }
    }
}
