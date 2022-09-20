//
//  File.swift
//  
//
//  Created by Liam Jones on 31/07/2022.
//


import Fluent

struct CreateReaction: AsyncMigration {
  func prepare(on database: Database) async throws {
    
    try await database.enum("reaction_type")
      .case("like")
      .case("up")
      .case("down")
      .create()
    
    let reactionType = try await database.enum("reaction_type").read()
    
    try await database.schema("reactions")
      .id()
      .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
      .field("post_id", .uuid, .references("posts", "id", onDelete: .cascade))
      .field("comment_id", .uuid, .references("comments", "id", onDelete: .cascade))
      .field("type", reactionType, .required)
      .unique(on: "user_id", "post_id", "type")
      .create()
  }
  
  func revert(on database: Database) async throws {
    try await database.schema("reactions").delete()
    try await database.enum("reaction_type").delete()
  }
}



