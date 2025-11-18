//
//  ETXRegistrationManager.swift
//  TRC
//
//  Created by Mike Bush on 2/6/25.
//

import Foundation
import os
import Alamofire
import UIKit
import Combine
import B2VExtrasSwift
import CoreLocation

extension Bundle {
    func requiredString(forInfoKey key: String) -> String {
        guard let value = object(forInfoDictionaryKey: key) as? String else {
            fatalError("Missing or invalid Info.plist value for key: \(key)")
        }
        return value
    }
}

class ETXRegistrationManager: ObservableObject {
    static let shared = ETXRegistrationManager()
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.example.app", category: "ETXRegistrationManager")
    
    // Registration properties…
    let oauth_url = "https://\(Bundle.main.requiredString(forInfoKey: "ETX_REG_OAUTH_URL"))"
    let encodedKeySecret = Bundle.main.requiredString(forInfoKey: "ETX_REG_OAUTH_TOKEN")
    let vendor_id = Bundle.main.requiredString(forInfoKey: "ETX_REG_VENDOR")
    
    let thingspace_url = "https://thingspace.verizon.com/api/m2m/v1/session/login"
    let imp_reg_url = "https://imp.thingspace.verizon.com/api/v2/clients/registration"
    let imp_con_url = "https://imp.thingspace.verizon.com/api/v2/clients/connection"
    
    let certURL = "https://api.driveazapp.com"
    let generateKey = "EVc6cR0Gutor7Ae3BTkYfOnFfedMchK1umHECBrqXtgCpUlXrMbWUPRnRGxVRwQb"
    
    // These values will be persisted
    var deviceId: String = UIDevice.current.identifierForVendor?.uuidString ?? "default-device-id"
    var mqttURL: String = ""  // This will be loaded (and later updated) during registration
    var certificates: [String: String] = [:]
    var filePW = "your_p12_password"
    var clientType = "Vehicle"
    var clientSubType = "PassengerCar"
    
    // For restart logic
    private var initCount = 0
    
    // MARK: - Registration Flow
    
    /// Starts the registration process.
    func startRegistration(completion: @escaping (Bool) -> Void) {
        getAccessToken(completion: completion)
    }
    
    func getTokens(completion: @escaping (Bool) -> Void) {
        getAccessToken(completion: completion)
    }
    
    func getAccessToken(completion: @escaping (Bool) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Basic \(encodedKeySecret)",
            "Content-Type": "application/x-www-form-urlencoded",
        ]
        let params: [String: Any] = [
            "grant_type": "client_credentials",
        ]
        
        self.logger.debug("ETX Requesting access token with params: \(params) and headers: \(headers) at \(self.oauth_url)")
        AF.request(self.oauth_url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseData { (response: AFDataResponse<Data>) in
            switch response.result {
            case .success(let value):
                do {
                    let loginJSON = try JSONSerialization.jsonObject(with: value, options: []) as? [String: Any]
                    self.logger.debug("ETX Access token response: \(String(describing: loginJSON))")  
                    if let accessToken = loginJSON?["access_token"] as? String {
                        self.getSessionToken(completion: completion, accessToken: accessToken)
                    } else {
                        self.logger.error("ETX Access token missing in response")
                        completion(false)
                    }
                } catch {
                    self.logger.error("ETX Error parsing registration response: \(error)")
                    completion(false)
                }
            case .failure(let error):
                self.logger.error("ETX Error: \(error)")
                completion(false)
            }
        }
    }
    
    func getSessionToken(completion: @escaping (Bool) -> Void, accessToken: String) {

        let user = Bundle.main.requiredString(forInfoKey: "ETX_REG_USER")
        let pass = Bundle.main.requiredString(forInfoKey: "ETX_REG_PASS")

        let parameters: [String: Any] = [
            "username": user,
            "password": pass
        ]
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json"
        ]
        
        self.logger.debug("ETX Requesting session token with params: \(parameters) and headers: \(headers) at \(self.thingspace_url)")
        AF.request(self.thingspace_url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseData { (response: AFDataResponse<Data>) in
            switch response.result {
            case .success(let value):
                do {
                    let loginJSON = try JSONSerialization.jsonObject(with: value, options: []) as? [String: Any]
                    self.logger.debug("ETX Session token response: \(String(describing: loginJSON))")
                    if let sessionToken = loginJSON?["sessionToken"] as? String {
                        self.postRegistrationCall(completion: completion, accessToken: accessToken, sessionToken: sessionToken)
                    } else {
                        self.logger.error("ETX Session token missing in response")
                        completion(false)
                    }
                } catch {
                    self.logger.error("ETX Error parsing registration response: \(error)")
                    completion(false)
                }
            case .failure(let error):
                self.logger.error("ETX Error: \(error)")
                completion(false)
            }
        }
    }
    
