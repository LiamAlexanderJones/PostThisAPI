//
//  File.swift
//  
//
//  Created by Liam Jones on 22/06/2022.
//

import Fluent
import Vapor

final class UserToken: Model, Content {
  static let schema = "user_tokens"
  
  @ID(key: .id)
  var id: UUID?
  
  @Field(key: "value")
  var value: String
  
  @Parent(key: "user_id")
  var user: User
  
  init() { }
  
  init(id: UUID? = nil, value: String, userID: User.IDValue) {
    self.id = id
    self.value = value
    self.$user.id = userID
  }
  
}

extension UserToken: ModelTokenAuthenticatable {
  
  static func generate(for user: User) throws -> UserToken {
    let random = [UInt8].random(count: 16).base64
    return try UserToken(value: random, userID: user.requireID())
  }
  
  static let valueKey = \UserToken.$value
  static let userKey = \UserToken.$user
  typealias User = App.User
  
  var isValid: Bool { true }
  
}
