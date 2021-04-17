//
//  CreateAdminUser.swift
//  
//
//  Created by Mansur Ahmed on 2021-04-05.
//

import Fluent
import Vapor

struct CreateAdminUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        let passwordHash: String
        
        do {
            passwordHash = try Bcrypt.hash("password")
        } catch {
            return database.eventLoop.future(error: error)
        }
        
        let admin = User(firstName: "Admin", lastName: "Admin", username: "admin", password: passwordHash, role: .admin)
        let doctor = User(firstName: "Test", lastName: "Doctor", username: "testdoc", password: passwordHash, role: .employee)
     
        _ = admin.save(on: database)
        return doctor.save(on: database)
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        User.query(on: database)
            .filter(\.$username == "admin")
            .delete()
    }
}
