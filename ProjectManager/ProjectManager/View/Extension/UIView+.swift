//
//  UIView+.swift
//  ProjectManager
//
//  Created by 맹선아 on 2023/01/13.
//

import UIKit

extension UIView {
    
    convenience init(backgroundColor: UIColor? = .clear ) {
        self.init(frame: .zero)
        self.backgroundColor = backgroundColor
        translatesAutoresizingMaskIntoConstraints = false
    }
}
