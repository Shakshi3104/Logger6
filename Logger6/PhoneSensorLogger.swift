//
//  PhoneSensorLogger.swift
//  Logger6
//
//  Created by MacBook Pro on 2020/08/02.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//


import Foundation
import CoreMotion
import Combine


func getTimestamp() -> String {
    let format = DateFormatter()
    format.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
    return format.string(from: Date())
}

class PhoneSensorManager: NSObject, ObservableObject {
    var motionManager: CMMotionManager?
    var data = SensorData()
    
    // iPhone
    @Published var accX = 0.0
    @Published var accY = 0.0
    @Published var accZ = 0.0
    @Published var gyrX = 0.0
    @Published var gyrY = 0.0
    @Published var gyrZ = 0.0
    @Published var magX = 0.0
    @Published var magY = 0.0
    @Published var magZ = 0.0
    
    var timer = Timer()
    
    override init() {
        super.init()
        self.motionManager = CMMotionManager()
    }
    
    @objc private func startLogSensor() {
        
        if let data = motionManager?.accelerometerData {
            let x = data.acceleration.x
            let y = data.acceleration.y
            let z = data.acceleration.z
            
            self.accX = x
            self.accY = y
            self.accZ = z
        }
        else {
            self.accX = Double.nan
            self.accY = Double.nan
            self.accZ = Double.nan
        }
        
        if let data = motionManager?.gyroData {
            let x = data.rotationRate.x
            let y = data.rotationRate.y
            let z = data.rotationRate.z
            
            self.gyrX = x
            self.gyrY = y
            self.gyrZ = z
        }
        else {
            self.gyrX = Double.nan
            self.gyrY = Double.nan
            self.gyrZ = Double.nan
        }
        
        if let data = motionManager?.magnetometerData {
            let x = data.magneticField.x
            let y = data.magneticField.y
            let z = data.magneticField.z
            
            self.magX = x
            self.magY = y
            self.magZ = z
        }
        else {
            self.magX = Double.nan
            self.magY = Double.nan
            self.magZ = Double.nan
        }
        
        // センサデータを記録する
        let timestamp = getTimestamp()
        
        self.data.append(time: timestamp, x: self.accX, y: self.accY, z: self.accZ, sensorType: .phoneAccelerometer)
        self.data.append(time: timestamp, x: self.gyrX, y: self.gyrY, z: self.gyrZ, sensorType: .phoneGyroscope)
        self.data.append(time: timestamp, x: self.magX, y: self.magY, z: self.magZ, sensorType: .phoneMagnetometer)
    }
    
    func startUpdate(_ freq: Double) {
        if self.motionManager!.isAccelerometerAvailable {
            self.motionManager?.startAccelerometerUpdates()
        }
        
        if self.motionManager!.isGyroAvailable {
            self.motionManager?.startGyroUpdates()
        }
        
        if self.motionManager!.isMagnetometerAvailable {
            self.motionManager?.startMagnetometerUpdates()
        }
    
        // プル型でデータ取得
        self.timer = Timer.scheduledTimer(timeInterval: 1.0 / freq,
                           target: self,
                           selector: #selector(self.startLogSensor),
                           userInfo: nil,
                           repeats: true)
        
    }
    
    func stopUpdate() {
        self.timer.invalidate()
        
        if self.motionManager!.isAccelerometerActive {
            self.motionManager?.stopAccelerometerUpdates()
        }
        
        if self.motionManager!.isGyroActive {
            self.motionManager?.stopGyroUpdates()
        }
        
        if self.motionManager!.isMagnetometerActive {
            self.motionManager?.stopMagnetometerUpdates()
        }
        
    }
    
}
