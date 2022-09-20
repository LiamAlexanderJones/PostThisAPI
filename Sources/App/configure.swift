import Fluent
import FluentPostgresDriver
import Vapor
import Foundation

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
 //  app.middleware.use(FileMiddleware(publicDirectory: app.directory.workingDirectory))
  app.routes.defaultMaxBodySize = "10mb"
  


    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "postgres",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "postthis"
    ), as: .psql)


  app.migrations.add(CreateUser())
  app.migrations.add(CreateUserToken())
  app.migrations.add(CreatePost())
  app.migrations.add(CreateComment())
  app.migrations.add(CreateReaction())

    // register routes
    try routes(app)
  
  try app.autoMigrate().wait()
}
