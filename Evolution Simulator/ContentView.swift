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

    @State var ant = Ant(position: CGPoint(x: 30, y: 50), xSpeed: 15.0, ySpeed: 10.0, color: .blue)

    @State var colony = [Ant]()

    var body: some View {

        ZStack {
            ForEach(colony) { ant in
                Image(systemName: "ant")
                    .imageScale(.large)
                    .font(.largeTitle)
                //                .rotationEffect(Angle(degrees: reverse ? 270: 90))
                //                .rotationEffect(Angle(radians: (atan2(ant.ySpeed, ant.xSpeed) + .pi / 2)))
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
            ant.xSpeed = 20
            ant.ySpeed = 15

            if colony.isEmpty {
                for i in 0...5 {
                    var ant = Ant(position: CGPoint(x: 10 * Double(i) + buffer, y: 10 * Double(i) + buffer), color: .blue)
                    ant.xSpeed = 10 + Double.random(in: -10...10)
                    ant.ySpeed = 10 + Double.random(in: -10...10)
                    ant.color = colors.randomElement() ?? .blue
                    colony.append(ant)
                }
            }
        }
        .onReceive(timer, perform: { _ in

            for i in 0...colony.count - 1 {

                colony[i].position.x += colony[i].xSpeed
                colony[i].position.y += colony[i].ySpeed

                if colony[i].position.x > playSize.width + buffer || colony[i].position.x < buffer {
                    colony[i].xSpeed = -colony[i].xSpeed
                }

                if colony[i].position.y > playSize.height + buffer || colony[i].position.y < buffer {
                    colony[i].ySpeed = -colony[i].ySpeed
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
