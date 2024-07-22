//
//  FirebasePublicationMethods.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 22.07.2024.
//

import Foundation
import UIKit

// MARK: - set publication

extension RealTimeDataBaseManager {

    func sendPublication(publication: Publication) {
        let email = UserDefaults.standard.string(forKey: "email") ?? ""
        let selfSafeEmail = RealTimeDataBaseManager.safeEmail(emailAddress: email)

        database.child(selfSafeEmail)
            .child("publications")
            .observeSingleEvent(of: .value) { [ weak self ] snapshot in
                guard let strongSelf = self else { return }
                if var publications = snapshot.value as? [String: Any] {
                    let publicationData: [String: String] = [
                        "publiactionPictureFileName": publication.publiactionPictureFileName,
                        "date": publication.date,
                        "text": publication.text ?? "",
                        "id": publication.id.uuidString
                    ]
                    publications["\(publication.id)"] = publicationData
                    strongSelf.database.child(selfSafeEmail).child("publications").setValue(publications)
                    print("успешное добавление публикации")
                } else {
                    let publicationData: [String: String] = [
                        "publiactionPictureFileName": publication.publiactionPictureFileName,
                        "date": publication.date,
                        "text": publication.text ?? "",
                        "id": publication.id.uuidString
                    ]
                    var publications: [String: Any] = [:]
                    publications["\(publication.id)"] = publicationData
                    strongSelf.database.child("\(selfSafeEmail)/publications").setValue(publications)
                    print("успешная вствака первой публикации")
                }
            }
    }

}



