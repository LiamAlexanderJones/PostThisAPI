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
      .field("body", .string, .required)
      .field("createdAt", .date, .required)
      .field("createdBy", .string, .required)
      .field("hasImage", .bool, .required)
      .create()
  }
  
  func revert(on database: Database) async throws {
    try await database.schema("comments").delete()
  }
  
  //TODO: Do we need a special migration for comments as children?
  
}
