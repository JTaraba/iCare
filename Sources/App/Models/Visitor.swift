//
//  Visitor.swift
//  
//
//  Created by Josh Taraba on 2021-02-02.
//

import Vapor
import Fluent


final class Visitor: Model, Content {
    static let schema = "visitors"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "firstName")
    var firstName: String

    @Field(key: "lastName")
    var lastName: String
    
    @Enum(key: "role")
    var role: Role
    
    init() {}
    
    init(id: UUID? = nil, firstName: String, lastName: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.role = .visitor
    }
}
