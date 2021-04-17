//
//  File.swift
//  
//
//  Created by Mansur Ahmed on 2021-04-05.
//

import Fluent

struct CreateVisitor: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.enum(Role.schema)
            .read()
            .flatMap { role in
                database.schema(Visitor.schema)
                    .id()
                    .field("firstName", .string, .required)
                    .field("lastName", .string, .required)
                    .field("role", role, .required)
                    .create()
            }
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Visitor.schema).delete()
    }
}
