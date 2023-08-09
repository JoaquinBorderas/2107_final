//
//  ContentView.swift
//  CanvasConnect
//
//  Created by Joaquín Borderas Ochoa on 2023-04-05.
//

import SwiftUI
import PencilKit
import FirebaseFirestore
import FirebaseAuth

struct ContentView: View {
    @State private var posts: [DrawingPost] = []
    var userName: String {
        UserDefaults.standard.string(forKey: "userName") ?? "User"
    }
    @Binding var loggedIn: Bool
    var body: some View {
        VStack {
         
                Button(action: signOut) {
                    Text("Sign Out")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .padding()
                
                Spacer()
                
                NavigationLink(destination: DrawingCanvasView()) {
                    HStack {
                        
                        Image(systemName: "pencil")
                        Text("Draw Now")
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                
                List(posts) { post in
                    DrawingRow(post: post, likePostAction: likePost, deletePostAction: deletePost, currentUserId: Auth.auth().currentUser?.uid ?? "")
                }
            }
            .navigationBarTitle("Hello, \(userName)!", displayMode: .inline)
            .onAppear {
                loadDrawings()
            }
        }
    
    func signOut() {
            do {
                try Auth.auth().signOut()
                loggedIn = false
            } catch {
                print("Error signing out: \(error)")
            }
        }
    private func loadDrawings() {
        let db = Firestore.firestore()
        let currentUserId = Auth.auth().currentUser?.uid ?? ""// Retrieve the current user's ID
        db.collection("drawings")
          .order(by: "timestamp", descending: true)
          .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.posts.removeAll()
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let creatorId = data["creatorId"] as? String ?? ""
                    let likesArray = data["likesArray"] as? [String] ?? []
                    let creatorName = data["creatorName"] as? String ?? ""
                    let likes = likesArray.count
                    let likedByUser = likesArray.contains(currentUserId)
                    let commentsCount = data["commentsCount"] as? Int ?? 0
                    if let drawingData = data["drawing"] as? Data, let drawing = try? PKDrawing(data: drawingData) {
                        let post = DrawingPost(id: document.documentID, creatorName: creatorName, creatorId: creatorId, drawing: drawing, likes: likes, likedByUser: likedByUser, commentsCount: commentsCount)
                                       self.posts.append(post)
                    } else {
                        print("Error loading drawing data")
                    }
                }
            }
        }
    }

    func likePost(postId: String) {
        if let index = posts.firstIndex(where: { $0.id == postId }) {
            let currentUserId = Auth.auth().currentUser?.uid ?? ""
            var post = posts[index]
            let db = Firestore.firestore()
            let postRef = db.collection("drawings").document(postId)

            if post.likedByUser {
                // Unlike the post
                post.likes -= 1
                post.likedByUser = false
                // Update Firestore to remove the current user's ID from the likes array for the post
                postRef.updateData([
                    "likesArray": FieldValue.arrayRemove([currentUserId])
                ])
            } else {
                // Like the post
                post.likes += 1
                post.likedByUser = true
                // Update Firestore to add the current user's ID to the likes array for the post
                postRef.updateData([
                    "likesArray": FieldValue.arrayUnion([currentUserId])
                ])
            }

            posts[index] = post
        }
    }
    func deletePost(postId: String) {
        let db = Firestore.firestore()
        db.collection("drawings").document(postId).delete { err in
            if let err = err {
                print("Error deleting document: \(err)")
            } else {
                print("Document successfully deleted")
                if let index = posts.firstIndex(where: { $0.id == postId }) {
                    posts.remove(at: index)
                }
            }
        }
    }


}

struct DrawingRow: View {
        let post: DrawingPost
        let likePostAction: (String) -> Void
        let deletePostAction: (String) -> Void
        let currentUserId: String

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(post.creatorName)
                    .font(.headline)
                Image(uiImage: post.drawing.toUIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                
                HStack(spacing: 15) {
                    Button(action: {
                        likePostAction(post.id)
                    }) {
                        HStack {
                            Image(systemName: "heart")
                            Text("\(post.likes)")
                        }
                        .padding(.all, 8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()

                    Button(action: {
                        deletePostAction(post.id)
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Delete")
                                .foregroundColor(.red)
                        }
                        .padding(.all, 8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    VStack {
                        NavigationLink(destination: CommentsView(postID: post.id)) {
                            HStack {
                                Image(systemName: "text.bubble")
                                Text("\(post.commentsCount)")
                            }
                            .padding(.all, 8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .padding(.horizontal, 10)
                
                Divider()
            }
            .foregroundColor(.gray)
        }
    }

  
