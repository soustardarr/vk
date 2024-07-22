//
//  FirebsaeFriendMethods.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 22.07.2024.
//

import Foundation

// MARK: - User Subscription Status Manager

extension RealTimeDataBaseManager {
    // currentUser - тот на кого подписываемся
    // selfUser - аккаунт с которого подписываемся

    //MARK: ДОБАВЛЕНИЕ ПОДПИСКИ
    func addFollow(for currentUser: User, completion: @escaping (User?) -> Void) {
//        let selfUser = CoreDataManager.shared.obtainSavedProfileInfo()
        let email = UserDefaults.standard.string(forKey: "email") ?? ""
        let selfSafeEmail = RealTimeDataBaseManager.safeEmail(emailAddress: email)
        var currentUser = User(name: currentUser.name,
                                  email: currentUser.email,
                                  friends: currentUser.friends,
                                  followers: currentUser.followers,
                                  subscriptions: currentUser.subscriptions)
        // добавляем подписчика current user
        database.child(currentUser.safeEmail)
            .child("followers")
            .observeSingleEvent(of: .value) { [ weak self ] snapshot in
                guard let strongSelf = self else { return }
                if var followers = snapshot.value as? [String] {
                    followers.append(selfSafeEmail)
                    currentUser.followers = followers
                    strongSelf.database.child(currentUser.safeEmail).child("followers").setValue(followers)
                    completion(currentUser)
                } else {
                    let followers: [String] = [selfSafeEmail]
                    currentUser.followers?.append(selfSafeEmail)
                    strongSelf.database.child("\(currentUser.safeEmail)/followers").setValue(followers)
                    currentUser.followers = followers
                    completion(currentUser)
                }
            }
        // добавляем подписку на кого то selfuser'у
        database.child(selfSafeEmail)
            .child("subscriptions")
            .observeSingleEvent(of: .value) { [ weak self ] snapshot in
                guard let strongSelf = self else { return }
                if var subscriptions = snapshot.value as? [String] {
                    subscriptions.append(currentUser.safeEmail)
                    strongSelf.database.child(selfSafeEmail).child("subscriptions").setValue(subscriptions)
                } else {
                    let subscriptions = [ currentUser.safeEmail ]
                    strongSelf.database.child("\(selfSafeEmail)/subscriptions").setValue(subscriptions)
                }
            }
    }

    //MARK: УДАЛЕНИЕ ПОДПИСКИ
    func deleteFollow(for currentUser: User, completion: @escaping (User?) -> Void) {
        let email = UserDefaults.standard.string(forKey: "email") ?? ""
        let selfSafeEmail = RealTimeDataBaseManager.safeEmail(emailAddress: email)
//        let selfUser = CoreDataManager.shared.obtainSavedProfileInfo()
        // удаляем подписку selfuser
        database.child(selfSafeEmail)
            .child("subscriptions")
            .observeSingleEvent(of: .value) { [ weak self ] snapshot in
                guard let strongSelf = self else { return }
                if var subscriptions = snapshot.value as? [String] {
                    print(subscriptions)
                    subscriptions.removeAll(where: { $0 == currentUser.safeEmail})
                    strongSelf.database
                        .child(selfSafeEmail)
                        .child("subscriptions").setValue(subscriptions)
                }
            }
        // удаляем подписчика current user
        var currentUser = User(name: currentUser.name,
                                  email: currentUser.email,
                                  friends: currentUser.friends,
                                  followers: currentUser.followers,
                                  subscriptions: currentUser.subscriptions)
        database.child(currentUser.safeEmail)
            .child("followers")
            .observeSingleEvent(of: .value) {[ weak self ] snapshot in
                guard let strongSelf = self else { return }
                if var followers = snapshot.value as? [String] {
                    followers.removeAll(where: { $0 == selfSafeEmail})
                    currentUser.followers = followers
                    strongSelf.database.child(currentUser.safeEmail).child("followers").setValue(followers)
                    completion(currentUser)
                }
            }
    }

    func deleteFromFriendList(_ selfEmail: String, _ currentUserEmail: String) {
        // удаляем у себя друга
        database.child(selfEmail)
            .child("friends")
            .observeSingleEvent(of: .value) { [ weak self ] snapshot in
                guard let strongSelf = self else { return }
                if var friends = snapshot.value as? [String] {
                    friends.removeAll(where: { $0 == currentUserEmail})
                    strongSelf.database.child(selfEmail).child("friends").setValue(friends)
                }
            }
        // удаляем currentusery себя из друзей
        database.child(currentUserEmail)
            .child("friends")
            .observeSingleEvent(of: .value) { [ weak self ] snapshot in
                guard let strongSelf = self else { return }
                if var friends = snapshot.value as? [String] {
                    friends.append(selfEmail)
                    friends.removeAll(where: { $0 == selfEmail})
                    strongSelf.database.child(currentUserEmail).child("friends").setValue(friends)
                }
            }
    }

    func addToFriendsList(_ selfEmail: String, _ currentUserEmail: String) {
        // добавляем себе в друзья
        database.child(selfEmail)
            .child("friends")
            .observeSingleEvent(of: .value) { [ weak self ] snapshot in
                guard let strongSelf = self else { return }
                if var friends = snapshot.value as? [String] {
                    friends.append(currentUserEmail)
                    strongSelf.database.child(selfEmail).child("friends").setValue(friends)
                } else {
                    let friends: [String] = [ currentUserEmail ]
                    strongSelf.database.child("\(selfEmail)/friends").setValue(friends)
                }
            }
        // добавляем current usery себя ему в друзья
        database.child(currentUserEmail)
            .child("friends")
            .observeSingleEvent(of: .value) { [ weak self ] snapshot in
                guard let strongSelf = self else { return }
                if var friends = snapshot.value as? [String] {
                    friends.append(selfEmail)
                    strongSelf.database.child(currentUserEmail).child("friends").setValue(friends)
                } else {
                    let friends = [ selfEmail ]
                    strongSelf.database.child("\(currentUserEmail)/friends").setValue(friends)
                }
            }
    }
}

