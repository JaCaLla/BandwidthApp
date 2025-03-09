//
//  ContentView.swift
//  BandwidthApp
//
//  Created by Javier Calatrava on 9/3/25.
//

import SwiftUI
import Network
import Combine

struct ContentView: View {
    @StateObject private var networkMonitor = BandwidthViewModel()
    @State private var speedWithSlicing: Double?
    @State private var speedWithoutSlicing: Double?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("5G Network Slicing Test")
                .font(.title)
                .padding()
            
            Text("Current Network: \(networkMonitor.currentNetwork)" )
            Text("Slicing Active: \(networkMonitor.is5GSlicing ? "Yes" : "No")")
            
            Button("Test Speed with Slicing") {
                Task {
                    guard let speed = await networkMonitor.testSpeed() else  { return }
                    speedWithSlicing = speed
                }
            }
            .disabled(!networkMonitor.is5GSlicing)
            
            Button("Test Speed without Slicing") {
                Task {
                    guard let speed = await networkMonitor.testSpeed() else  { return }
                    speedWithoutSlicing = speed
                }
            }
            .disabled(networkMonitor.is5GSlicing)
            
            
            if let slicingSpeed = speedWithSlicing {
                Text("Speed with Slicing: \(String(format: "%.2f", slicingSpeed)) Mbps")
            }
            
            if let noSlicingSpeed = speedWithoutSlicing {
                Text("Speed without Slicing: \(String(format: "%.2f", noSlicingSpeed)) Mbps")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
