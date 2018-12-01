//
//  UserManager.swift
//  ios-github-connector
//
//  Created by Liubov Fedorchuk on 12/1/18.
//  Copyright © 2018 Liubov Fedorchuk. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

/**
    # Service
 
    Usage: To get GitHub users.
 
    Created using [GitHub API]
 
    [GitHub API]: https://api.github.com/
 
 */


class UserManager {
    
    let BASE_URL = "https://api.github.com"
    
    func getUsers(completionHandler: @escaping ([User]?, Int?) -> Void) {
        Alamofire.request(BASE_URL + "/users",
                          method: .get,
                          parameters: nil,
                          encoding: JSONEncoding.default).validate().responseArray() {
                            (response: DataResponse<[User]>) in
                            let status = response.response?.statusCode
                            switch response.result {
                            case .success:
                                guard status == 200 else {
                                    log.debug("Request passed with status code, but not 200 OK: \(status!)")
                                    completionHandler(nil, status!)
                                    return
                                }
                                
                                let articleData = response.result.value!
                                completionHandler(articleData, status!)
                            case .failure(let error):
                                guard status == nil else {
                                    log.debug("Request failure with status code: \(status!)")
                                    completionHandler(nil, status!)
                                    return
                                }
                                
                                log.error("Request failure with error: \(error as! String)")
                                completionHandler(nil, nil)
                            }
        }
    }
}
