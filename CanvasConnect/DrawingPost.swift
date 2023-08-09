//
//  DrawingPost.swift
//  CanvasConnect
//
//  Created by Joaquín Borderas Ochoa on 2023-08-07.
//

import Foundation


import PencilKit

struct DrawingPost: Identifiable {
    let id: String // Unique ID
    var creatorName: String
    let creatorId: String 
    var drawing: PKDrawing
    var likes: Int
    var likedByUser: Bool // Indicates whether the current user has liked this post
    var commentsCount: Int
}
