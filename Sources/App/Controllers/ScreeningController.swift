import Vapor
import Leaf

struct ScreeningController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let screenRoutes = routes.grouped("screening")
        screenRoutes.get(use: screenHandler)
        screenRoutes.post(use: screenPostHandler)
        screenRoutes.get("fail", use: failScreenHandler)
        screenRoutes.post("fail", use: failScreenPostHandler)
    }
    
    // MARK: - Screening Handlers
    
    func screenHandler(_ req: Request) -> EventLoopFuture<View> {
        return req.view.render("screening")
    }
    
    func screenPostHandler(_ req: Request) throws -> Response {
        let data = try req.content.decode(ScreeningFormData.self)
        //let loginRedirect = req.redirect(to: "login")
        
        if data.answer {
            // if answer yes to something
            return req.redirect(to: "screening/fail")
        }
        
        return req.redirect(to: "profile")
    }
    
    
    // MARK: - Failed Screening Handlers
    
    func failScreenHandler(_ req: Request) -> EventLoopFuture<View> {
        req.view.render("screenfail")
    }
    
    func failScreenPostHandler(_ req: Request) throws -> Response {
        let res = try req.content.decode(FailScreeningData.self)

        if res.understand {
            return req.redirect(to: "/profile")
        }
        
        return req.redirect(to: "/login")
    }
}

// MARK: - Screening structure

struct ScreeningFormData: Content {
    let answer: Bool
}

// MARK: - Fail Screening structure

struct FailScreeningData: Content {
    let understand: Bool
}
