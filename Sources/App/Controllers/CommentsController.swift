//
//  File.swift
//  
//
//  Created by Liam Jones on 20/06/2022.
//

import Fluent
import Vapor
import Foundation



struct CommentsController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    //Routes for individual comments (Deletion and reactions)
    let commentRoutes = routes.grouped("api", "comments", ":commentID")
    commentRoutes.get("reactions", use: getReactorsToComment)
    
    let tokenProtectedComment = commentRoutes.grouped(UserToken.authenticator(), User.guardMiddleware())
    tokenProtectedComment.delete(use: deleteComment)
    tokenProtectedComment.post(":type", use: addReactionToComment)
    tokenProtectedComment.delete(":type", use: removeReactionFromComment)
  }
  
  
  func deleteComment(req: Request) async throws -> HTTPStatus {
    let user = try req.auth.require(User.self)
    guard let comment = try await Comment.find(req.parameters.get("commentID"), on: req.db) else {
      throw Abort(.notFound)
    }
    let id = try user.requireID()
    guard id == comment.$user.id else {
      throw Abort(.unauthorized)
    }
    try await comment.delete(on: req.db)
    return .noContent
  }
  
  
  //MARK: - Handling reactions
  
  func addReactionToComment(req: Request) async throws -> HTTPStatus {
    let user = try req.auth.require(User.self)
    guard let comment = try await Comment.find(req.parameters.get("commentID"), on: req.db) else {
      throw Abort(.notFound)
    }
    guard let type = ReactionType.fromString(req.parameters.get("type") ?? "") else {
      throw Abort(.badRequest)
    }
    let reaction = try Reaction(type: type, userID: user.requireID(), commentID: comment.requireID())
    try await reaction.save(on: req.db)
    return .created
  }
  
  
  func removeReactionFromComment(req: Request) async throws -> HTTPStatus {
    let user = try req.auth.require(User.self)
    guard let comment = try await Comment.find(req.parameters.get("commentID"), on: req.db) else {
      throw Abort(.notFound)
    }
    guard let type = ReactionType.fromString(req.parameters.get("type") ?? "") else {
      throw Abort(.badRequest)
    }
    let reaction = try await comment.$reactions.query(on: req.db)
      .join(User.self, on: \Reaction.$user.$id == \User.$id)
      .filter(User.self, \.$username == user.username)
      .filter(\.$type == type)
      .first()
    try await reaction?.delete(on: req.db)
    return .noContent
  }
  
  
  func getReactorsToComment(req: Request) async throws -> Reaction.Reactors {
    guard let comment = try await Comment.find(req.parameters.get("commentID"), on: req.db) else {
      throw Abort(.notFound)
    }
    let reactions = try await comment.$reactions.get(on: req.db)
    var likeUsers: [User.Public] = []
    var upUsers: [User.Public] = []
    var downUsers: [User.Public] = []
    
    for reaction in reactions {
      let user = try await reaction.$user.get(on: req.db).convertToPublic()
      switch reaction.type {
      case .like:
        likeUsers.append(user)
      case .up:
        upUsers.append(user)
      case .down:
        downUsers.append(user)
      }
    }
    return Reaction.Reactors(likeReactors: likeUsers, upReactors: upUsers, downReactors: downUsers)
  }
  
  
  
}


