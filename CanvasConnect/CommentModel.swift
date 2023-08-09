//
//  CommentModel.swift
//  CanvasConnect
//
//  Created by Joaquín Borderas Ochoa on 2023-08-08.
//

import Foundation
import FirebaseFirestore
import Firebase
struct CommentModel: Identifiable {
    var id: String
    var text: String
    var userId: String
    var userName: String
    var timestamp: Timestamp
    
    // If you want to initialize from Firestore document data
    init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let text = data["text"] as? String,
              let userId = data["userId"] as? String,
              let userName = data["userName"] as? String,
              let timestamp = data["timestamp"] as? Timestamp else {
            return nil
        }
        self.id = document.documentID
        self.text = text
        self.userId = userId
        self.userName = userName
        self.timestamp = timestamp
    }

}
