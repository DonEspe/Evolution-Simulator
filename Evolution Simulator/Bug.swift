//
//  Ant.swift
//  Evolution Simulator
//
//  Created by Don Espe on 11/27/23.
//

import Foundation
import SwiftUI

let maxSpeed = CGFloat(8)

let colors: [Color] = [.blue, .teal, .cyan, .purple, .indigo, .mint, .yellow, .orange, .red]

struct Bug: Identifiable, Equatable, Hashable {
    var id =  UUID()

    var sightRange:CGFloat = 120.0
    var alive = true
    var age = 0

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

    var previousChange: CGVector = .zero

    var totalSpeed: CGFloat = 0

    var color: Color

    var heading: Double = 0

    var energy: Double = 10 {
        didSet {
            if energy > topEnergy {
                topEnergy = energy
            }

            if energy < 0 {
                energy = 0
            }
        }
    }

    var topEnergy: Double = 10

    var moves = 0
    var collision = 0

    var leavesCollected = 0

    var bugsSpawned = 0
    var spawnedBy: UUID? = nil
    var genNumber = 0

    var changeSpeed = false
    var moveTowardLeaf = true
    var findClosest = false
    var seeOnlyAhead = false
    var sightAngle:CGFloat = (.pi / 5) //(2 * .pi / 3)

    func trueHeading() -> CGFloat {
        var tempHeading = heading

        while tempHeading < 0 {
            tempHeading += 2 * .pi
        }

        while tempHeading > 2 * .pi {
            tempHeading -= 2 * .pi
        }
        return tempHeading
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
