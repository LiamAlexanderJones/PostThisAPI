//
//  File.swift
//  
//
//  Created by Liam Jones on 20/06/2022.
//
import Fluent

struct CreateUser: AsyncMigration {
  
  func prepare(on database: Database) async throws {
    try await database.schema("users")
      .id()
      .field("username", .string, .required)
      .field("password_hash", .string, .required)
      .field("followed_users", .array(of: .uuid), .required)
      .unique(on: "username")
      .create()
  }
  
  func revert(on database: Database) async throws {
    try await database.schema("users").delete()
  }
}
