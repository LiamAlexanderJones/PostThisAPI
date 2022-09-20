//
//  File.swift
//  
//
//  Created by Liam Jones on 26/06/2022.
//

import Fluent
import Vapor
import Foundation

//TODO: Remove createdBY field for posts and comments. No longer needed.

final class Post: Model, Content, Authenticatable {
  static let schema = "posts"
  
  @ID(key: .id)
  var id: UUID?
  
  @Parent(key: "user_id")
  var user: User
  
  @Children(for: \.$post)
  var comments: [Comment]
  
  @Children(for: \.$post)
  var reactions: [Reaction]
  
  @Field(key: "body")
  var body: String
  
  @Field(key: "createdAt")
  var createdAt: Date
  
//  @Field(key: "createdBy")
//  var createdBy: String
  
  @Field(key: "hasImage")
  var hasImage: Bool
  
  init() { }
  
  init(id: UUID? = nil, userID: User.IDValue, body: String, createdAt: Date, hasImage: Bool) {
    self.id = id
    self.$user.id = userID
    self.body = body
    self.createdAt = createdAt
   // self.createdBy = createdBy
    self.hasImage = hasImage
  }
  
  struct Create: Content {
    var body: String
    var createdAt: Date
    var hasImage: Bool
  }
  
  struct Get: Content {
    var id: UUID?
    var body: String
    var createdAt: Date
    var createdBy: User.Public
    var hasImage: Bool
  }
  
}

extension Array where Element == Post {
  func convertToGet() -> [Post.Get] {
    return self.map { post in
      return Post.Get(id: post.id, body: post.body, createdAt: post.createdAt, createdBy: User.Public(id: post.user.id, username: post.user.username), hasImage: post.hasImage)
    }
  }
}
