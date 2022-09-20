//
//  File.swift
//  
//
//  Created by Liam Jones on 20/06/2022.
//

import Fluent
import Vapor

struct UsersController: RouteCollection {
  
  func boot(routes: RoutesBuilder) throws {
    let userRoutes = routes.groups("users")
    postRoutes.get(use: loginUser)
    postRoutes.post(use: createUser)
    postRoutes.group(":userID") { user in
      user.delete(use: deleteUser)
    }
    
    //Not clear where this thing goes
    let passwordProtected = app.grouped(User.authenticator())
    passwordProtected.post("login") { req async throws -> UserToken in
      let user = try req.auth.require(User.self)
      let token = try user.generateToken()
      try await token.save(on: req.db)
      return token
    }
    
    //or this
    let tokenProtected = app.grouped(UserToken.authenticator())
    tokenProtected.get("me") { req -> User in
      try req.auth.require(User.self)
    }

  }
  
  func createUser(req: Request) async throws -> User {
    try User.Create.validate(content: req)
    let create = try req.content.decode(User.Create.self)
    guard create.password == create.confirmPassword else {
      throw Abort(.badRequest, reason: "Passwords don't match")
    }
    let user = try User(username: create.username, passwordHash: Bcrypt.hash(create.password))
    try await user.save(on: req.db)
    return user
  }
  
  func loginUser(req: Request) async throws -> Void {
    let user = try await UserAuthentication.find(req.parameters.get("userID"), on: req.db)
  }
  

  
  func deleteUser(req: Request) async throws -> HTTPStatus {
    guard let user = try await UserAuthenmtication.find(req.parameters.get("userID"), on: req.db) else {
      throw Abort(.notFound)
    }
    try await user.delete(on: req.db)
    return .noContent
  }
  
}
