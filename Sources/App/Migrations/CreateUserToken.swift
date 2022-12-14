//
//  File.swift
//  
//
//  Created by Liam Jones on 22/06/2022.
//

import Fluent

struct CreateUserToken: AsyncMigration {
  
  func prepare(on database: Database) async throws {
    try await database.schema("user_tokens")
      .id()
      .field("value", .string, .required)
      .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
      .unique(on: "value")
      .create()
  }
  
  func revert(on database: Database) async throws {
    try await database.schema("user_tokens").delete()
  }
}
