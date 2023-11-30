//
//  ContentView.swift
//  Evolution Simulator
//
//  Created by Don Espe on 11/27/23.
//

import SwiftUI

let playSize = CGSize(width: 300, height: 300)
let buffer = 30.0

struct ContentView: View {
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    @State var colony = [Bug]()

    var body: some View {

        ZStack {
            ForEach(colony) { bug in
                Image(systemName: "ladybug") //"microbe")
                    .imageScale(.large)
//                    .font(.largeTitle)
                    .rotationEffect(Angle(radians: bug.heading))
                    .foregroundStyle(bug.color)
                    .position(bug.position)
            }

            Image(systemName: "leaf")
                .imageScale(.large)
                .rotationEffect(Angle(degrees: 0))
                .foregroundStyle(.green)
                .position(CGPoint(x: 30, y: 200))

            Rectangle()
                .stroke()
                .frame(width: playSize.width + 20, height: playSize.height + 20)
                .position(CGPoint(x: buffer + playSize.width / 2, y: buffer + playSize.height / 2))

        }
        .onAppear {
            if colony.isEmpty {
                colony = populateColony(numberOfBugs: 5)
            }
        }
        .onReceive(timer, perform: { _ in
            for i in 0...colony.count - 1 {
                colony[i] = moveBug(bug: colony[i])
            }
        })
        .animation(.smooth, value: colony)
    }

    func populateColony(numberOfBugs: Int) -> [Bug] {
        var colony = [Bug]()

        for i in 0...numberOfBugs - 1 {
            var bug = Bug(position: CGPoint(x: 30 * Double(i) + buffer, y: 30 * Double(i) + buffer), color: .blue)
            bug.speed.dx = 5 + Double.random(in: -5...5)
            bug.speed.dy = 5 + Double.random(in: -5...5)
            bug.color = colors.randomElement() ?? .blue
            bug.changeSpeed = Bool.random()
            colony.append(bug)
        }

        return colony

    }

    func testCollision(bug: Bug, colony: [Bug]) -> Bool {
        let bugVelocity = abs(bug.speed.dx) + abs(bug.speed.dy)

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

    func distance(_ point1: CGPoint, _ point2: CGPoint) -> Double {
        let part1 = point1.x - point2.x
        let part2 = point1.y - point2.y
        return sqrt(part1 * part1 + part2 * part2)
    }

    func moveBug(bug: Bug) -> Bug {
        var tempBug = bug

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
