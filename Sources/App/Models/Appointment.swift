//
//  File.swift
//  
//
//  Created by Josh Taraba on 2021-04-07.
//

import Vapor
import Fluent

final class Appointment: Model, Encodable {
    static let schema = "appointments"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "date")
    var date: String
    
    @Parent(key: "userID")
    var patient: User
    
    @Parent(key: "userID2")
    var doctor: User
    
    init() {}
    
    init(id:UUID? = nil, name: String, description: String, date: String, userID: User.IDValue, userID2: User.IDValue){
        self.id = id
        self.name = name
        self.description = description
        self.date = date
        self.$patient.id = userID
        self.$doctor.id = userID2
    }
}

extension Appointment: Content {}
