//
//  ContentView.swift
//  Evolution Simulator
//
//  Created by Don Espe on 11/27/23.
//

import SwiftUI

let playSize = CGSize(width: 300, height: 300)
let buffer = CGFloat(30.0)

struct ContentView: View {
    let timer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()

    @State var colony = [Bug]()
    @State var leaves = [Leaf]()
    @State var highestMoves = 0
    @State var generation = 0
    @State var moves = 0

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Generation: \(generation)")
                    .font(.monospaced(.body)())
                    .padding()
                Spacer()
                Text("Highest: \(highestMoves)")
                    .font(.monospaced(.body)())
                    .padding()
            }
            HStack {
                Text("Bugs: \(colony.count)")
                    .font(.monospaced(.body)())
                    .padding()
                Spacer()
                Text("Leaves: \(leaves.count)")
                    .font(.monospaced(.body)())
                Spacer(minLength: 2)
                Text("Moves: \(String(format: "%04d", moves))")
                    .font(.monospaced(.body)())
                    //                Text(String(format: "%08d", moves))
//                    .frame(minWidth: 150)
//                    .fixedSize()
                    .padding()
            }

            ZStack {
                ForEach(colony) { bug in
                    Image(systemName: "ladybug") //"microbe")
                        .imageScale(.large)
                    //                    .font(.largeTitle)
                        .rotationEffect(Angle(radians: bug.heading))
                        .foregroundStyle(bug.energy > 1 ? bug.color : .gray)
                        .position(bug.position)
                }

                ForEach(leaves) { leaf in
                    Image(systemName: "leaf")
                        .imageScale(.large)
                        .rotationEffect(Angle(degrees: 0))
                        .foregroundStyle(.green)
                        .position(leaf.position)
                }

                Rectangle()
                    .stroke()
                    .frame(width: playSize.width + 20, height: playSize.height + 20)
                    .position(CGPoint(x: buffer + playSize.width / 2, y: buffer + playSize.height / 2))

            }
            .animation(.smooth, value: colony)
        }
        .onAppear {
//            if colony.isEmpty {
//                colony = populateColony(numberOfBugs: 5)
//            }
        }
        .onReceive(timer, perform: { _ in
            if colony.isEmpty {
                moves = 0
                generation += 1
                print("Highest moves: ", highestMoves, "after ", generation, " generations.")
                colony = populateColony(numberOfBugs: 5 + Int.random(in: 0...10))
                leaves = spawnLeaves(number: 5 + Int.random(in: -4...5))
            }
            var bugsToRemove = [Int]()
            guard colony.count > 0 else { return }

            moves += 1

            for i in 0...colony.count - 1 {
                if let foundLeafIndex = findLeaf(bug: colony[i], leaves: leaves) {
                    colony[i].energy += leaves[foundLeafIndex].energyLevel
                    leaves.remove(at: foundLeafIndex)
                }
                colony[i] = moveBug(bug: colony[i])
                if colony[i].energy <= 0 {
                    bugsToRemove.append(i)
                }
                }

            for index in bugsToRemove.sorted(by: >) {
                colony.remove(at: index)
            }
        })

    }

    func populateColony(numberOfBugs: Int) -> [Bug] {
        var colony = [Bug]()

        for i in 0...numberOfBugs - 1 {
            var bug = Bug(position: CGPoint(x: 20 * Double(i) + buffer, y: 20 * Double(i) + buffer), color: .blue)
            bug.speed.dx = 5 + Double.random(in: -5...5)
            bug.speed.dy = 5 + Double.random(in: -5...5)
            bug.color = colors.randomElement() ?? .blue
            bug.changeSpeed = Bool.random()
            colony.append(bug)
        }

        return colony
    }

    func spawnLeaves(number: Int) -> [Leaf] {
        var leaves = [Leaf]()
        for _ in 0...number - 1 {
            let leaf = Leaf(position: CGPoint(
                x: CGFloat.random(in: (buffer)...(playSize.width + buffer)),
                y: CGFloat.random(in: (buffer)...(playSize.height + buffer))))
            leaves.append(leaf)
        }
        return leaves
    }

    func testCollision(bug: Bug, colony: [Bug]) -> Bool {
//        let bugVelocity = abs(bug.speed.dx) + abs(bug.speed.dy)

        for target in colony {
            guard target.id != bug.id else {
                continue
            }

            if distance(target.position, bug.position) < 12 {
                return true
            }
        }

        return false
    }

    func findLeaf(bug: Bug, leaves: [Leaf]) -> Int? {
        for (index, leaf) in leaves.enumerated() {
            if distance(bug.position, leaf.position) < 12 {
                return index
            }
        }

        return nil
    }

    func distance(_ point1: CGPoint, _ point2: CGPoint) -> Double {
        let part1 = point1.x - point2.x
        let part2 = point1.y - point2.y
        return sqrt(part1 * part1 + part2 * part2)
    }

    func moveBug(bug: Bug) -> Bug {
        var tempBug = bug

        tempBug.energy -= 0.1
        tempBug.moves += 1

        if tempBug.moves > highestMoves {
            highestMoves = tempBug.moves
        }

//        if tempBug.energy < 0.5 {
//            tempBug.color = .gray
//        }

        if testCollision(bug: bug, colony: colony) {
            tempBug.speed.dx = -tempBug.speed.dx
            tempBug.speed.dy = -tempBug.speed.dy

            tempBug.position.x += tempBug.speed.dx
            tempBug.position.y += tempBug.speed.dy

            return tempBug
        }

        if bug.changeSpeed {
            tempBug.speed.dx += Double.random(in: -1...1)
            tempBug.speed.dy += Double.random(in: -1...1)
        }

        tempBug.position.x += tempBug.speed.dx
        tempBug.position.y += tempBug.speed.dy

        // Check if in borders declared at top of file.
        if tempBug.position.x > playSize.width + buffer {
            tempBug.speed.dx = -tempBug.speed.dx
            tempBug.position.x = playSize.width + buffer - 3
        }

        if tempBug.position.x < buffer {
            tempBug.speed.dx = -tempBug.speed.dx
            tempBug.position.x = buffer + 3
        }

        if tempBug.position.y > playSize.height + buffer {
            tempBug.speed.dy = -tempBug.speed.dy
            tempBug.position.y = playSize.height + buffer - 3
        }

        if tempBug.position.y < buffer {
            tempBug.speed.dy = -tempBug.speed.dy
            tempBug.position.y = buffer + 3
        }

        return tempBug
    }
}

#Preview {
    ContentView()
}
