//
//  GenerationTracking.swift
//  Evolution Simulator
//
//  Created by Don Espe on 12/2/23.
//

import Foundation

struct GenerationTracking: Identifiable {
    let id = UUID()
    var generation = 0
    var totalBugs = 0
    var totalLeaves = 0
    var totalMoves = 0 {
        didSet {
            averageMoves = totalMoves / totalBugs
        }
    }

    var collisions = 0
    var highestMoves = 0
    var oldestBug = 0
    var minMoves = 0
    var leavesEaten = 0
    var averageMoves = 0
    var lastCouldSee = false

    var bugsCollectedLeaves = 0
    var sightedCollectedLeaves = 0
    var blindCollectedLeaves = 0
    var numberFromPrevious = 0
}
