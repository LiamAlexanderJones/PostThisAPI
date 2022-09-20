//
//  File.swift
//  
//
//  Created by Liam Jones on 26/06/2022.
//

import Fluent

struct CreatePost: AsyncMigration {
  
  func prepare(on database: Database) async throws {
    try await database.schema("posts")
      .id()
      .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
      .field("body", .string, .required)
      .field("createdAt", .datetime, .required)
      .field("hasImage", .bool, .required)
      .create()
  }
  
  func revert(on database: Database) async throws {
    try await database.schema("posts").delete()
  }
  
}
