//
//  WatchConnector.swift
//  Logger6
//
//  Created by MacBook Pro on 2020/08/02.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

import Foundation
import UIKit
import WatchConnectivity

class WatchConnector: NSObject, ObservableObject, WCSessionDelegate {
    
    let saver = WatchSensorData()
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith state = \(activationState.rawValue)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Phone: didReceive: \(message)")
        
        DispatchQueue.main.async {
            if let accData = message["ACC_DATA"] as? String {
                self.saver.logAccelerometerData(line: accData)
            }
            
            if let gyrData = message["GYR_DATA"] as? String {
                self.saver.logGyroscopeData(line: gyrData)
            }
        }
    }
    
    
}

class WatchSensorData {
    var accelerometerData: String
    var gyroscopeData: String
    
    public init() {
        let column = "time,x,y,z\n"
        self.accelerometerData = column
        self.gyroscopeData = column
    }
    
    func logAccelerometerData(line: String) {
        self.accelerometerData.append(contentsOf: line)
    }
    
    func logGyroscopeData(line: String) {
        self.gyroscopeData.append(contentsOf: line)
    }
    
    // 保存したファイルパスを取得する
    func getDataURLs(label: String, subject: String) -> [URL] {
        let format = DateFormatter()
        format.dateFormat = "yyyyMMddHHmmss"
        let time = format.string(from: Date())
        
        /* 一時ファイルを保存する場所 */
        let tmppath = NSHomeDirectory() + "/tmp"
        
        let apd = "\(time)_\(label)_\(subject)" // 付加する文字列(時間+ラベル+ユーザ名)
        // ファイル名を生成
        let accelerometerFilepath = tmppath + "/watch_accelermeter_\(apd).csv"
        let gyroFilepath = tmppath + "/watch_gyroscope_\(apd).csv"
        
        // ファイルを書き出す
        do {
            try self.accelerometerData.write(toFile: accelerometerFilepath, atomically: true, encoding: String.Encoding.utf8)
            try self.gyroscopeData.write(toFile: gyroFilepath, atomically: true, encoding: String.Encoding.utf8)
            
        }
        catch let error as NSError{
            print("Failure to Write File\n\(error)")
        }
        
        /* 書き出したcsvファイルの場所を取得 */
        var urls = [URL]()
        urls.append(URL(fileURLWithPath: accelerometerFilepath))
        urls.append(URL(fileURLWithPath: gyroFilepath))

        // データをリセットする
        self.resetData()
        
        return urls
    }
    
    // データをリセットする
    func resetData() {
        let column = "time,x,y,z\n"
        self.accelerometerData = column
        self.gyroscopeData = column
    }
}