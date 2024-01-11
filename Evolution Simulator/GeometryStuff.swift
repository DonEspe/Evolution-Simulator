//
//  GeometryStuff.swift
//  Evolution Simulator
//
//  Created by Don Espe on 1/10/24.
//

import SwiftUI

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout Value, nextValue: () -> Value) { }
}

public extension View {
    /// - Parameters:
    ///     - callBack: Block called after the size has been measured
    func calculateFrame(_ callBack: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader {
                Color.clear.preference(key: SizePreferenceKey.self,
                                       value: $0.frame(in: .local).size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self) { callBack($0) }
    }///Func ends
}

//MARK: Example usage...

//struct ContentView: View {
//    @State private var labelWidth: CGFloat = 0
//    @State private var labelHeight: CGFloat = 0
//
//    var body: some View {
//        VStack {
//            Text("Hello World")
//                .calculateFrame {   ///<---- Here you will get size
//                    labelWidth = $0.width
//                    labelHeight = $0.height
//                }
//                .padding()
//            Text("Text Width - \(labelWidth), \nText Height - \(labelHeight)")
//        }
//    }
//}
