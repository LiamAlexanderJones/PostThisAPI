//
//  File.swift
//  
//
//  Created by Liam Jones on 26/06/2022.
//


import Fluent
import Vapor
import Foundation




struct PostsController: RouteCollection {

  func boot(routes: RoutesBuilder) throws {
    let postRoutes = routes.grouped("api", "posts")
    postRoutes.get("global", ":page", ":resultsPerPage", use: getPaginatedGlobalPosts)
    
    postRoutes.get(":postID", "comments", ":page", ":resultsPerPage", use: getPaginatedCommentsForPost)
    postRoutes.get(":postID", "reactions", use: getReactorsToPost)
    
    let tokenProtected = postRoutes.grouped(UserToken.authenticator(), User.guardMiddleware())
    tokenProtected.get("main", ":page", ":resultsPerPage", use: getPaginatedMainFeedPosts)
    tokenProtected.post(use: addPost)
    tokenProtected.delete(":postID", use: deletePost)
    tokenProtected.post(":postID", "comments", use: addCommentToPost)
    tokenProtected.post(":postID", ":type", use: addReactionToPost)
    tokenProtected.delete(":postID", ":type", use: removeReactionFromPost)
  }
  

  //MARK: -Getting, adding and deleting posts
  
  func getPaginatedGlobalPosts(req: Request) async throws -> [Post.Get] {
    guard let page = req.parameters.get("page", as: Int.self) else {
      throw Abort(.badRequest)
    }
    guard let per = req.parameters.get("resultsPerPage", as: Int.self) else {
      throw Abort(.badRequest)
    }
    return try await Post.query(on: req.db)
      .with(\.$user)
      .sort(\.$createdAt, .descending)
      .paginate(PageRequest(page: page, per: per))
      .items
      .convertToGet()
  }
  
  
  func getPaginatedMainFeedPosts(req: Request) async throws -> [Post.Get] {
    //Gets posts by the current user and everyone they follow

    //There's no clean way to use paginate here, because different users might have made more or less posts over a given period of time. You can only find the page contents after you've combined the results and arranged them by date.
    //For the nth page, we pull n pages of posts for each user, combine them, then trim away everything before and after. This method is cheaper than pulling all the posts if the total number of posts is large AND the user only looks at the first few pages.
    guard let page = req.parameters.get("page", as: Int.self) else {
      throw Abort(.badRequest)
    }
    guard let per = req.parameters.get("resultsPerPage", as: Int.self) else {
      throw Abort(.badRequest)
    }
    let upperBound = page * per
    let lowerBound = (page - 1) * per
    let user = try req.auth.require(User.self)
    let followedUserIDs = user.followedUsers

    var posts = try await user.$posts.query(on: req.db)
      .with(\.$user)
      .sort(\.$createdAt, .descending)
      .range(..<upperBound)
      .all()

    for followedUserID in followedUserIDs {
      guard let followedUser = try await User.find(followedUserID, on: req.db) else {
        throw Abort(.notFound)
      }
      let followedUserPosts = try await followedUser.$posts.query(on: req.db)
        .with(\.$user)
        .sort(\.$createdAt, .descending)
        .range(..<upperBound)
        .all()
      posts.append(contentsOf: followedUserPosts)
    }

    let sorted = posts
      .sorted(by: { $0.createdAt > $1.createdAt} )
      .dropFirst(lowerBound)
      .prefix(per)

    return Array(sorted)
      .convertToGet()
  }


  func addPost(req: Request) async throws -> String {
    let user = try req.auth.require(User.self)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let postData = try req.content.decode(Post.Create.self, using: decoder)
    let newPost = try Post(userID: user.requireID(), body: postData.body, createdAt: postData.createdAt, hasImage: postData.hasImage)
    try await newPost.save(on: req.db)
    guard let idString = newPost.id?.uuidString else {
      throw Abort(.noContent)
    }
    return idString
  }
  
  
  func deletePost(req: Request) async throws -> HTTPStatus {
    let user = try req.auth.require(User.self)
    guard let post = try await Post.find(req.parameters.get("postID"), on: req.db) else {
      throw Abort(.notFound)
    }
    let id = try user.requireID()
    guard id == post.$user.id else {
      throw Abort(.unauthorized)
    }
    try await post.delete(on: req.db)
    return .noContent
  }
  
  
  //MARK: -Comment Routes
  
  func getPaginatedCommentsForPost(req: Request) async throws -> [Comment.Get] {
    guard let page = req.parameters.get("page", as: Int.self) else {
      throw Abort(.badRequest)
    }
    guard let per = req.parameters.get("resultsPerPage", as: Int.self) else {
      throw Abort(.badRequest)
    }
    guard let post = try await Post.find(req.parameters.get("postID"), on: req.db) else {
      throw Abort(.notFound)
    }
    return try await post.$comments.query(on: req.db)
      .with(\.$user)
      .sort(\.$createdAt, .descending)
      .paginate(PageRequest(page: page, per: per))
      .items
      .reversed()
      .convertToGet()
  }
  
  
  func addCommentToPost(req: Request) async throws -> String {
    let user = try req.auth.require(User.self)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let commentData = try req.content.decode(Comment.Create.self, using: decoder)
    let newComment = try Comment(userID: user.requireID(), postID: commentData.postID, body: commentData.body, createdAt: commentData.createdAt, hasImage: commentData.hasImage)
    try await newComment.save(on: req.db)
    guard let idString = newComment.id?.uuidString else {
      throw Abort(.noContent)
    }
    return idString
  }
  
  
  //MARK: -Reaction routes
  
  func addReactionToPost(req: Request) async throws -> HTTPStatus {
    let user = try req.auth.require(User.self)
    guard let post = try await Post.find(req.parameters.get("postID"), on: req.db) else {
      throw Abort(.notFound)
    }
    guard let type = ReactionType.fromString(req.parameters.get("type") ?? "") else {
      throw Abort(.badRequest)
    }
    let reaction = try Reaction(type: type, userID: user.requireID(), postID: post.requireID())
    try await reaction.save(on: req.db)
    return .created
  }
  
  func removeReactionFromPost(req: Request) async throws -> HTTPStatus {
    let user = try req.auth.require(User.self)
    guard let post = try await Post.find(req.parameters.get("postID"), on: req.db) else {
      throw Abort(.notFound)
    }
    guard let type = ReactionType.fromString(req.parameters.get("type") ?? "") else {
      throw Abort(.badRequest)
    }
    let reaction = try await post.$reactions.query(on: req.db)
      .join(User.self, on: \Reaction.$user.$id == \User.$id)
      .filter(User.self, \.$username == user.username)
      .filter(\.$type == type)
      .first()

    try await reaction?.delete(on: req.db)
    return .noContent
  }
  

  func getReactorsToPost(req: Request) async throws -> Reaction.Reactors {
    guard let post = try await Post.find(req.parameters.get("postID"), on: req.db) else {
      throw Abort(.notFound)
    }
    let reactions = try await post.$reactions.get(on: req.db)
    var likeUsers: [User.Public] = []
    var upUsers: [User.Public] = []
    var downUsers: [User.Public] = []

    for reaction in reactions {
      let user = try await reaction.$user.get(on: req.db).convertToPublic()
      switch reaction.type {
      case .like:
        likeUsers.append(user)
      case .up:
        upUsers.append(user)
      case .down:
        downUsers.append(user)
      }
    }
    return Reaction.Reactors(likeReactors: likeUsers, upReactors: upUsers, downReactors: downUsers)
  }
  
}






