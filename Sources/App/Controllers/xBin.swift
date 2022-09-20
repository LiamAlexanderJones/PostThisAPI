//
//  File.swift
//  
//
//  Created by Liam Jones on 16/08/2022.
//

import Foundation




//func getCommentsForPost(req: Request) async throws -> [Comment.Get] {
//  guard let post = try await Post.find(req.parameters.get("postID"), on: req.db) else {
//    throw Abort(.notFound)
//  }
//  
//  return try await post.$comments.query(on: req.db)
//    .with(\.$user)
//    .all()
//    .convertToGet()
//
////    return try await post.$comments.get(on: req.db)
////      .convertToGet()
//}


//func getPosts(req: Request) async throws -> [Post.Get] {
//  //Returns all posts
//  return try await Post.query(on: req.db)
//    .with(\.$user)
//    .sort(\.$createdAt)
//    .all()
//    .convertToGet()
//}

//func getMainFeedPosts(req: Request) async throws -> [Post.Get] {
//  //Gets posts by the current user and everyone they follow
//
//  let user = try req.auth.require(User.self)
//  let followedUserIDs = user.followedUsers //Turn into user object, then get posts?
//
//  var posts = try await user.$posts.query(on: req.db)
//    .with(\.$user)
//    .all()
//    .convertToGet()
//
//  for followedUserID in followedUserIDs {
//    guard let followedUser = try await User.find(followedUserID, on: req.db) else {
//      throw Abort(.notFound)
//    }
//    let followedUserPosts = try await followedUser.$posts.query(on: req.db)
//      .with(\.$user)
//      .all()
//      .convertToGet()
//    posts.append(contentsOf: followedUserPosts)
//  }
//
//  return posts.sorted { $0.createdAt < $1.createdAt }
//}


//func getUserPosts(req: Request) async throws -> [Post.Get] {
//  //Returns posts by a specified user. MIGHT NEED TO GO IN USERS
//
//  guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
//    throw Abort(.notFound)
//  }
//
//  return try await user.$posts.query(on: req.db)
//    .with(\.$user)
//    .all()
//    .convertToGet()
//
//}



