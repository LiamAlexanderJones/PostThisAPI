//
//  File.swift
//  
//
//  Created by Liam Jones on 20/06/2022.
//

import Fluent
import Vapor
import Foundation


final class User: Model, Content {
  static let schema = "users"
  
  @ID(key: .id)
  var id: UUID?
  
  @Children(for: \.$user)
  var posts: [Post]
  
  @Children(for: \.$user)
  var comments: [Comment]
  
  @Children(for: \.$user)
  var reactions: [Reaction]
  
  @Field(key: "username")
  var username: String
  
  @Field(key: "password_hash")
  var passwordHash: String
  
  
  //FOLLOW FUCNTION
  @Field(key: "followed_users")
  var followedUsers: [UUID]
  

  init() { }
  
  init(id: UUID? = nil, username: String, passwordHash: String) {
    self.id = id
    self.username = username
    self.passwordHash = passwordHash
    self.followedUsers = []
  }
  
  struct Public: Content {
    var id: UUID?
    var username: String
  }
  
  struct Create: Content, Validatable {
    var username: String
    var password: String
    var confirmPassword: String

    static func validations(_ validations: inout Validations) {
      validations.add("username", as: String.self, is: !.empty)
      validations.add("password", as: String.self, is: .count(6...))
    }
    
  }
  
}

extension User {
  func convertToPublic() -> User.Public {
    return User.Public(id: self.id, username: self.username)
  }
}


extension User: ModelAuthenticatable {

  static let usernameKey = \User.$username
  static let passwordHashKey = \User.$passwordHash
 
  func verify(password: String) throws -> Bool {
    try Bcrypt.verify(password, created: self.passwordHash)
  }
}





extension User {
  func generateToken() throws -> UserToken {
    try UserToken(
      value: [UInt8].random(count: 16).base64,
      userID: self.requireID()
    )
  }
}
