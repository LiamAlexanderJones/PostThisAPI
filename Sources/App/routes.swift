import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }

    try app.register(collection: TodoController())
  try app.register(collection: UsersController())
  try app.register(collection: PostsController())
  try app.register(collection: CommentsController())
  try app.register(collection: ImagesController())
  
}
