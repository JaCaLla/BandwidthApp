//
//  NetworkMonitor.swift
//  BandwidthApp
//
//  Created by Javier Calatrava on 9/3/25.
//

import SwiftUI
import Network
import CoreTelephony

class BandwidthViewModel: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private let telephonyInfo = CTTelephonyNetworkInfo()
    
    @Published var is5GSlicing = false
    @Published var currentNetwork = "Unknown"
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.usesInterfaceType(.cellular) {
                    self.currentNetwork = "Cellular"
                    self.check5GStatus()
                } else if path.usesInterfaceType(.wifi) {
                    self.currentNetwork = "Wi-Fi"
                    self.is5GSlicing = false
                } else {
                    self.currentNetwork = "Unknown"
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    func check5GStatus() {
       guard let radioTech = telephonyInfo.serviceCurrentRadioAccessTechnology?.values.first else {
           is5GSlicing = false
           return
       }
       
        is5GSlicing = radioTech == CTRadioAccessTechnologyNR || radioTech == CTRadioAccessTechnologyNRNSA
   }
    
    func testSpeed() async -> Double? {
        guard let url = URL(string: "https://speed.cloudflare.com") else {
           return nil
        }
        
        let startTime = Date()
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let elapsedTime = Date().timeIntervalSince(startTime)
            let speedMbps = (Double(data.count) * 8) / (elapsedTime * 1_000_000)
            
            return speedMbps
        } catch {
            
        }
        return nil
    }
}
