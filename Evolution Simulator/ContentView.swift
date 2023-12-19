//
//  ContentView.swift
//  Evolution Simulator
//
//  Created by Don Espe on 11/27/23.
//

import SwiftUI

let playSize = CGSize(width: 330, height: 310)
let buffer = CGFloat(20.0)

struct ContentView: View {
    let timer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()

    @State var colony = [Bug]()
    @State var leaves = [Leaf]()
    @State var records = [GenerationTracking]()

    @State var highestMoves = 0
    @State var generation = 0
    @State var moves = 0

    @State var paused = false
    @State var showingPopover = false
    @State var tappedBug = UUID()
    @State var showHealth = true

    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Text("Gen: \(generation)")
                    .font(.monospaced(.body)())
                    .padding(.horizontal)
                if !records.isEmpty {
                    Text("Oldest: \(records[generation - 1].oldestBug)")
                }
//                Spacer()
                Text("Highest: \(highestMoves)")
                    .font(.monospaced(.body)())
                    .padding(.horizontal)
//                Spacer()
//                if !records.isEmpty {
//                    Text("Collisions: \(records[generation - 1].collisions)")
//                }
            }

            HStack {
                //                Text("Bugs: \(colony.count)")
                Text("Bugs: \(numberAlive())")
                    .font(.monospaced(.body)())
                    .padding(.horizontal)
                Spacer()
                Text("Leaves: \(leaves.count)")
                    .font(.monospaced(.body)())
                Spacer(minLength: 2)
                Text("Moves: \(String(format: "%04d", moves))")
                    .font(.monospaced(.body)())
                    .padding(.horizontal)
            }

            HStack {
                if !records.isEmpty {
                    Text("Total Bugs: \(records[generation - 1].totalBugs)")
                    Spacer()
                    Text("Bugs survived: \(records[generation - 1].numberFromPrevious)")
                    Spacer()
                    Text("total leaves: \(records[generation - 1].totalLeaves)")
                }
            }
            HStack {
                Toggle("Pause", isOn: $paused)
//                Button("Pause") {
//                    paused.toggle()
//                }
//                .font(.title)
//                .foregroundColor(paused ? .gray : .blue)

                Toggle("Show Health", isOn: $showHealth)
            }

            ZStack {
                ForEach(colony) { bug in
                    if bug.alive {
                        if showHealth {
                            Rectangle()
                                .frame(width: 22, height: 4)
                                .position(CGPoint(x: bug.position.x, y: bug.position.y - 20))
                                .foregroundColor(bug.energy < 5 ? .red : .blue)

                            let adjustment = ((20 / bug.topEnergy) * bug.energy)

                            Rectangle()
                                .frame(width: 20 - adjustment, height: 2)
                                .position(CGPoint(x: bug.position.x + ( adjustment) / 2, y: bug.position.y - 20))
                                .foregroundColor(.black)
                        }

                        Image(systemName: "ladybug") //"microbe")
                            .imageScale(.large)
                            .rotationEffect(Angle(radians: bug.heading))
                            .foregroundStyle(bug.energy > 2 ? bug.color : .gray)
                            .position(bug.position)
                            .onTapGesture { pressed in
                                tappedBug = bug.id
                                showingPopover = true
                            }
                        
                        Circle()
                            .stroke(lineWidth: 3.0)
                            .frame(width: 8, height: 8)
                            .position(bug.position)
                            .foregroundStyle(bug.bugsSpawned > 0 ? .white : .clear)

//                            .foregroundStyle(bug.findClosest ? .green : .blue)

                        Circle()
                            .stroke(lineWidth: 2.0)
                            .frame(width: 8, height: 8)
                            .position(bug.position)
                            .foregroundStyle(bug.spawnedBy != nil ? .yellow : .clear)
                        //                            .foregroundStyle(bug.findClosest ? .green : .blue)

                        if tappedBug == bug.id && showingPopover {
                            Circle()
                                .stroke(lineWidth: 1.0)
                                .frame(width: 33, height: 33)
                                .position(bug.position)
                                .foregroundStyle(.white.blendMode(.difference))
                        }
                    }
                }

                ForEach(leaves) { leaf in
                    Image(systemName: "leaf")
                        .imageScale(.large)
                        .rotationEffect(Angle(degrees: 0))
                        .foregroundStyle(.green)
                        .position(leaf.position)
                }

                Rectangle()
                    .stroke(lineWidth: 2)
                    .frame(width: playSize.width + buffer, height: playSize.height + buffer)
                    .position(CGPoint(x: buffer + (playSize.width) / 2, y: buffer + (playSize.height) / 2))

            }
            .animation(.linear, value: colony)



                if showingPopover, let showBug = findBug(withId: tappedBug) {
                    let displayBug = colony[showBug]
                    VStack {
                        Spacer()
                            .frame(height: 20)
                        Text("Clicked on:")
                            .font(.title)
                            .fontWeight(.bold)
                        HStack {
                            Text("Color: \(displayBug.color.description.capitalized)")
                            Spacer()
                            Text("Age: \(displayBug.age)")
                        }
                        HStack {
                            Text("Energy: \((String(format: "%0.2f", displayBug.energy)))")
                            Text("Top Energy: \(String(format: "%0.2f", displayBug.topEnergy))")
                        }
                        HStack {
                            Text("Speed: \((String(format: "%0.2f", displayBug.totalSpeed)))")
                            Text("Speed Vector: \((String(format: "%0.2f", displayBug.speed.dx))), \((String(format: "%0.2f",displayBug.speed.dy)))")
                        }
                        HStack {
                            Text("Heading: \((String(format: "%0.2f", displayBug.trueHeading() * 180 / .pi)))")
                            Text("Sight range: \((String(format: "%0.1f", displayBug.sightRange)))")
                        }

                        HStack {
                            if displayBug.moveTowardLeaf && !displayBug.findClosest{
                                //                            Text("Bug Moves Toward Leaf: \(displayBug.moveTowardLeaf.description)")
                                Text("Bug Moves Toward Leaf")
                            } else {
                                Text("Bug Finds Closest Leaf")
                            }
                            if displayBug.changeSpeed {
                                Text("Bug can change speed")
                            }
                        }
                        if displayBug.seeOnlyAhead {
                            Text("Bug can only see ahead")
                        }
//                        Text("Bug Finds Closest Leaf: \(displayBug.findClosest.description)")

//                        Text("Bug Changes Speed: \(displayBug.changeSpeed.description)")
                        Text("Leaves Collected: \(displayBug.leavesCollected)")
                        HStack {
                            Text("Moves: \(displayBug.moves)")
                            Spacer()
                            Text("Collisions: \(displayBug.collision)")
                        }
                        Text("Spawned: \(displayBug.bugsSpawned)")
                        Spacer()
                    }
                    .onTapGesture {
                        showingPopover = false
                    }
                } else {
                    VStack(alignment: .center) {
                        Spacer()
                            .frame(height: 20)
                        Text("Records:")
                            .font(.title)
                            .fontWeight(.bold)
                        List(records) { record in
                            GenerationView(record: record)
                        }
                    }
                }
        }
        .onAppear {
            // Do stuff when view first appears...
        }
        .onReceive(timer, perform: { _ in
            if paused {
                return
            }

//            if colony.isEmpty {
            if numberAlive() == 0 {
                print("new generation")

                //MARK: Collect top bugs and allow to move to new generation

                var survivedBugs = [Bug]()

                if !records.isEmpty {
                    survivedBugs = surviveGeneration(colony: colony, genRecords: records[generation - 1])
                }

                moves = 0
                generation += 1
//                print("tracking: ", records)
                records.append(GenerationTracking(generation: generation))
                records[generation - 1].numberFromPrevious = survivedBugs.count
//                colony = populateColony(numberOfBugs: 5 + Int.random(in: 0...10))  //TODO: adjust for bugs carried over

                colony = populateColony(numberOfBugs: Int.random(in: 1...5))
                //MARK: Insert top bugs from previous generation + Add to age

                for bug in survivedBugs {
                    colony.append(bug)
                }

//                colony = populateColony(numberOfBugs: 3)
                leaves = spawnLeaves(number: 5 + Int.random(in: -4...5) + (colony.count / 2))

                records[generation - 1].totalLeaves = leaves.count
                records[generation - 1].totalBugs = numberAlive() //colony.count

                for bug in colony {
                    if let spawnedBy = bug.spawnedBy {
                        if let parentIndex = findBug(withId: spawnedBy) {
                            self.colony[parentIndex].bugsSpawned += 1
                        }
                    }

                    if bug.alive && bug.age > records[generation - 1].oldestBug {
                        records[generation - 1].oldestBug = bug.age
                        print("updated age to ", bug.age)
                    }
                }
            }

            performMoves()
        })
    }

    func findBug(withId: UUID) -> Int? {
        for (index, bug) in colony.enumerated() {
            if bug.id == withId {
                return index
            }
        }

        return nil
    }

    func performMoves() {
        var bugsToRemove = [Int]()

        guard numberAlive() > 0 else { return }

        moves += 1

        records[generation - 1].highestMoves += 1

        for i in 0...colony.count - 1 {
            if let foundLeafIndex = findLeaf(bug: colony[i], leaves: leaves, ignoreSight: true) {
                records[generation - 1].leavesEaten += 1
                colony[i].energy += leaves[foundLeafIndex].energyLevel
                colony[i].leavesCollected += 1

                if colony[i].moveTowardLeaf {
                    records[generation - 1].sightedCollectedLeaves += 1
                } else {
                    records[generation - 1].blindCollectedLeaves += 1
                }

                if colony[i].leavesCollected == 1 {
                    records[generation - 1].bugsCollectedLeaves += 1
                }
                leaves.remove(at: foundLeafIndex)
            }

            if colony[i].alive {
                colony[i] = moveBug(bug: colony[i])
                if colony[i].energy <= 0 {
                    bugsToRemove.append(i)
                    colony[i].alive = false
                    if colony[i].moves < records[generation - 1].minMoves || records[generation - 1].minMoves == 0 {
                        records[generation - 1].minMoves = colony[i].moves
                    }
                }
            }
        }

        for index in bugsToRemove.sorted(by: >) {
            if numberAlive() == 1 {  //colony.count
                records[generation - 1].lastCouldSee = colony[index].moveTowardLeaf
            }
//            colony.remove(at: index)
        }
    }

    func populateColony(numberOfBugs: Int) -> [Bug] {
        var colony = [Bug]()

        for _ in 0...numberOfBugs - 1 {
            var bugPosition = CGPoint(x: CGFloat.random(in: buffer...(playSize.width - buffer)),
                                      y: CGFloat.random(in: buffer...(playSize.height - buffer)))

            for checkBug in colony {
                var count = 0
                while checkBug.position.distance(from: bugPosition) < 20 && count <= 20 {
                    count += 1
                    bugPosition = CGPoint(x: CGFloat.random(in: buffer...(playSize.width - buffer)),
                                          y: CGFloat.random(in: buffer...(playSize.height - buffer)))
                }
            }
//            var bug = Bug(position: CGPoint(x: 20 * Double(i) + buffer, y: 20 * Double(i) + buffer), color: .blue)
            var bug = Bug(position: bugPosition, color: .blue)
            bug.speed.dx = 5 + Double.random(in: -5...5)
            bug.speed.dy = 5 + Double.random(in: -5...5)
            bug.color = bug.age < colors.count ? colors[bug.age] : .red  //  colors.randomElement() ?? .blue
            bug.changeSpeed = Bool.random()
            bug.moveTowardLeaf = Bool.random()
            bug.findClosest = Bool.random()
            bug.seeOnlyAhead = Bool.random()
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

    func bugInPath(bug: Bug, colony: [Bug]) -> Bug? {
        var bugsInRange = [(bug:Bug, distance: CGFloat)]()
        for target in colony {
            guard target.id != bug.id && target.alive else {
                continue
            }

            let distance = distance(target.position, bug.position)

            if distance < 50 && abs(changeBetweenAngles(angle1: angleBetween(point1: bug.position, point2: target.position), angle2: bug.trueHeading())) < .pi * 0.75 {
                //abs(((angleBetween(point1: bug.position, point2: target.position) ) - bug.trueHeading())) < ( .pi  ) {
                bugsInRange.append((target, distance))
            }
        }

        guard !bugsInRange.isEmpty else { return nil }

        var shortestDistance = bugsInRange.first!.distance
        var closestBug = bugsInRange.first!.bug

        for target in bugsInRange {
            if target.distance < shortestDistance {
                closestBug = target.bug
                shortestDistance = target.distance
            }
        }

        return closestBug
    }

    func testCollision(bug: Bug, colony: [Bug]) -> Bool {

        for target in colony {
            guard target.id != bug.id else {
                continue
            }

            if distance(target.position, bug.position) < 8 + bug.totalSpeed && target.alive {
                return true
            }
        }

        return false
    }

    func findLeaf(bug: Bug, leaves: [Leaf], inRange: CGFloat = 8, ignoreSight: Bool = false) -> Int? {
        //find first
        var leavesSeen = [(number: Int, distance: CGFloat)]()
        for (index, leaf) in leaves.enumerated() {
            if distance(bug.position, leaf.position) < inRange + bug.totalSpeed {
                if ignoreSight || !bug.seeOnlyAhead || abs((angleBetween(point1: bug.position, point2: leaf.position) - bug.trueHeading())) < (2 * .pi / 3) {
                    leavesSeen.append((number: index, distance(bug.position, leaf.position)))
                    if !bug.findClosest {
                        return index
                    }
                }
            }
        }

        guard !leavesSeen.isEmpty else { return nil }

        // Find closest leaf
        var shortestDistance = CGFloat.greatestFiniteMagnitude  //TODO: modify to find highest energy level
        var useLeaf = leavesSeen.first?.number
        for leaf in leavesSeen {
            if leaf.distance < shortestDistance {
                shortestDistance = leaf.distance
                useLeaf = leaf.number
            }
        }

        return useLeaf
    }

    func numberAlive() -> Int {
        return colony.reduce(0) { $0 + ($1.alive ? 1 : 0) }
    }

    func surviveGeneration(colony: [Bug], genRecords: GenerationTracking) -> [Bug] {
        var survived = [Bug]()

        //decide if bugs go to next generation...
        for bug in colony {
            if bug.alive {
                survived.append(bug)
            }

            if bug.moves > genRecords.averageMoves {
                survived.append(bug)
            }

            if bug.leavesCollected >= 2 {
                survived.append(bug)
            }

            if bug.leavesCollected > 3 {
                var tempBug = bug
                tempBug.id = UUID()
                tempBug.spawnedBy = bug.id

//                if let parentIndex = findBug(withId: bug.id) {
//                    self.colony[parentIndex].bugsSpawed += 1
//                }

                tempBug.age = 0
                survived.append(tempBug)
                print("bug spawned new bug...")
            }
        }

        //reset survived bugs...
        survived = Array(Set(survived))

        for (index, _ ) in survived.enumerated() {

            survived[index].moves = 0
            survived[index].alive = true
            survived[index].age += 1
            survived[index].leavesCollected = 0
            survived[index].energy = 10 //TODO: figure out good start energy for bugs
            survived[index].topEnergy = survived[index].energy
            survived[index].color = survived[index].age < colors.count ? colors[survived[index].age] : .red
        }

//        records[generation - 1].numberFromPrevious = survived.count

        print(survived.count, " bugs survived to next generation.")

        return survived
    }

    func distance(_ point1: CGPoint, _ point2: CGPoint) -> Double {
        let part1 = point1.x - point2.x
        let part2 = point1.y - point2.y
        return sqrt(part1 * part1 + part2 * part2)
    }

    func angleBetween(point1: CGPoint, point2: CGPoint) -> CGFloat {
        let deltaX = point1.x - point2.x
        let deltaY = point1.y - point2.y

        var angle = atan2(deltaY, deltaX)

        if angle < 0 {
            angle += 2 * .pi
        }

        if angle > 2 * .pi {
            angle -= 2 * .pi
        }

//        print("angle: ", angle)

        return angle
    }

    func changeBetweenAngles(angle1: CGFloat, angle2: CGFloat) -> CGFloat {
        var change = angle1 - angle2

        if change > .pi {
            change -= 2 * .pi
        }

        if change < -.pi {
            change += 2 * .pi
        }

        return change
    }

    func moveBug(bug: Bug) -> Bug {
        var tempBug = bug

        tempBug.energy -=  0.05 + bug.totalSpeed / 100
        tempBug.moves += 1
        records[generation - 1].totalMoves += 1

        if tempBug.moves > highestMoves {
            highestMoves = tempBug.moves
        }

        if tempBug.changeSpeed {
            tempBug.speed.dx += Double.random(in: -1...1)
            tempBug.speed.dy += Double.random(in: -1...1)
        }

        if bug.moveTowardLeaf {
            if let foundLeaf = findLeaf(bug: tempBug, leaves: leaves, inRange: bug.sightRange) {

                let angle = angleBetween(point1: leaves[foundLeaf].position, point2: tempBug.position)

                let newDx = tempBug.totalSpeed * cos(angle)
                let newDy = tempBug.totalSpeed * sin(angle)

                tempBug.speed = CGVector(dx: newDx, dy: newDy)
            }
        }

        if let avoidBug = bugInPath(bug: tempBug, colony: colony) {
            let angle = angleBetween(point1: avoidBug.position, point2: tempBug.position)
//            print("Angle between: ", angle, ", bug heading: ", tempBug.trueHeading(), ", change: ", changeBetweenAngles(angle1: angle, angle2: tempBug.trueHeading()))
            var adjust = -0.1
//            if angle < bug.trueHeading()
            if changeBetweenAngles(angle1: angle, angle2: tempBug.trueHeading()) < 0
            {
                adjust = 0.1
            }

            if abs(changeBetweenAngles(angle1: angle, angle2: tempBug.trueHeading())) < .pi * 0.75 {

                let turnBy:CGFloat = adjust // (Bool.random() ? adjust : -adjust)

                let newDx = tempBug.totalSpeed * cos(tempBug.heading + turnBy ) //(Bool.random() ? .pi / 2 : -.pi / 2))
                let newDy = tempBug.totalSpeed * sin(tempBug.heading + turnBy ) //(Bool.random() ? .pi / 2 : -.pi / 2))

                tempBug.speed = CGVector(dx: newDx, dy: newDy)
            }
        }

        if testCollision(bug: bug, colony: colony) {
            tempBug.collision += 1
            records[generation - 1].collisions += 1
            tempBug.speed.dx = -tempBug.speed.dx
            tempBug.speed.dy = -tempBug.speed.dy

            tempBug.position.x += tempBug.speed.dx
            tempBug.position.y += tempBug.speed.dy

//            return tempBug
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

struct GenerationView: View {
    var record: GenerationTracking

    var body: some View {

        VStack {
            HStack {
                Spacer()
                Text("Generation: \(record.generation)")
                    .fontWeight(.bold)
                Spacer()
            }
            HStack {
                Text("Oldest: \(record.oldestBug)")
                Spacer()
                Text("From prev: \(record.numberFromPrevious)")
            }

            HStack {
                Text("Total bugs: \(record.totalBugs)")
                Spacer()
                Text("Total leaves: \(record.totalLeaves)")
            }
            HStack {
                Text("Leaves eaten: \(record.leavesEaten)")
                Spacer()
                Text("Least moves: \(record.minMoves )")
            }

            HStack {
                Text("Blind ate: \(record.blindCollectedLeaves)")
                Spacer()
                Text("Sighted ate: \(record.sightedCollectedLeaves)")
            }
            HStack {
                Text("Bugs that ate: \(record.bugsCollectedLeaves)")
                if record.lastCouldSee {
                    Text("Last could see")
                }
            }
            HStack {
                Text("Total moves: \(record.totalMoves)")
                Spacer()
                Text("Collisions: \(record.collisions)")
            }
            HStack {
                Text("Average moves: \(record.averageMoves)")
                Spacer()
                Text("Top moves: \(record.highestMoves)")
            }
            
        }
        .font(.monospaced(.body)())
    }
}