    func postRegistrationCall(completion: @escaping (Bool) -> Void, accessToken: String, sessionToken: String) {
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": "Bearer \(accessToken)",
            "SessionToken": sessionToken,
            "Content-Type": "application/json",
        ]
        let params: [String: Any] = [
            "ClientType": clientType,
            "ClientSubtype": clientSubType,
            "VendorID": self.vendor_id,
            "DeviceID": deviceId
        ]
        
        self.logger.debug("ETX Registering device with params: \(params) and headers: \(headers) at \(self.imp_reg_url)")
        AF.request(self.imp_reg_url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseData { (response: AFDataResponse<Data>) in
            switch response.result {
            case .success(let value):
                do {
                    let loginJSON = try JSONSerialization.jsonObject(with: value, options: []) as? [String: Any]
                    self.logger.debug("ETX Registration response: \(String(describing: loginJSON))")
                    if let certificateDict = loginJSON?["Certificate"] as? [String: String] {
                        self.certificates = certificateDict
                        self.deviceId = loginJSON?["DeviceID"] as? String ?? self.deviceId
                        self.postConnectionCall(completion: completion, accessToken: accessToken, sessionToken: sessionToken)
                    } else if let errorMessage = loginJSON?["description"] as? String, errorMessage == "device already registered" {
                        self.putRegistrationCall(completion: completion, accessToken: accessToken, sessionToken: sessionToken)
                    } else {
                        self.logger.error("ETX Certificate field missing or unexpected format")
                        self.certificates = [:]
                        completion(false)
                    }
                } catch {
                    self.logger.error("ETX Error parsing registration response: \(error)")
                    completion(false)
                }
            case .failure(let error):
                self.logger.error("ETX Error: \(error)")
                completion(false)
            }
        }
    }
    
    func putRegistrationCall(completion: @escaping (Bool) -> Void, accessToken: String, sessionToken: String) {
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": "Bearer \(accessToken)",
            "SessionToken": sessionToken,
            "Content-Type": "application/json",
            "DeviceID": deviceId,
            "VendorID": self.vendor_id,
        ]
        let params: [String: Any] = [:]
        
