//
//  File.swift
//  
//
//  Created by Liam Jones on 20/06/2022.
//

import Fluent
import Vapor

final class Comment: Model, Content {
  static let schema = "comments"
  
  @ID(key: .id)
  var id: UUID?
  
  @Parent(key: "post_id")
  var post: Post
  
  @Field(key: "body")
  var body: String
  
  @Field(key: "createdAt")
  var createdAt: Date
  
  @Field(key: "createdBy")
  var createdBy: String
  
  @Field(key: "hasImage")
  var hasImage: Bool
  
  init() { }
  
  init(id: UUID? = nil, postID: Post.IDValue, body: String, createdAt: Date, createdBy: String, hasImage: Bool) {
    self.id = id
    self.$post.id = postID
    self.body = body
    self.createdAt = createdAt
    self.createdBy = createdBy
    self.hasImage = hasImage
  }
  
}
