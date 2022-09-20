//
//  File.swift
//  
//
//  Created by Liam Jones on 21/06/2022.
//

import Fluent

struct CreateComment: AsyncMigration {
  func prepare(on database: Database) async throws {
    try await database.schema("comments")
      .id()
      .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
      .field("post_id", .uuid, .required, .references("posts", "id"))
      .field("body", .string, .required)
      .field("createdAt", .datetime, .required)
      .field("hasImage", .bool, .required)
      .create()
  }
  
  func revert(on database: Database) async throws {
    try await database.schema("comments").delete()
  }
  
  
}
