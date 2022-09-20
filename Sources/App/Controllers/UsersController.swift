//
//  File.swift
//  
//
//  Created by Liam Jones on 20/06/2022.
//

import Fluent
import Vapor
import Foundation

struct UsersController: RouteCollection {
  
  func boot(routes: RoutesBuilder) throws {
    let userRoutes = routes.grouped("api", "users")
    userRoutes.post(use: createUser)
    userRoutes.get(":userID", "posts", ":page", ":resultsPerPage", use: getPaginatedUserPosts)
    
    let basicAuthGroup = userRoutes.grouped(User.authenticator())
    basicAuthGroup.post("login", use: loginUser)
    
    let tokenProtected = userRoutes.grouped(UserToken.authenticator(), User.guardMiddleware())
    tokenProtected.get("followed", use: getFollowedUsers)
    tokenProtected.post("follow", ":userToFollowID", use: followUser)

  }
  
  func createUser(req: Request) async throws -> UserToken {
    try User.Create.validate(content: req)
    let create = try req.content.decode(User.Create.self, using: JSONDecoder())
    guard create.password == create.confirmPassword else {
      throw Abort(.badRequest, reason: "Passwords didn't match")
    }
    let user = try User(username: create.username, passwordHash: Bcrypt.hash(create.password))
    try await user.save(on: req.db)
    let token = try UserToken.generate(for: user)
    try await token.save(on: req.db)
    return token
  }
  
  
  func loginUser(req: Request) async throws -> UserToken {
    let user = try req.auth.require(User.self)
    let token = try UserToken.generate(for: user)
    try await token.save(on: req.db)
    return token
  }
  
  
  //MARK: -Getting posts for a particular user
  
  func getPaginatedUserPosts(req: Request) async throws -> [Post.Get] {
    //Returns posts by a specified user.
    guard let page = req.parameters.get("page", as: Int.self) else {
      throw Abort(.badRequest)
    }
    guard let per = req.parameters.get("resultsPerPage", as: Int.self) else {
      throw Abort(.badRequest)
    }
    guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
      throw Abort(.notFound)
    }
    return try await user.$posts.query(on: req.db)
      .with(\.$user)
      .sort(\.$createdAt, .descending)
      .paginate(PageRequest(page: page, per: per))
      .items
      .convertToGet()
  }
  
  
  //MARK: -Functions for following other users
  
  func getFollowedUsers(req: Request) async throws -> [User.Public] {
    let user = try req.auth.require(User.self)
    var followedUsers: [User.Public] = []
    
    for id in user.followedUsers {
      if let followedUser = try await User.find(id, on: req.db)?.convertToPublic() {
        followedUsers.append(followedUser)
      }
    }
    return followedUsers
  }
  
  
  func followUser(req: Request) async throws -> HTTPStatus {
    let user = try req.auth.require(User.self)
    guard let userToFollow = try await User.find(req.parameters.get("userToFollowID"), on: req.db) else {
      throw Abort(.notFound)
    }
    let userToFollowID = try userToFollow.requireID()
    
    if user.followedUsers.contains(userToFollowID) {
      user.followedUsers.removeAll { $0 == userToFollowID }
    } else {
      user.followedUsers.append(userToFollowID)
    }
    try await user.save(on: req.db)
    return .noContent
  }
  
  
}
