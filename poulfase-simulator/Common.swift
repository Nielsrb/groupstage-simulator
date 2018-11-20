//
//  Common.swift
//  poulfase-simulator
//
//  Created by Niels Beeuwkes on 20/11/2018.
//  Copyright © 2018 Niels Beeuwkes. All rights reserved.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
    func bold(size: CGFloat) -> NSMutableAttributedString {
        let attr = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: size)]
        return NSMutableAttributedString(string: self.string, attributes: attr)
    }
}
