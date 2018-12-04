//
//  UIImageView + Rounded.swift
//  ios-github-connector
//
//  Created by Liubov Fedorchuk on 12/4/18.
//  Copyright © 2018 Liubov Fedorchuk. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    func setRounded() {
        self.layer.cornerRadius = (self.frame.width / 2)
        self.layer.masksToBounds = true
    }
}
