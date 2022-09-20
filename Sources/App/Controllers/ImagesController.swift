//
//  File.swift
//
//
//  Created by Liam Jones on 07/07/2022.



import Fluent
import Vapor


struct ImagesController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let imageRoutes = routes.grouped("api", "images", ":imgID")
    imageRoutes.get(use: getImage)
    
    let tokenProtected = imageRoutes.grouped(UserToken.authenticator(), User.guardMiddleware())
    tokenProtected.post(use: uploadImage)
    tokenProtected.delete(use: deleteImage)
  }
  
  
  func uploadImage(req: Request) async throws -> HTTPStatus {
    print("Upload img route hit.")
    guard let imgID = req.parameters.get("imgID") else { throw Abort(.notFound) }
    guard let imgData = req.body.data else { throw Abort(.badRequest) }
    print("Upload img route hit id is \(imgID) and data is \(imgData).")
    try await req.fileio.writeFile(imgData, at: req.application.directory.resourcesDirectory + imgID)
    return .created
  }
  
  func getImage(req: Request) async throws -> Response {
    guard let imgID = req.parameters.get("imgID") else { throw Abort(.notFound) }
    return req.fileio.streamFile(at: req.application.directory.resourcesDirectory + imgID)
  }

  func deleteImage(req: Request) async throws -> HTTPStatus {
    guard let imgID = req.parameters.get("imgID") else { throw Abort(.notFound) }
    try FileManager.default.removeItem(atPath: req.application.directory.resourcesDirectory + imgID)
    return .noContent
  }



}
