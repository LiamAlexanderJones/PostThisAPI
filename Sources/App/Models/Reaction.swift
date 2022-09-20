//
//  File.swift
//  
//
//  Created by Liam Jones on 29/07/2022.
//

import Fluent
import Vapor

final class Reaction: Model, Content {
  
  static let schema = "reactions"
  
  @ID(key: .id)
  var id: UUID?
  
  //To consider: Type could be an enum of three values, so you would need three reactions in full. Or it could be a binary vector eg. 011, so you would only need one reaction potentially
  @Enum(key: "type")
  var type: ReactionType
  
  @Parent(key: "user_id")
  var user: User
  
  @OptionalParent(key: "post_id")
  var post: Post?
  
  @OptionalParent(key: "comment_id")
  var comment: Comment?
  
  init() { }
  
  //Maybe you should overload this init instead so it's never possible to create a reaction with neither comment nor post
  
  init(id: UUID? = nil, type: ReactionType, userID: User.IDValue, postID: Post.IDValue? = nil, commentID: Comment.IDValue? = nil) {
    self.id = id
    self.type = type
    self.$user.id = userID
    self.$post.id = postID
    self.$comment.id = commentID
  }
  
  
  struct Reactors: Content {
    var likeReactors: [User.Public]
    var upReactors: [User.Public]
    var downReactors: [User.Public]
  }
  
}






enum ReactionType: String, Codable {
  case like, up, down
  
  static func fromString(_ string: String) -> Self? {
    switch string {
    case "like":
      return .like
    case "up":
      return .up
    case "down":
      return .down
    default:
      return nil
    }
  }
  
}

