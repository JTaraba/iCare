//
//  File.swift
//
//
//  Created by Josh Taraba on 2021-04-07.
//

import Vapor
import Fluent

struct AppointmentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let appointmentRoutes = routes.grouped("appointments")
        appointmentRoutes.get(use: indexHandler)
        appointmentRoutes.get(":appointmentID", use: appointmentHandler) //specific appointments per user will need to add a different endpoint
        appointmentRoutes.post(":appointmentID", use: deleteAppointmentHandler)
        appointmentRoutes.get("new", use: createAppointmentHandler)
        appointmentRoutes.post("new", use: createAppointmentPostHandler)
    }
    
    func deleteAppointmentHandler(_ req: Request) -> EventLoopFuture<Response> {
        Appointment.find(req.parameters.get("appointmentID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { appointment in
                appointment.delete(on: req.db)
                    .transform(to: req.redirect(to: "/appointments"))
            }
    }
    
    func indexHandler(_ req: Request) throws -> EventLoopFuture<View> {
        let user = try req.auth.require(User.self)
        
        if user.role == .patient {
            return user.$appointmentsP.get(on: req.db).flatMap { appointments in
                print("count: \(appointments.count)")
                
                let context = IndexContext(appointments: appointments)
                
                return req.view.render("appointments", context)
            }
        } else {
            return user.$appointmentsD.get(on: req.db).flatMap { appointments in
                print("count: \(appointments.count)")
                
                let context = IndexContext(appointments: appointments)
                
                return req.view.render("appointments", context)
            }
        }
    }
    
    func appointmentHandler(_ req: Request) throws -> EventLoopFuture<View> {
        let user = try req.auth.require(User.self)
        
        return Appointment.find(req.parameters.get("appointmentID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { appointment in
                if user.role == .patient {
                    return appointment.$doctor.get(on: req.db).flatMap { user2 in
                            let context = AppointmentContext(title: appointment.name, appointment: appointment, user: user2)
                            
                            return req.view.render("appointment", context)
                    }
                } else {
                    return appointment.$patient.get(on: req.db).flatMap { user2 in
                            let context = AppointmentContext(title: appointment.name, appointment: appointment, user: user2)
                            
                            return req.view.render("appointment", context)
                    }
                }
            }
    }
    
    // MARK: - CREATE APPOINTMENT BUTTONS AND HANDLERS
    func createAppointmentHandler(_ req: Request) throws -> EventLoopFuture<View> {
        let user = try req.auth.require(User.self)
        
        return User.query(on: req.db).all().flatMap { users in
            let filteredUsers = users.filter {
                if user.role == .employee {
                    return $0.role == .patient
                } else if user.role == .patient {
                    return $0.role == .employee
                } else {
                    return false
                }
            }
            
            
            let context = CreateAppointmentContext(users: filteredUsers, role: user.role)
            return req.view.render("newAppointment", context)
        }
    }
    
    func createAppointmentPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let data = try req.content.decode(CreateAppointmentData.self)
        let date = "\(data.date) at \(data.time)"
        
        let user = try req.auth.require(User.self)
        let userID = try user.requireID()
        let userID2 = UUID.init(uuidString: data.id)!
        
        let appointment = Appointment(
            name: data.name,
            description: data.description,
            date: date,
            userID: user.role == .patient ? userID : userID2,
            userID2: user.role == .patient ? userID2 : userID
        )
        
        return appointment.save(on: req.db).transform(to: req.redirect(to: "/appointments"))
    }
    
}

// MARK: - STRUCTS
struct CreateAppointmentContext: Encodable {
    let title = "New Appointment"
    let users: [User]
    let role: Role
}

struct CreateAppointmentData: Content {
    let name: String
    let description: String
    let date: String
    let time: String
    let id: String
}

struct IndexContext: Encodable {
    let title = "Appointments"
    let appointments: [Appointment]
}

struct AppointmentContext: Encodable {
    let title: String
    let appointment: Appointment
    let user: User
}

struct UserContext: Encodable {
    let title: String
    let user: User
    let appointments: [Appointment]
}

//MARK: QUERIES
//Table.query(on: req.db).all() equivalent to SELECT * FROM TABLE
//Table.find(req.parameters.get("tableID"), on: req.db) Queries for an entry with the specific ID. returns one entry
