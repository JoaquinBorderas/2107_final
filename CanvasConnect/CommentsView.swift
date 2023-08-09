//
//  CommentsView.swift
//  CanvasConnect
//
//  Created by Joaquín Borderas Ochoa on 2023-08-08.
//

import SwiftUI
import FirebaseFirestore
import Firebase
import Foundation

struct CommentsView: View {
    var postID: String
    @State private var comments: [CommentModel] = []
    @State private var newComment: String = ""

    var body: some View {
        VStack {
            List(comments) { comment in
                VStack(alignment: .leading) {
                    Text(comment.userName).font(.subheadline)
                    Text(comment.text)
                }
            }

            
            HStack {
                TextField("Add a comment...", text: $newComment)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: addComment) {
                    Text("Post")
                }
            }
            .padding()
        }
        .onAppear(perform: loadComments)
    }
    
    private func loadComments() {
        let db = Firestore.firestore()
        db.collection("drawings").document(postID).collection("comments")
          .order(by: "timestamp", descending: false)
          .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting comments: \(err)")
            } else {
                self.comments.removeAll()
                for document in querySnapshot!.documents {
                    if let comment = CommentModel(document: document) {
                        self.comments.append(comment)
                    }
                }
            }
        }
    }

    private func addComment() {
        guard !newComment.isEmpty else { return }

        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("No user is logged in, cannot add comment")
            return
        }

        let userName = UserDefaults.standard.string(forKey: "userName") ?? "Anonymous" // Replace with the appropriate method to get the current user's name

        let db = Firestore.firestore()
        let drawingRef = db.collection("drawings").document(postID)
        drawingRef.collection("comments").addDocument(data: [
            "text": newComment,
            "userId": currentUserId,
            "userName": userName,
            "timestamp": FieldValue.serverTimestamp()
        ]) { err in
            if let err = err {
                print("Error adding comment: \(err)")
            } else {
                // Increment the comments count
                drawingRef.updateData([
                    "commentsCount": FieldValue.increment(Int64(1))
                ])
                print("Comment added successfully")
                self.newComment = ""
            }
        }
    }

}
