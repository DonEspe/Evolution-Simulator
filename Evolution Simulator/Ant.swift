//
//  Ant.swift
//  Evolution Simulator
//
//  Created by Don Espe on 11/27/23.
//

import Foundation
import SwiftUI

let colors: [Color] = [.blue, .purple, .green, .teal, .brown, .yellow]

struct  Ant: Identifiable, Equatable {
    var id =  UUID()
    var position: CGPoint
    var xSpeed: Double = 0 {
        didSet {
            let oldHeading = heading
            heading = (atan2(ySpeed, xSpeed) + .pi / 2)
            if abs(oldHeading - heading) > .pi {
                if oldHeading < heading {
                    heading -= 2 * .pi
                } else {
                    heading += 2 * .pi
                }
            }
        }
    }
    var ySpeed: Double = 0 {
        didSet {
            let oldHeading = heading
            heading = (atan2(ySpeed, xSpeed) + .pi / 2)

            if abs(oldHeading - heading) > .pi {
                if oldHeading < heading {
                    heading -= 2 * .pi
                } else {
                    heading += 2 * .pi
                }
            }
        }
    }
    var color: Color

    var heading: Double = 0
}
