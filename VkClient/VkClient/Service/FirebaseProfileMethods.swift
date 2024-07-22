//
//  FirebaseProfileMethods.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 22.07.2024.
//

import Foundation
import UIKit

extension RealTimeDataBaseManager {

    func getProfileInfo(safeEmail: String, completionHandler: @escaping (Result<User, Error>) -> ()) {
        self.database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            if let userDict = snapshot.value as? [String: Any],
               let userName = userDict["name"] as? String,
               let userEmail = userDict["email"] as? String,
               let friends = userDict["friends"] as? [String],
               let followers = userDict["followers"] as? [String],
               let subscriptions = userDict["subscriptions"] as? [String],
               let publicationsDict = userDict["publications"] as? [String: Any] {
                var publications: [Publication] = []
                for (_, value) in publicationsDict {
                    if let publicationDict = value as? [String: Any] {
                        let idString = publicationDict["id"] as? String
                        let id = UUID(uuidString: idString ?? "")
                        let text = publicationDict["text"] as? String
                        let date = publicationDict["date"] as? String
                        let publication = Publication(id: id ?? UUID(), name: userName, text: text ?? "", date: date ?? "")
                        publications.append(publication)
                    }
                }
                StorageManager.shared.downloadAvatarDataSelfProfile(safeEmail) { data in
                    if data != nil {
                        var updatedPublications = publications.map { publication -> Publication in
                            var updatedPublication = publication
                            updatedPublication.avatarImage = UIImage(data: data ?? Data())
                            return updatedPublication
                        }
                        let user = User(name: userName, email: userEmail, profilePicture: data, friends: friends, followers: followers, subscriptions: subscriptions, publiсations: updatedPublications)
                        completionHandler(.success(user))
                    } else {
                        print("получен профиль без фото")
                        let user = User(name: userName, email: userEmail, friends: friends, followers: followers, subscriptions: subscriptions, publiсations: publications)
                        completionHandler(.success(user))
                    }
                }
            } else if let userDict = snapshot.value as? [String: Any],
                      let userName = userDict["name"] as? String,
                      let userEmail = userDict["email"] as? String,
                      let publicationsDict = snapshot.value as? [String: Any] {
                var publications: [Publication] = []
                for (_, value) in publicationsDict {
                    if let publicationDict = value as? [String: Any] {
                        let idString = publicationDict["id"] as? String
                        let id = UUID(uuidString: idString ?? "")
                        let text = publicationDict["text"] as? String
                        let date = publicationDict["date"] as? String
                        let publication = Publication(id: id ?? UUID(), name: userName, text: text ?? "", date: date ?? "")
                        publications.append(publication)
                    }
                }
                StorageManager.shared.downloadAvatarDataSelfProfile(safeEmail) { data in
                    if data != nil {
                        var updatedPublications = publications.map { publication -> Publication in
                            var updatedPublication = publication
                            updatedPublication.avatarImage = UIImage(data: data ?? Data())
                            return updatedPublication
                        }
                        let user = User(name: userName, email: userEmail, profilePicture: data, publiсations: updatedPublications)
                        completionHandler(.success(user))
                    } else {
                        print("получен профиль без фото")
                        let user = User(name: userName, email: userEmail, publiсations: publications)
                        completionHandler(.success(user))
                    }
                }
            } else if let userDict = snapshot.value as? [String: Any],
                      let userName = userDict["name"] as? String,
                      let userEmail = userDict["email"] as? String {
                StorageManager.shared.downloadAvatarDataSelfProfile(safeEmail) { data in
                    if data != nil {
                        let user = User(name: userName, email: userEmail, profilePicture: data)
                        completionHandler(.success(user))
                    } else {
                        print("получен профиль без фото")
                        let user = User(name: userName, email: userEmail)
                        completionHandler(.success(user))
                    }
                }
            } else {
                completionHandler(.failure(RealTimeDataBaseError.failedProfile))
                print("Неизвестный формат снимка данных")
            }
        }
    }


    //MARK: ПОЛУЧЕНИЕ ВСЕХ ЮЗЕРОВ
    func getAllUsers(completion: @escaping (Result<[User], Error>) -> ()) {
        database.observeSingleEvent(of: .value) { snapshot in
            guard let childrensJson = snapshot.value as? [String: Any] else {
                completion(.failure(RealTimeDataBaseError.failedReceivingUsers))
                return
            }
            var users: [User] = []
            for (_, value) in childrensJson {
                if let userDict = value as? [String: Any] {
                    let name = userDict["name"] as? String
                    let email = userDict["email"] as? String
                    let friends = userDict["friends"] as? [String]
                    let followers = userDict["followers"] as? [String]
                    let subscriptions = userDict["subscriptions"] as? [String]
                    let user = User(name: name ?? "", email: email ?? "",
                                    friends: friends, followers: followers, subscriptions: subscriptions)
                    users.append(user)
                }
            }
            completion(.success(users))
        }
    }

}
