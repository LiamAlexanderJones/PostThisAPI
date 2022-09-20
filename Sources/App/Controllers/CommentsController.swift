//
//  File.swift
//  
//
//  Created by Liam Jones on 20/06/2022.
//

import Fluent
import Vapor

struct CommentsController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let comments = routes.grouped("comments")
    comments.get(use: index)
    comments.post(use: create)
    comments.group(":commentID") { comment in
      comment.delete(use: delete)
    }
  }
  //TODO: FIX
  
  func getCommentsForPost(post Post, req: Request) async throws -> [Comment] {
    let comments = try await post.$comments.get(on: req.db)
    return comments
  }
  
  func addCommentToPost(post: Post, req: Request) async throws -> Comment {
    let newComment = try req.content.decode(Comment.self)
    try await post.$comments.create(newComment, on: req.db)
    return comment
  }

  
  //TODO: implement delete

    func delete(req: Request) async throws -> HTTPStatus {
        guard let todo = try await Todo.find(req.parameters.get("todoID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await todo.delete(on: req.db)
        return .noContent
    }
}
