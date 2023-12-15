//
//  Leaf.swift
//  Evolution Simulator
//
//  Created by Don Espe on 11/30/23.
//

import Foundation

struct Leaf: Identifiable {
    var id = UUID()
    var position: CGPoint
    var energyLevel = 10.0  //TODO: make random energy levels....
}
