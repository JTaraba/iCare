//
//  CreateEmployee.swift
//  
//
//  Created by Josh Taraba on 2021-02-02.
//

import Fluent

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.enum(Role.schema)
            .case("employee")
            .case("patient")
            .case("visitor")
            .case("admin")
            .create()
            .flatMap { role in
                database.schema(User.schema)
                    .id()
                    .field("firstName", .string, .required)
                    .field("lastName", .string, .required)
                    .field("username", .string, .required)
                    .field("password", .string, .required)
                    .field("role", role, .required)
                    .unique(on: "username")
                    .create()
            }
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema)
            .delete()
    }
}
