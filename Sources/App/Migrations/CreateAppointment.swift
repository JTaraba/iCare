//
//  File.swift
//  
//
//  Created by Josh Taraba on 2021-04-07.
//

import Fluent
import Vapor

struct CreateAppointment: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("appointments")
            .id()
            .field("name", .string, .required)
            .field("description", .string, .required)
            .field("date", .string, .required)
            .field("userID", .uuid, .required, .references("users", "id"))
            .field("userID2", .uuid, .required, .references("users", "id"))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("appointments").delete()
    }
}
