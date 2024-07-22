//
//  FirebaseFriendProfile.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 22.07.2024.
//

import Foundation


extension RealTimeDataBaseManager {

    func getEmailFriends(safeEmail: String, completion: @escaping (Result<[String], Error>) -> Void) {
        database.child(safeEmail).child("friends").observeSingleEvent(of: .value) { snapshot in
            if let friends = snapshot.value as? [String] {
                completion(.success(friends))
            } else {
                completion(.failure(RealTimeDataBaseError.failedReceivingFriends))
            }
        }
    }


    func getAllFriendProfiles(emails: [String], completion: @escaping ([User]?) -> ()) {
        var friends: [User] = []
        let dispatchGroup = DispatchGroup()

        emails.forEach { email in
            dispatchGroup.enter()
            RealTimeDataBaseManager.shared.getProfileInfo(safeEmail: email) { result in
                switch result {
                case .success(let user):
                    friends.append(user)
                case .failure(let error):
                    print("не удалось получить профиль друга: \(error)")
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(friends)
        }
    }


    

}
