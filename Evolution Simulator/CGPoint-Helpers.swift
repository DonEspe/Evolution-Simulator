//
//  CGPoint-Helpers.swift
//  Boids
//
//  Created by Paul Hudson on 03/10/2020.
//

import SwiftUI

extension CGPoint {
    var magnitude: CGFloat {
        distance(from: .zero)
    }

    var heading: Double {
        Double(-atan2(-y, x))
    }

    mutating func normalize() {
        let len = distance(from: .zero)
        self = CGPoint(x: self.x / len, y: self.y / len)
    }

    mutating func limit(to: CGFloat) {
        let length = magnitude

        if length > to {
            x *= to / length
            y *= to / length
        }
    }

    func distanceSquared(from: CGPoint) -> CGFloat {
        (self.x - from.x) * (self.x - from.x) + (self.y - from.y) * (self.y - from.y)
    }

    func distance(from: CGPoint) -> CGFloat {
        sqrt(distanceSquared(from: from))
    }

    static func *=(lhs: inout CGPoint, rhs: CGFloat) {
        lhs.x *= rhs
        lhs.y *= rhs
    }

    static func /=(lhs: inout CGPoint, rhs: CGFloat) {
        lhs.x /= rhs
        lhs.y /= rhs
    }

    static func +=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }

    static func -=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }

    static func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}
