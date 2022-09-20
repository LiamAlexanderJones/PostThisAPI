import Fluent
import Vapor

func routes(_ app: Application) throws {
  try app.register(collection: UsersController())
  try app.register(collection: PostsController())
  try app.register(collection: CommentsController())
  try app.register(collection: ImagesController())
}
