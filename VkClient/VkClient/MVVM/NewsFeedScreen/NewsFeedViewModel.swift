//
//  NewsFeedViewModel.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 21.04.2024.
//



import Foundation
import UIKit
import Combine

class NewsFeedViewModel {

    var getNewsPublications: (([Publication]?) -> ())?

    private var emails: [String]? {
        didSet {
            getFriendProfiles(emails: emails ?? [])
        }
    }

    private var profiles: [User]? {
        didSet {
            getPublications(users: profiles ?? [])
        }
    }

    private var publications: [Publication]? {
        didSet {
            getNewsPublications?(publications)
        }
    }


    func getFriendEmails() {
        let email = UserDefaults.standard.string(forKey: "safeEmail") ?? ""
        RealTimeDataBaseManager.shared.getEmailFriends(safeEmail: email) { result in
            switch result {
            case .success(let friendEmails):
                self.emails = friendEmails
            case .failure(let error):
                print("ошпбка получения Email`ов друзей, возможно что их нет : \(error)")
            }
        }
    }

    func getFriendProfiles(emails: [String]) {
        RealTimeDataBaseManager.shared.getAllFriendProfiles(emails: emails) { users in
            guard let profiles = users else  {
                print("друзей нет или произошла ошибка")
                return
            }
            self.profiles = profiles
        }
    }

    func getPublications(users: [User]) {
        var posts = users.compactMap { $0.publiсations }.flatMap { $0 }
        var publications: [Publication] = []
        let dispatchGroup = DispatchGroup()
        posts.forEach { post in
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

}
