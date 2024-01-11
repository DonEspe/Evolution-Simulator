//
//  ContentView.swift
//  Evolution Simulator
//
//  Created by Don Espe on 11/27/23.
//

import SwiftUI
import Charts
import Subsonic

let playSize = CGSize(width: 330, height: 310)
let buffer = CGFloat(20.0)
let strideBy = 6.0
let testing = false

enum SecondaryViewType {
    case bug
    case generations
    case graph
}

struct ContentView: View {
    let timer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()

    @State var colony = [Bug]()
    @State var leaves = [Leaf]()
    @State var records = [GenerationTracking]()

    @State var highestMoves = 0
    @State var generation = 0
    @State var moves = 0

    @State var paused = false
    //    @State var showingPopover = false
    @State var secondaryView: SecondaryViewType = .graph
    @State var scrollPosition = 0
    //    @State var showChart = true
    @State var tappedBug = UUID()
    @State var showHealth = true
    @State var showSightLines = false

    @StateObject private var eatSound = SubsonicPlayer(sound: "eat.mp3")
    @StateObject private var dieSound = SubsonicPlayer(sound: "drop_002.mp3")


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
                Toggle("Show Health", isOn: $showHealth)
                Toggle("Show Sight", isOn: $showSightLines)
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
                                    secondaryView = .bug
                                }

// draw lines to show sight area.
                        if bug.seeOnlyAhead && bug.moveTowardLeaf && showSightLines {
                            Rectangle()
                                .frame(width: 2, height: bug.sightRange, alignment: .top)
                                .padding(.bottom, bug.sightRange)
                                .rotationEffect(Angle(radians: bug.trueHeading() - (bug.sightAngle / 2)), anchor: .center)
                                .position(x: bug.position.x , y: bug.position.y)
                                .foregroundColor(.green.opacity(0.5))


                            Rectangle()
                                .frame(width: 2, height: 40, alignment: .center)
                                .padding(.bottom, 40)
                                .rotationEffect(Angle(radians: bug.trueHeading()), anchor: .center)
                                .foregroundColor(.blue.opacity(0.5))
                                .position(x: bug.position.x , y: bug.position.y)

                            Rectangle()
                                .frame(width: 2, height: bug.sightRange, alignment: .bottom)
                                .padding(.bottom, (bug.sightRange))
                                .rotationEffect(Angle(radians: bug.trueHeading() + (bug.sightAngle / 2)), anchor: .center)
                                .foregroundColor(.green.opacity(0.5))
                                .position(x: bug.position.x , y: bug.position.y)
                        }
// put white circle for parent bugs
                        Circle()
                            .stroke(lineWidth: 3.0)
                            .frame(width: 8, height: 8)
                            .position(bug.position)
                            .foregroundStyle(bug.bugsSpawned > 0 ? .white : .clear)
