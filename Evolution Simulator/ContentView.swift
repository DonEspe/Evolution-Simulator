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
                    .font(.largeTitle)
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
                for i in 0...8 {
                    var ant = Ant(position: CGPoint(x: 10 * Double(i) + buffer, y: 10 * Double(i) + buffer), color: .blue)
                    ant.speed.dx = 10 + Double.random(in: -10...10)
                    ant.speed.dy = 10 + Double.random(in: -10...10)
                    ant.color = colors.randomElement() ?? .blue
                    colony.append(ant)
                }
            }
        }
        .onReceive(timer, perform: { _ in
            for i in 0...colony.count - 1 {

                colony[i].position.x += colony[i].speed.dx
                colony[i].position.y += colony[i].speed.dy

                if colony[i].position.x > playSize.width + buffer || colony[i].position.x < buffer {
                    colony[i].speed.dx = -colony[i].speed.dx
                }

                if colony[i].position.y > playSize.height + buffer || colony[i].position.y < buffer {
                    colony[i].speed.dy = -colony[i].speed.dy
                }
            }
        })
        .animation(.smooth, value: colony)
    }

    //func moveAnt(ant:
}

#Preview {
    ContentView()
}
