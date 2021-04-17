import Fluent
import Vapor

func routes(_ app: Application) throws {
    let usersController = UsersController()
    try app.register(collection: usersController)
    
    let visitationController = VisitationController()
    try app.register(collection: visitationController)
}
