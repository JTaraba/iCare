//
//  Employee.swift
//  
//
//  Created by Mansur Ahmed on 2021-02-12.
//

import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "firstName")
    var firstName: String

    @Field(key: "lastName")
    var lastName: String
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "password")
    var password: String
    
    @Children(for: \.$patient)
    var appointmentsP: [Appointment]
    
    @Children(for: \.$doctor)
    var appointmentsD: [Appointment]
    
    @Enum(key: "role")
    var role: Role
    
    init() {}

    init(id: UUID? = nil, firstName: String, lastName: String, username: String, password: String, role: Role) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.password = password
        self.role = role
    }
    
    final class Public: Content {
        var id: UUID?
        var firstName: String
        var lastName: String
        var username: String
        var role: Role
        
        init(id: UUID?, firstName: String, lastName: String, username: String, role: Role) {
            self.id = id
            self.firstName = firstName
            self.lastName = lastName
            self.username = username
            self.role = role
        }
    }
}

extension User {
    func convertToPublic() -> User.Public {
        return User.Public(id: id, firstName: firstName, lastName: lastName, username: username, role: role)
    }
}

extension EventLoopFuture where Value: User {
    func convertToPublic() -> EventLoopFuture<User.Public> {
        return self.map { user in
            return user.convertToPublic()
        }
    }
}

extension Collection where Element: User {
    func convertToPublic() -> [User.Public] {
        return self.map { $0.convertToPublic() }
    }
}

extension EventLoopFuture where Value == Array<User> {
    func convertToPublic() -> EventLoopFuture<[User.Public]> {
        return self.map { $0.convertToPublic() }
    }
}

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$username
    static let passwordHashKey = \User.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}

extension User: ModelSessionAuthenticatable {}

extension User: ModelCredentialsAuthenticatable {}
