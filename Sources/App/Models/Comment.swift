//
//  File.swift
//  
//
//  Created by Liam Jones on 20/06/2022.
//

import Fluent
import Vapor
import Foundation

final class Comment: Model, Content {
  static let schema = "comments"
  
  @ID(key: .id)
  var id: UUID?
  
  @Parent(key: "user_id")
  var user: User
  
  @Parent(key: "post_id")
  var post: Post
  
  @Children(for: \.$comment)
  var reactions: [Reaction]
  
  @Field(key: "body")
  var body: String
  
  @Field(key: "createdAt")
  var createdAt: Date
  
  @Field(key: "hasImage")
  var hasImage: Bool
  
  init() { }
  
  init(id: UUID? = nil, userID: User.IDValue, postID: Post.IDValue, body: String, createdAt: Date, hasImage: Bool) {
    self.id = id
    self.$user.id = userID
    self.$post.id = postID
    self.body = body
    self.createdAt = createdAt
//    self.createdBy = createdBy
    self.hasImage = hasImage
  }
  
  struct Create: Content {
    let postID: UUID
    var body: String
    var createdAt: Date
    var hasImage: Bool
  }
  
  struct Get: Content {
    var id: UUID?
    var postID: UUID?
    var body: String
    var createdAt: Date
    var createdBy: User.Public
    var hasImage: Bool
  }
  
}


extension Array where Element == Comment {
  func convertToGet() -> [Comment.Get] {
    return self.map { comment in
      return Comment.Get(id: comment.id, postID: comment.$post.id, body: comment.body, createdAt: comment.createdAt, createdBy: User.Public(id: comment.$user.id, username: comment.user.username), hasImage: comment.hasImage)
    }
  }
}
