//
//  Ant.swift
//  Evolution Simulator
//
//  Created by Don Espe on 11/27/23.
//

import Foundation
import SwiftUI

let colors: [Color] = [.blue, .purple, .green, .teal, .brown, .yellow, .cyan, .indigo, .mint, .orange, .red]

struct  Ant: Identifiable, Equatable {
    var id =  UUID()
    var position: CGPoint
    var speed = CGVector(dx: 0.0, dy: 0.0) {
        didSet {
            let oldHeading = heading
            heading = (atan2(speed.dy, speed.dx) + .pi / 2)
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
