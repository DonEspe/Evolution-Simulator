//
//  Ant.swift
//  Evolution Simulator
//
//  Created by Don Espe on 11/27/23.
//

import Foundation
import SwiftUI

let maxSpeed = CGFloat(8)

let colors: [Color] = [.blue, .purple, .teal, .yellow, .cyan, .indigo, .mint, .orange, .red]

struct  Bug: Identifiable, Equatable {
    var id =  UUID()
    var position: CGPoint
    var speed = CGVector(dx: 0.0, dy: 0.0) {
        didSet {

            if speed.dx > maxSpeed {
                speed.dx = maxSpeed
            }
            if speed.dx < -maxSpeed {
                speed.dx = -maxSpeed
            }

            if speed.dy > maxSpeed {
                speed.dy = maxSpeed
            }
            if speed.dy < -maxSpeed {
                speed.dy = -maxSpeed
            }

            totalSpeed = sqrt(speed.dx * speed.dx + speed.dy * speed.dy)

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

    var totalSpeed: CGFloat = 0

    var color: Color

    var heading: Double = 0

    var changeSpeed = false

    var energy: Double = 10 {
        didSet {
            if energy > topEnergy {
                topEnergy = energy
            }
        }
    }

    var topEnergy: Double = 10

    var moves = 0

    var leavesCollected = 0
}
