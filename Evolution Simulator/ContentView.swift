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
    @State var antPosition = CGPoint(x: 30.0, y: 50.0)

    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    @State var colony = [Ant]()

    var body: some View {

        ZStack {
            ForEach(colony) { ant in
                Image(systemName: "ant")
                    .imageScale(.large)
//                    .font(.largeTitle)
                    .rotationEffect(Angle(radians: ant.heading))
                    .foregroundStyle(ant.color)
                    .position(ant.position)
            }

            Image(systemName: "leaf")
                .imageScale(.large)
                .rotationEffect(Angle(degrees: 0))
                .foregroundStyle(.green)
                .position(CGPoint(x: 30, y: 200))
        }
        .onAppear {
            if colony.isEmpty {
                colony = populateColony(numberOfAnts: 20)
            }
        }
        .onReceive(timer, perform: { _ in
            for i in 0...colony.count - 1 {
                colony[i] = moveAnt(ant: colony[i])
            }
        })
        .animation(.smooth, value: colony)
    }

    func populateColony(numberOfAnts: Int) -> [Ant] {
        var colony = [Ant]()

        for i in 0...numberOfAnts - 1 {
            var ant = Ant(position: CGPoint(x: 10 * Double(i) + buffer, y: 10 * Double(i) + buffer), color: .blue)
            ant.speed.dx = 10 + Double.random(in: -10...10)
            ant.speed.dy = 10 + Double.random(in: -10...10)
            ant.color = colors.randomElement() ?? .blue
            colony.append(ant)
        }

        return colony

    }

    func moveAnt(ant: Ant) -> Ant {
        var tempAnt = ant
        tempAnt.position.x += tempAnt.speed.dx
        tempAnt.position.y += tempAnt.speed.dy

        if tempAnt.position.x > playSize.width + buffer || tempAnt.position.x < buffer {
            tempAnt.speed.dx = -tempAnt.speed.dx
        }

        if tempAnt.position.y > playSize.height + buffer || tempAnt.position.y < buffer {
            tempAnt.speed.dy = -tempAnt.speed.dy
        }

        return tempAnt
    }
}

#Preview {
    ContentView()
}