        self.logger.debug("ETX Updating registration with params: \(params) and headers: \(headers) at \(self.imp_reg_url)")
        AF.request(self.imp_reg_url, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers).responseData { (response: AFDataResponse<Data>) in
            switch response.result {
            case .success(let value):
                do {
                    let loginJSON = try JSONSerialization.jsonObject(with: value, options: []) as? [String: Any]
                    self.logger.debug("ETX Update registration response: \(String(describing: loginJSON))")
                    if let certificateDict = loginJSON?["Certificate"] as? [String: String] {
                        self.certificates = certificateDict
                        self.postConnectionCall(completion: completion, accessToken: accessToken, sessionToken: sessionToken)
                    } else {
                        self.logger.error("ETX Certificate field missing or unexpected format")
                        self.certificates = [:]
                        completion(false)
                    }
                } catch {
                    self.logger.error("ETX Error parsing registration response: \(error)")
                    completion(false)
                }
            case .failure(let error):
                self.logger.error("ETX Error: \(error)")
                completion(false)
            }
        }
    }
    
    func postConnectionCall(completion: @escaping (Bool) -> Void, accessToken: String, sessionToken: String) {
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": "Bearer \(accessToken)",
            "SessionToken": sessionToken,
            "VendorID": self.vendor_id,
            "Content-Type": "application/json",
        ]
        
        let goodLocations = [
            CLLocationCoordinate2D(latitude: 33.435112498382324, longitude: -112.01077196030407), // PHX
            CLLocationCoordinate2D(latitude: 33.63231474545422, longitude: -84.43477625575007), // ATL
            CLLocationCoordinate2D(latitude: 42.21293528061342, longitude: -83.3520750667301), // DTW
            CLLocationCoordinate2D(latitude: 40.637853178988514, longitude: -73.77776699870391), // NYC
            CLLocationCoordinate2D(latitude: 33.94201468027798, longitude: -118.40374585080627) // LAX
        ]
        
        var closestLocation = goodLocations[0]
        if let curLoc = LocationManager.sharedInstance.lastSeenLocation?.coordinate {
            for testLoc in goodLocations {
                if curLoc.distance(to: testLoc) < curLoc.distance(to: closestLocation) {
                    closestLocation = testLoc
                }
            }
        }
        
        let params: [String: Any] = [
            "DeviceID": deviceId,
            "Geolocation": [
                "Latitude": closestLocation.latitude,
                "Longitude": closestLocation.longitude
            ],
            "NetworkType": "non-VZ"
        ]
        
        
        
        self.logger.debug("ETX Connecting device with params: \(params) and headers: \(headers) at \(self.imp_con_url)")
        AF.request(self.imp_con_url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseData { (response: AFDataResponse<Data>) in
            switch response.result {
            case .success(let value):
                do {
                    let connectionJSON = try JSONSerialization.jsonObject(with: value, options: []) as? [String: Any]
                    self.logger.debug("ETX Connection response: \(String(describing: connectionJSON))")
                    // Save the MQTT URL from the connection response
                    self.mqttURL = connectionJSON?["MqttURL"] as? String ?? self.mqttURL
                    self.logger.debug("ETX MQTT URL: \(self.mqttURL)")
                    completion(true)
                } catch {
                    self.logger.error("ETX Error parsing connection response: \(error)")
                    completion(false)
                }
            case .failure(let error):
                self.logger.error("ETX Error: \(error)")
                completion(false)
            }
        }
    }
    
    // MARK: - Certificate Generation and Utility Functions
    
    func applicationSupportFilePath(fileName: String) -> URL? {
        guard let appSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        let directory = appSupportDirectory.appendingPathComponent(Bundle.main.bundleIdentifier ?? "ETXRegistrationManager", isDirectory: true)
        if !FileManager.default.fileExists(atPath: directory.path) {
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                logger.info("Failed to create Application Support directory: \(error)")
                return nil
            }
        }
        return directory.appendingPathComponent(fileName)
    }
    
    func generateDERCertificate(deviceId: String, certificates: [String: String], completion: @escaping (Bool, URL?) -> Void) {
        let url = "\(certURL)/generate_der"
        let parameters: [String: Any] = [
            "DeviceID": deviceId,
            "Certificate": certificates
        ]
        let headers: HTTPHeaders = [
            "X-Api-Key": generateKey
        ]

        let derRequest = AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        derRequest.responseData(queue: .main) { response in
            guard let data = response.data else {
                self.logger.info("ETX Failed to download DER certificate")
                completion(false, nil)
                return
            }
            // Decode Base64 if needed, even when mislabeled as binary
            var derData = data
            let contentType = (response.response?.allHeaderFields["Content-Type"] as? String) ?? "unknown"
            if contentType.contains("text/plain") || contentType.contains("application/json") {
                if let text = String(data: data, encoding: .utf8), let decoded = Data(base64Encoded: text) {
                    derData = decoded
                    self.logger.debug("ETX Decoded Base64 DER certificate (content-type text)")
                } else {
                    self.logger.warning("ETX Server returned text but couldn't decode DER as Base64")
                }
            } else if let ascii = String(data: data, encoding: .utf8) {
                // Heuristic: Base64 DER often starts with "MII"; try decode regardless of content-type
                let trimmed = ascii.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.hasPrefix("MII"), let decoded = Data(base64Encoded: trimmed) {
                    derData = decoded
                    self.logger.debug("ETX Decoded Base64 DER certificate (heuristic MII)")
                } else {
                    self.logger.debug("ETX Received binary DER certificate")
                }
            } else {
                self.logger.debug("ETX Received binary DER certificate")
            }
            

            guard let fileURL = self.applicationSupportFilePath(fileName: "ca.der") else {
                self.logger.info("ETX Failed to get Application Support file path for DER certificate")
                completion(false, nil)
                return
            }
            do {
                try derData.write(to: fileURL)
                self.logger.info("ETX Successfully saved DER certificate at \(fileURL)")
                completion(true, fileURL)
            } catch {
                self.logger.error("ETX Error saving DER certificate: \(error)")
                completion(false, nil)
            }
        }
    }
    
    func generateP12Certificate(deviceId: String, certificates: [String: String], passkey: String, completion: @escaping (Bool, URL?) -> Void) {
        let url = "\(certURL)/generate_p12"
        let parameters: [String: Any] = [
            "DeviceID": deviceId,
            "Certificate": certificates
        ]
        let headers: HTTPHeaders = [
            "X-Passkey": passkey,
            "X-Api-Key": generateKey,
            "Content-Type": "application/json"
        ]
        let p12Request = AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        p12Request.responseData(queue: .main) { response in
            guard let data = response.data else {
                self.logger.info("ETX Failed to download P12 certificate")
                completion(false, nil)
                return
            }
            
            // Log response details for debugging
            let contentTypeHeader = (response.response?.allHeaderFields["Content-Type"] as? String) ?? "unknown"
            self.logger.debug("ETX P12 response: Content-Type: \(contentTypeHeader), Data size: \(data.count) bytes")
            
            // Log first few bytes to help diagnose data format
            if data.count > 0 {
                let firstBytes: [UInt8] = Array(data.prefix(min(16, data.count)))
                self.logger.debug("ETX P12 first bytes: \(firstBytes.map { String(format: "%02X", $0) }.joined(separator: " "))")
            }
            
            // Decode Base64 if needed, even when mislabeled as binary
            var p12Data = data
            let contentType = (response.response?.allHeaderFields["Content-Type"] as? String) ?? "unknown"
            if contentType.contains("text/plain") || contentType.contains("application/json") {
                if let text = String(data: data, encoding: .utf8), let decoded = Data(base64Encoded: text) {
                    p12Data = decoded
                    self.logger.debug("ETX Decoded Base64 P12 certificate (content-type text)")
                } else {
                    self.logger.warning("ETX Server returned text but couldn't decode P12 as Base64")
                }
            } else if let ascii = String(data: data, encoding: .utf8) {
                // Heuristic: Base64 PKCS#12 often starts with "MII"; try decode regardless of content-type
                let trimmed = ascii.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.hasPrefix("MII"), let decoded = Data(base64Encoded: trimmed) {
                    p12Data = decoded
                    self.logger.debug("ETX Decoded Base64 P12 certificate (heuristic MII)")
                } else {
                    self.logger.debug("ETX Received binary P12 certificate")
                }
            } else {
                self.logger.debug("ETX Received binary P12 certificate")
            }
            
            guard let fileURL = self.applicationSupportFilePath(fileName: "client.p12") else {
                self.logger.info("ETX Failed to get Application Support file path for P12 certificate")
                completion(false, nil)
                return
            }
            do {
                try p12Data.write(to: fileURL)
                self.logger.info("ETX Successfully saved P12 certificate at \(fileURL)")
                completion(true, fileURL)
            } catch {
                self.logger.error("ETX Error saving P12 certificate: \(error)")
                completion(false, nil)
            }
        }
    }
    
    // MARK: - Persistent Data
    
    func savePersistentData(deviceId: String, derFilePath: URL, p12FilePath: URL) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(deviceId, forKey: deviceIdKey)
        userDefaults.set(derFilePath.path, forKey: derFilePathKey)
        userDefaults.set(p12FilePath.path, forKey: p12FilePathKey)
        // Also persist the mqttURL
        userDefaults.set(mqttURL, forKey: mqttURLKey)
    }
    
    func savePersistentEulaData(eulaAgreedTo: Int) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(eulaAgreedTo, forKey: eulaKey)
    }
    
    func loadPersistentData() -> (deviceId: String?, derFilePath: URL?, p12FilePath: URL?, agreedToEula: Int?) {
        let userDefaults = UserDefaults.standard
        let deviceId = userDefaults.string(forKey: deviceIdKey)
        let agreedToEula = userDefaults.integer(forKey: eulaKey)
        // If a saved mqttURL exists, update our property.
        if let savedMqttURL = userDefaults.string(forKey: mqttURLKey) {
            self.mqttURL = savedMqttURL
        }
        let derFilePath = applicationSupportFilePath(fileName: "ca.der")
        let p12FilePath = applicationSupportFilePath(fileName: "client.p12")
        logger.info("Loaded persistent data: Device ID: \(deviceId ?? "nil")")
        logger.debug("DER Path: \(derFilePath?.path ?? "nil")")
        logger.debug("P12 Path: \(p12FilePath?.path ?? "nil")")
        logger.info("MQTT URL: \(self.mqttURL)")
        logger.info("DER Exists: \(derFilePath != nil && FileManager.default.fileExists(atPath: derFilePath!.path))")
        logger.info("P12 Exists: \(p12FilePath != nil && FileManager.default.fileExists(atPath: p12FilePath!.path))")
        return (deviceId, derFilePath, p12FilePath, agreedToEula)
    }
    
    private var deviceIdKey: String { "MQTTManagerDeviceID" }
    private var derFilePathKey: String { "MQTTManagerDERFilePath" }
    private var p12FilePathKey: String { "MQTTManagerP12FilePath" }
    private var mqttURLKey: String { "MQTTManagerMqttURL" }
    private var eulaKey: String { "MQTTManagerEula" }
    
    // MARK: - Restart Logic
    
    func restartInitialization(reason: String) {
        logger.info("Restarting initialization due to: \(reason)")
        var delayTime = initCount * 10
        if delayTime > 300 {
            delayTime = 300
        }
        initCount += 1
        logger.info("Sleeping for \(delayTime) seconds before restarting initialization...")
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(delayTime)) {
            self.startRegistration { _ in }
        }
    }
}
