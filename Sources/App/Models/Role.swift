//
//  Role.swift
//  
//
//  Created by Mansur Ahmed on 2021-02-12.
//

import Vapor
    
enum Role: String {
    static let schema = "role"
    
    // add more as required
    case patient
    
    case visitor
    
    case employee
    
    case admin
    
    var clearance: Int {
        switch self {
        case .employee: return 1
        case .patient: return 3
        case .visitor: return 4
        case .admin: return -1
        }
    }
}

extension Role: Content {}
