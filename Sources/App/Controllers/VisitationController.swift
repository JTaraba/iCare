//
//  File.swift
//  
//
//  Created by Josh Taraba on 2021-04-09.
//

import Fluent
import Vapor

struct VisitationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let visitorRoutes = routes.grouped("visitor")
        visitorRoutes.get(use: indexHandler)
        
        visitorRoutes.get("register", use: getVisitationHandler)
        visitorRoutes.post("register",use: createVisitorPostHandler)
        
        visitorRoutes.get("screening", use: screenHandler)
        visitorRoutes.post("screening", use: screenPostHandler)
        
        visitorRoutes.get("screening","fail", use: failScreenHandler)
        visitorRoutes.post("screening","fail", use: failScreenPostHandler)

        visitorRoutes.get("visitation-times", use: indexHandler)
        visitorRoutes.get("visitation-times", ":patient", use: getVisitationTimesHandler)
    }
    
    func indexHandler(_ req: Request) -> Response {
        return req.redirect(to: "screening")
    }
    
    
    func screenHandler(_ req: Request) -> EventLoopFuture<View> {
        return req.view.render("visitorScreening")
    }
    
    func screenPostHandler(_ req: Request) throws -> Response {
        let data = try req.content.decode(VisitorScreeningFormData.self)
        //let loginRedirect = req.redirect(to: "login")
        
        if data.visitorAnswer {
            // if answer yes to something
            return req.redirect(to: "screening/fail")
        }
        
        return req.redirect(to: "register")
    }
    
    
    // MARK: - Failed Screening Handlers
    
    func failScreenHandler(_ req: Request) -> EventLoopFuture<View> {
        return req.view.render("visitorScreeningFail")
    }
    
    func failScreenPostHandler(_ req: Request) throws -> Response {
        let res = try req.content.decode(VisitorFailScreeningData.self)

        if res.understand {
            return req.redirect(to: "/")
        }
        
        return req.redirect(to: "/")
    }
    
    //MARK: - Create Visitor
    func getVisitationHandler(_ req: Request) -> EventLoopFuture<View> {
        let context: CreateVisitorContext
        
        if let error = req.query[Bool.self, at: "error"], error {
            context = CreateVisitorContext(error: true)
        } else {
            context = CreateVisitorContext()
        }
        
        return req.view.render("visitation", context)
    }
    
    func createVisitorPostHandler(_ req: Request) throws -> EventLoopFuture<Response>{
        let data = try req.content.decode(CreateVisitorData.self)
        
        return User.query(on: req.db).all().flatMap { users in
            let foundPatient = users.first(where: { $0.username == data.username && $0.role == .patient })
            
            if let _ = foundPatient {
                let visitor = Visitor(
                    firstName: data.firstName,
                    lastName: data.lastName
                )
                
                
                return visitor.save(on: req.db).transform(to: req.redirect(to: "visitation-times/\(data.username)"))
            }
            
            let context = CreateVisitorContext(error: true)
            return req.view.render("visitation", context).encodeResponse(for: req)
        }
    }
    
    func getVisitationTimesHandler(_ req: Request) -> EventLoopFuture<Response> {
        User.query(on: req.db).all().flatMap { users in
            let username: String = req.parameters.get("patient") ?? ""
            let user = users.first(where: { $0.username == username && $0.role == .patient })
            
            if let user = user {
                let context = VisitationTimeContext(user: user)
                return req.view.render("visitationTimes", context).encodeResponse(for: req)
            }
            
            return req.eventLoop.future(req.redirect(to: "screening"))
        }
    }
    
}

// MARK: - Screening structure

struct VisitorScreeningFormData: Content {
    let visitorAnswer: Bool
}

// MARK: - Fail Screening structure

struct VisitorFailScreeningData: Content {
    let understand: Bool
}

//MARK: - Visitor Structs

struct CreateVisitorContext: Encodable {
    let error: Bool
    
    init(error: Bool = false) {
        self.error = error
    }
}

struct CreateVisitorData: Content {
    let firstName: String
    let lastName: String
    let username: String
    let message: String
}

struct VisitationTimeContext: Encodable {
    let user: User
}