// put yellow circle for child bugs
                        Circle()
                            .stroke(lineWidth: 2.0)
                            .frame(width: 8, height: 8)
                            .position(bug.position)
                            .foregroundStyle(bug.spawnedBy != nil ? .yellow : .clear)
                        //                            .foregroundStyle(bug.findClosest ? .green : .blue)

                        if tappedBug == bug.id {
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

            switch secondaryView {
                case .bug:
                    VStack {
                        Spacer()
                            .frame(height: 20)
                        Text("Clicked on:")
                            .font(.title)
                            .fontWeight(.bold)
                        if let showBug = findBug(withId: tappedBug, in: colony) {
                            let displayBug = colony[showBug]

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
                            Text("Heading: \((String(format: "%0.2f", displayBug.trueHeading() * 180 / .pi)))")
                            HStack {
                                Text("Sight range: \((String(format: "%0.1f", displayBug.sightRange)))")
                                Text("Sight angle: \((String(format: "%0.1f", (displayBug.sightAngle * 180) / .pi)))")
                            }


                            HStack {
                                if displayBug.moveTowardLeaf {
                                    Text("Bug Moves Toward Leaf")
                                }

                                if displayBug.findClosest {
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
                            HStack {
                                Text("Spawned: \(displayBug.bugsSpawned)")
                                Spacer()
                                Text("Gen #\(displayBug.genNumber)")
                            }
                            Spacer()

                        } else {
                            Spacer()
                            Text("This bug has been removed.")
                                .fontWeight(.semibold)
                            Spacer()
                            Text("Select a different bug.")
                                .fontWeight(.bold)
                            Spacer()
                        }
                        HStack {
                            Button("Generation View") {
                                secondaryView = .generations
                            }
                            Spacer()
                            Button("Chart View") {
                                secondaryView = .graph
                            }
                        }
                        .padding(.horizontal)
                    }
                    .font(.subheadline)//                    .onTapGesture {
//                        secondaryView = .generations
//                        //                        showingPopover = false
//                    }
                case .generations:
                    VStack(alignment: .center, spacing: 0) {
                        Spacer()
                            .frame(height: 40)
                        Text("Records:")
                            .font(.title)
                            .fontWeight(.bold)
                        List(records) { record in
                            GenerationView(record: record)
                        }
                    }
                    HStack {
                        Button("Chart View") {
                            secondaryView = .graph
                        }
                        Spacer()
                        Button("Bug View") {
                            secondaryView = .bug
                        }
                    }
                    .padding(.horizontal)
                case .graph:
                    VStack(alignment: .center, spacing: 0) {
                        Spacer()
                            .frame(height: 30)
                        ChartView(records: records)
                            .frame(height: 230)
                            .padding()
                            .border(.blue.opacity(0.6))
                    }
                    HStack {
                        Button("Generation View") {
                            secondaryView = .generations
                        }
                        Spacer()
                        Button("Bug View") {
                            secondaryView = .bug
                        }
                    }
                    .padding(.horizontal)
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
                //                colony = populateColony(numberOfBugs: 1)

                //MARK: Insert top bugs from previous generation + Add to age

                for bug in survivedBugs {
                    colony.append(bug)
                }


                leaves = spawnLeaves(number: 5 + Int.random(in: -4...5) + (colony.count / 2))
                //                leaves = spawnLeaves(number: 20)

                if testing {
                    colony = populateColony(numberOfBugs: 1)
                    leaves = spawnLeaves(number: 1)
                }

                records[generation - 1].totalLeaves = leaves.count
                records[generation - 1].totalBugs = numberAlive() //colony.count

                for (index, bug) in colony.enumerated() {

                    for checkBug in colony {
                        var count = 0
                        while checkBug.position.distance(from: colony[index].position) < 20 && count <= 20 {
                            count += 1
                            colony[index].position = CGPoint(x: CGFloat.random(in: buffer...(playSize.width - buffer)),
                                                             y: CGFloat.random(in: buffer...(playSize.height - buffer)))
                        }
                    }

                    //                        if let spawnedBy = bug.spawnedBy {
                    //                            if let parentIndex = findBug(withId: spawnedBy) {
                    //                                print("bug id spawned by: ", spawnedBy)
                    //                                self.colony[parentIndex].bugsSpawned += 1
                    //                            }
                    //                        }

                    if bug.alive && bug.age > records[generation - 1].oldestBug {
                        records[generation - 1].oldestBug = bug.age
                        //                        print("updated age to ", bug.age)
                    }
                }
            }

            performMoves()
        })
    }

    func findBug(withId: UUID, in colony: [Bug]) -> Int? {
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
                //TODO: Play eat sound...
                eatSound.play()
            }

            if colony[i].alive {
                colony[i] = moveBug(bug: colony[i])
                if colony[i].energy <= 0 {
                    bugsToRemove.append(i)
                    colony[i].alive = false
                    dieSound.play()
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
            let bugPosition = CGPoint(x: CGFloat.random(in: buffer...(playSize.width - buffer)),
                                      y: CGFloat.random(in: buffer...(playSize.height - buffer)))

            //            var bug = Bug(position: CGPoint(x: 20 * Double(i) + buffer, y: 20 * Double(i) + buffer), color: .blue)
            var bug = Bug(position: bugPosition, color: .blue)
            bug.speed.dx = 5 + Double.random(in: -5...5)
            bug.speed.dy = 5 + Double.random(in: -5...5)
            bug.color = bug.age < colors.count ? colors[bug.age] : .red  //  colors.randomElement() ?? .blue
            bug.changeSpeed = Bool.random()
            bug.seeOnlyAhead = Bool.random()
            bug.sightRange = CGFloat.random(in: 25...200)
            bug.sightAngle = CGFloat.random(in: 0.44...2.8)
            bug.findClosest = Bool.random()
            bug.moveTowardLeaf = Bool.random()
            if bug.findClosest {
                bug.moveTowardLeaf = true
            }

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

            if distance < 50 && abs(changeBetweenAngles(angle1: angleBetween(point1: bug.position, point2: target.position), angle2: bug.trueHeading())) < .pi * 0.5 {
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
        for (index, leaf) in leaves.enumerated() { //FIXME: maybe record all leaves found and then check if distance in range
            //            print("bug range: ", bug.sightRange + bug.totalSpeed,", leaf distance: ", distance(bug.position, leaf.position),", inRange: ", inRange)
            if distance(bug.position, leaf.position) < inRange + bug.totalSpeed {
                //                print("leaf in range...")
                if ignoreSight || !bug.seeOnlyAhead || abs((angleBetween(point1: bug.position, point2: leaf.position) - bug.trueHeading())) < bug.sightAngle {
                    leavesSeen.append((number: index, distance(bug.position, leaf.position)))
                    //                    print("found leaf")
                    if !bug.findClosest {
                        return index
                    }
                }
            }
        }

        guard !leavesSeen.isEmpty else { return nil }
        //        print("leaves seen: ", leavesSeen.count)

        // Find closest leaf
        var shortestDistance = leavesSeen.first!.distance  //TODO: modify to find highest energy level
        var useLeaf = leavesSeen.first!.number
        for leaf in leavesSeen {
            if leaf.distance < shortestDistance {
                shortestDistance = leaf.distance
                useLeaf = leaf.number
            }
        }
        //        print("aim toward leaf #", useLeaf," at a distance of ", shortestDistance)
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

            survived = Array(Set(survived))

            if bug.leavesCollected >= 2 {
                survived.append(bug)
            }

            survived = Array(Set(survived))

            if bug.leavesCollected > 3 {
                var tempBug = bug

                if let parentIndex = findBug(withId: bug.id, in: survived) {
                    survived[parentIndex].bugsSpawned += 1
                }

                tempBug.id = UUID()
                tempBug.spawnedBy = bug.id
                tempBug.genNumber += 1
                tempBug.bugsSpawned = 0

                tempBug.age = 0
                survived.append(tempBug)
                //                print("bug spawned new bug. Gen #", tempBug.genNumber)
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

        if tempBug.changeSpeed { //} && !bug.moveTowardLeaf {
            tempBug.speed.dx += Double.random(in: -0.5...0.5)
            tempBug.speed.dy += Double.random(in: -0.5...0.5)
        }
        //        print("move bug")
        //        print("moveToward: ", tempBug.moveTowardLeaf,", findClosest: ", tempBug.findClosest)

        if tempBug.moveTowardLeaf || tempBug.findClosest {
            //            print("Bug should move toward leaf")
            if let foundLeaf = findLeaf(bug: tempBug, leaves: leaves, inRange: tempBug.sightRange, ignoreSight:
                                            !tempBug.seeOnlyAhead) {
                //                print("aim toward leaf")
                //                print("aim toward leaf #", foundLeaf," at a distance of ",  distance(bug.position, leaves[foundLeaf].position))


                let angle = angleBetween(point1: leaves[foundLeaf].position, point2: tempBug.position)
                //                var adjustAngleBy:CGFloat = -0.1

                //                if angle > tempBug.trueHeading() {
                //                    adjustAngleBy = 0.1
                //                }

                //                print("true heading before adjust: ", tempBug.heading, ", totalSpeed: ", tempBug.totalSpeed)

                let newDx = tempBug.totalSpeed * cos(angle ) //cos(tempBug.heading + adjustAngleBy - .pi / 2)// + adjustAngleBy) // cos(angle)
                let newDy = tempBug.totalSpeed * sin(angle ) //(tempBug.heading + adjustAngleBy - .pi / 2)// + adjustAngleBy) //sin(angle)

                tempBug.speed = CGVector(dx: newDx, dy: newDy)
                //                print("true heading after adjust: ", tempBug.heading, ", totalSpeed: ", tempBug.totalSpeed)
            }// else if tempBug.changeSpeed {
             //                tempBug.speed.dx += Double.random(in: -1...1)
             //                tempBug.speed.dy += Double.random(in: -1...1)
             //            }
        }

        if let avoidBug = bugInPath(bug: tempBug, colony: colony) {
            let angle = angleBetween(point1: avoidBug.position, point2: tempBug.position)

            var adjust = -0.1

            if changeBetweenAngles(angle1: angle, angle2: tempBug.trueHeading()) < 0
            {
                adjust = 0.1
            }

            if abs(changeBetweenAngles(angle1: angle, angle2: tempBug.trueHeading())) < .pi * 0.75 {

                let turnBy:CGFloat = adjust // (Bool.random() ? adjust : -adjust)

                let newDx = tempBug.totalSpeed * cos(tempBug.heading + turnBy) //- .pi / 2 ) //(Bool.random() ? .pi / 2 : -.pi / 2))
                let newDy = tempBug.totalSpeed * sin(tempBug.heading + turnBy) // - .pi / 2 ) //(Bool.random() ? .pi / 2 : -.pi / 2))

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

let scrollTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

struct ChartView: View {

    var records = [GenerationTracking]()
    @State var scrollPosition = 0
    let chartSize = 10

    var body: some View {

        let leavesTemp = records.map { $0.totalLeaves }
        let leavesMin = 0.0 // leaves.min() ?? 0
        let leavesMax = leavesTemp.max() ?? 1

        let bugsTemp = records.map { $0.totalBugs }
        //        let bugsMin = bugsTemp.min() ?? 0
        let bugsMax =  bugsTemp.max() ?? 1

        let survivedTemp = records.map { $0.numberFromPrevious }
        //        let survivedMin = survivedTemp.min() ?? 0
        let survivedMax = survivedTemp.max() ?? 5


        let highestTemp = records.map { $0.highestMoves }
        let useHighestMoves = highestTemp.max() ?? 100

        var useMax = Double(max(bugsMax, survivedMax, leavesMax, 14))

        //                        let useHighestMoves = highestMoves > 0 ? highestMoves : 1

        Chart(records) {
            LineMark(
                x: .value("Generation", $0.generation - 1),
                y: .value("Leaves", Double($0.totalLeaves) / useMax )

            )
            .foregroundStyle(.green)
            .symbol(.circle)
            .foregroundStyle(by: .value("Value", "Leaves"))

            LineMark(
                x: .value("Generation", $0.generation - 1),
                y: .value("Total Bugs", Double($0.totalBugs) / useMax)
            )
            .foregroundStyle(.blue)
            .symbol(.circle)
            .foregroundStyle(by: .value("Value", "Bugs"))

            LineMark(
                x: .value("Generation", $0.generation - 1),
                y: .value("Bugs Survived", Double($0.numberFromPrevious) / useMax)
            )
            .foregroundStyle(.purple)
            .symbol(.circle)
            .foregroundStyle(by: .value("Value", "Survived"))

            LineMark(
                x: .value("Generation", $0.generation - 1),
                y: .value("Oldest Bug", Double($0.oldestBug) / useMax)
            )
            .foregroundStyle(.yellow)
            .symbol(.circle)
            .foregroundStyle(by: .value("Value", "Oldest"))

            LineMark(
                x: .value("Generation", $0.generation - 1),
                y: .value("Highest Moves", Double($0.highestMoves) / Double(useHighestMoves))

            )
            .foregroundStyle(.gray)
            .symbol(.circle)
            .foregroundStyle(by: .value("Value", "Highest Moves"))

            LineMark(
                x: .value("Generation", $0.generation - 1),
                y: .value("Average Moves", Double($0.averageMoves) / Double(useHighestMoves))

            )
            .foregroundStyle(Color.teal)
            .symbol(.circle)
            .foregroundStyle(by: .value("Value", "Avg Moves"))

        }
        .chartYAxis {
            let defaultStride = Array(stride(from: 0, through: 1, by: 1.0 / strideBy))
            let leavesStride = Array(stride(from: Double(leavesMin),
                                            through: Double(useMax),
                                            by: Double((useMax - leavesMin)) / (strideBy)))

            AxisMarks(preset: .aligned, position: .leading, values: defaultStride) { axis in
                AxisGridLine()
                let value = leavesStride[axis.index]
                AxisValueLabel("\(String(format: "%2.0F", value))", centered: false)
                    .foregroundStyle(Color.green)
            }

            let movesStride = Array(stride(from: 0.0,
                                           through: Double(useHighestMoves),
                                           by: Double(useHighestMoves) / strideBy))
            AxisMarks(preset: .aligned, position: .trailing, values: defaultStride) { axis in
                AxisGridLine()
                let value = movesStride[axis.index]
                AxisValueLabel("\(String(format: "%2.0F", value))", centered: false)
            }
        }
        .chartXAxis {
            AxisMarks(preset: .aligned, values: .automatic(desiredCount: chartSize))
        }
        .chartXVisibleDomain(length: chartSize)
        .chartScrollableAxes(.horizontal)
        .chartScrollPosition(x: $scrollPosition)
        //        .chartScrollPosition(initialX: finalPostion)
//        .onChange(of: scrollPosition) {
//            print("Scroll position: ", scrollPosition)
//        }
        .onReceive(scrollTimer, perform: { _ in
            scrollPosition = records.count
        })

        .chartForegroundStyleScale([
            "Bugs": .blue,
            "Leaves": .green,
            "Survived": .purple,
            "Oldest": .yellow,
            "Highest Moves": .gray,
            "Avg Moves": .teal

        ])

    }
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
        .font(.monospaced(.caption)())
    }
}

