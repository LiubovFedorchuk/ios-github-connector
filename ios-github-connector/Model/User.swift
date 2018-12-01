//
//  User.swift
//  ios-github-connector
//
//  Created by Liubov Fedorchuk on 12/1/18.
//  Copyright © 2018 Liubov Fedorchuk. All rights reserved.
//

import Foundation
import ObjectMapper

/**
    # Model
 
    Model User inherited public protocol Mappable:
    - for mapping object User from JSON format.
 
    Created using [GitHUb API: Users]
 
    [GitHub API: Users]: https://api.github.com/users
 
 */

class User: Mappable {
    var username: String?
    var userUrl: String?
    var avatarUrl: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        username           <- map["login"]
        userUrl            <- map["html_url"]
        avatarUrl          <- map["avatar_url"]
    }
}
