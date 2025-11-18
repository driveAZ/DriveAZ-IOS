//
//  MQTTManager.swift
//  TRC
//
//  Created by Ben on 9/5/24.
//

import Alamofire
import CocoaLumberjack
import B2VExtras
import B2VExtrasSwift
import CocoaMQTT
import Foundation
import SwiftProtobuf
import os
import CoreLocation

/// This class handles MQTT operations (connecting, publishing/subscribing, etc.)
class MQTTManager: CocoaMQTTDelegate, ObservableObject, LocationManagerDelegate {
    static let sharedInstance = MQTTManager()
    
    let vendor_id = Bundle.main.requiredString(forInfoKey: "ETX_REG_VENDOR")
    let vendor_channel = Bundle.main.requiredString(forInfoKey: "ETX_ACTIVE_VENDOR_CHANNEL")

    var vruMode = false
    var sendWhileNotMoving = false
    
    // MQTTManager now owns its own published GRM dictionary.
    @Published var lastSeenGRMs: [String: GRMAnnotationItem] = [:]
    @Published var alertArray: [GRMAnnotationItem] = []
    @Published var mapUpdates = 0.0
    private var mapTimer: Timer?
    
    @Published var numberOfSentMessages = 0
    @Published var numberOfRecievedMessages = 0
    @Published var devPoints: [MyAnnotationItem] = []
    
    let typesWeCareAbout = ["PSM", "TIM"]
    var vendorTopics: [String]
    var publicTopics: [String]
    
    var timDecodeFailures = 0
    var psmDecodeFailures = 0
    
    var sendingOnPublic = true
    var sendingOnVendor = false
    var listeningOnPublic = true
    var listeningOnVendor = true
    
    var isConnected = false
    private var messageTimer: Timer?
    var sendWhileNotMovingTimer: Timer?
    var reconnectTimer: Timer?
    
    // MQTT connection properties
    var mqtt: CocoaMQTT?
    var mqttURL = ""
    var mqttHost = ""
    var mqttPort = 8883
    var privateSessionToken: String? = nil
    let geohashPercission = 6
    var lastSeenGeohash = "none"
    var updatesSinceLastNewGeohash = 0
    var lastLocationUpdateTime = 0.0
    var startedRegistration = false
    
    let maxSecondsToKeepOntoGRM:Double = 10 
    let maxDistanceToKeepOntoGRM:Double = (AlertManager.sharedInstance.total_stopping_distances.last ?? 1000) * 2
    
    // MARK: - Initialization
    /// The initializer checks for previously saved certificate data (via ETXRegistrationManager).
    /// If available, it immediately sets up the MQTT connection.
    /// Otherwise, it starts the registration process.
    private init() {
        print("mqtt init")
            publicTopics = typesWeCareAbout.map { s in "vzimp/1/GeoRelevance/+/+/Public/j2735_gr/\(s)/+"} + typesWeCareAbout.map { s in "vzimp/1/GeoRelevance/+/+/Public/j2735/\(s)/+"}
            vendorTopics = ["vzimp/1/GeoRelevance/+/+/\(self.vendor_id)/j2735_gr/PSM/+", "vzimp/1/GeoRelevance/+/+/\(self.vendor_id)/j2735_gr/TIM/+",
                            "vzimp/1/GeoRelevance/+/+/\(self.vendor_id)/j2735/PSM/+", "vzimp/1/GeoRelevance/+/+/\(self.vendor_id)/j2735/TIM/+"]
        LocationManager.sharedInstance.delegate = self // will be taken over by MapView eventually
        if LocationManager.sharedInstance.lastSeenLocation != nil && !startedRegistration {
            start()
        }
    }
    
    /// Helper to extract the host from a URL string.
    private func extractHost(from urlString: String) -> String {
        if let url = URL(string: urlString) {
            return url.host ?? mqttHost
        }
        return mqttHost
    }
    
    /// Called externally if needed.
    func start() {
        startedRegistration = true
        print("mike \(publicTopics)")
        // Ask ETXRegistrationManager for any persistent data
        let persistentData = ETXRegistrationManager.shared.loadPersistentData()
        if let deviceId = persistentData.deviceId,
           let derFileURL = persistentData.derFilePath,
           let p12FileURL = persistentData.p12FilePath,
           FileManager.default.fileExists(atPath: derFileURL.path),
           FileManager.default.fileExists(atPath: p12FileURL.path)
        {
            
            // Use the saved device ID (ETXRegistrationManager still handles registration)
            ETXRegistrationManager.shared.deviceId = deviceId
            print("Successfully loaded certs from storage.")
            
            // Derive the host from the MQTT URL.
            self.mqttHost = extractHost(from: ETXRegistrationManager.shared.mqttURL)
            
            // Use the persistent certificates to set up MQTT immediately.
            makeMQTT(withDERPath: derFileURL, p12Path: p12FileURL)
        } else {
            print("Persistent data not found or invalid. Starting registration.")
            ETXRegistrationManager.shared.startRegistration { success in
                if success {
                    self.mqttURL = ETXRegistrationManager.shared.mqttURL
                    // Explicit self. is used inside the closure.
                    self.mqttHost = self.extractHost(from: self.mqttURL)
                    // Generate the certificates (and then the connection) if needed.
                    self.makeMQTT()
                } else {
                    print("Failed to complete registration. MQTT will not start.")
                    
                    AlertManager.sharedInstance.errorAlertTitle = "Error"
                    AlertManager.sharedInstance.errorAlertText = "Failed to complete registration. MQTT will not start."
                    AlertManager.sharedInstance.errorAlertNumber = 2
                    AlertManager.sharedInstance.shouldShowErrorAlert = true
                }
            }
        }
        
        // Get the private session token and refresh it every 30 seconds.
        getPrivateSessionToken()
        Timer.scheduledTimer(
            withTimeInterval: 30, repeats: true,
            block: { _ in
                self.getPrivateSessionToken()
            })
        
    }
    
    // MARK: - MQTT Setup and Publishing
    /// Sets up the CocoaMQTT instance using provided certificate file paths.
    private func setupMQTT(derPath: URL, p12Path: URL) {
        let clientID = ETXRegistrationManager.shared.deviceId
        self.mqtt = CocoaMQTT(clientID: clientID, host: self.mqttHost, port: UInt16(self.mqttPort))
        print(
            "Connecting MQTT at \(self.mqttHost):\(self.mqttPort) with client ID \(clientID)")
        guard let mqtt = self.mqtt else { return }
        mqtt.delegate = self
        mqtt.enableSSL = true
        
        // Load the identity from the P12 file.
        if let clientCertArray = getClientCertFromP12File(
            certPath: p12Path.path, certPassword: ETXRegistrationManager.shared.filePW)
        {
            var sslSettings: [String: NSObject] = [:]
            sslSettings[kCFStreamSSLCertificates as String] = clientCertArray
            sslSettings[kCFStreamSSLPeerName as String] = mqttHost as NSString
            mqtt.sslSettings = sslSettings
        } else {
            print("Failed to configure SSL settings.")
            return
        }
        
        mqtt.didConnectAck = self.didConnect
        
        _ = mqtt.connect()
    }
    
    /// Either uses pre‐generated certificate paths or triggers certificate generation.
    func makeMQTT(withDERPath derPath: URL? = nil, p12Path: URL? = nil) {
        if let derPath = derPath, let p12Path = p12Path {
            print("Using existing DER and P12 paths.")
            setupMQTT(derPath: derPath, p12Path: p12Path)
            return
        }
        
        print("No persistent certificates found, generating new certificates.")
        guard !ETXRegistrationManager.shared.deviceId.isEmpty,
              !mqttURL.isEmpty,
              !ETXRegistrationManager.shared.certificates.isEmpty
        else {
            print("Device ID, MQTT URL, or certificates not set. Cannot proceed.")
            return
        }
        
        ETXRegistrationManager.shared.generateDERCertificate(
            deviceId: ETXRegistrationManager.shared.deviceId,
            certificates: ETXRegistrationManager.shared.certificates
        ) { derSuccess, derFileURL in
            guard derSuccess, let derFileURL = derFileURL else {
                print("Failed to fetch DER certificate. Cannot proceed.")
                return
            }
            
            ETXRegistrationManager.shared.generateP12Certificate(
                deviceId: ETXRegistrationManager.shared.deviceId,
                certificates: ETXRegistrationManager.shared.certificates,
                passkey: ETXRegistrationManager.shared.filePW
            ) { p12Success, p12FileURL in
                guard p12Success, let p12FileURL = p12FileURL else {
                    print("Failed to fetch P12 certificate. Cannot proceed.")
                    return
                }
                
                print("Successfully generated new certificates.")
                ETXRegistrationManager.shared.savePersistentData(
                    deviceId: ETXRegistrationManager.shared.deviceId, derFilePath: derFileURL,
                    p12FilePath: p12FileURL)
                self.setupMQTT(derPath: derFileURL, p12Path: p12FileURL)
            }
        }
    }
    
    /// Example function to send a message via MQTT.
    func sendMessage() {
        print("sendMessage")
        guard let location = LocationManager.sharedInstance.lastSeenLocation else {
            print("Failed to send message: no location data")
            return
        }
        
        var data = Georoutedmsg_GeoRoutedMsg()
        data.time = SwiftProtobuf.Google_Protobuf_Timestamp(date: Date())
        data.position = Georoutedmsg_Position()
        // (Assuming that latitudeRangeMap and longitudeRangeMap are defined elsewhere.)
        data.position.latitude = latitudeRangeMap.mapReverse(
            SafetyMessageManager.sharedInstance.psm.position.lat)!
        data.position.longitude = longitudeRangeMap.mapReverse(
            SafetyMessageManager.sharedInstance.psm.position.Long)!
        do {
            var mtype = "BSM"
            data.msgBytes = Data(SafetyMessageManager.sharedInstance.latestBSMBytes)
            if self.vruMode {
                mtype = "PSM"
                data.msgBytes = Data(SafetyMessageManager.sharedInstance.latestPSMBytes)
            }
            let bytes: [UInt8] = try Array(data.serializedData())
            let publicTopic =
            "vzimp/1/GeoRelevance/\(ETXRegistrationManager.shared.clientType)/\(ETXRegistrationManager.shared.clientSubType)/Public/j2735_gr/\(mtype)"
            let vendorTopic =
            "vzimp/1/GeoRelevance/\(ETXRegistrationManager.shared.clientType)/\(ETXRegistrationManager.shared.clientSubType)/\(self.vendor_channel)/j2735_gr/\(mtype)"
            if sendingOnPublic {
                mqtt?.publish(CocoaMQTTMessage(topic: publicTopic, payload: bytes, qos: .qos0))
            }
            if sendingOnVendor {
                mqtt?.publish(CocoaMQTTMessage(topic: vendorTopic, payload: bytes, qos: .qos0))
            }
            numberOfSentMessages = numberOfSentMessages + 1
        } catch {
            print("Error: unable to serialize data to bytes")
        }
    }
    
    // MARK: - CocoaMQTTDelegate Methods
    func didConnect(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        switch ack {
        case .accept:
            print("MQTT/EXT Connection Accepted")
        case .badUsernameOrPassword:
            print("MQTT/EXT badUsernameOrPassword")
        case .notAuthorized:
            print("MQTT/EXT notAuthorized")
        default:
            print("MQTT/EXT default")
        }
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("MQTT mqttDidPing")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("MQTT mqttDidReceivePong")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: (any Error)?) {
        print("MQTT/EXT mqttDidDisconnect")
        startReconnectTimer()
        isConnected = false
        if let err = err as NSError? {
            print("Error Domain: \(err.domain), Code: \(err.code)")
            if err.domain == "kCFStreamErrorDomainSSL" {
                print("Detected SSL error in MQTT disconnection.")
                // Optionally, restart initialization if needed.
                return
            }
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        print("MQTT didUnsubscribeTopics")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        for (topic, _) in success {
            if let topicStr = topic as? String {
                print("Subscribed to: \(topicStr)")
            }
        }
        if !failed.isEmpty {
            print("Failed to subscribe to topics: \(failed)")
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {

        var topics = publicTopics + vendorTopics

        print("MQTT/EXT didConnectAck \(ETXRegistrationManager.shared.deviceId)")
        isConnected = (ack == .accept)
        if isConnected {
            locationIsUpdated()
            for topic in topics {
                mqtt.subscribe(topic, qos: .qos0)
            }
            stopReconnectTimer()
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("MQTT didPublishAck")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        print("MQTT didReceiveMessage from topic: \(message.topic)")
        numberOfRecievedMessages = numberOfRecievedMessages + 1
        let topicSegments = message.topic.split(separator: "/")
        if topicSegments.contains("j2735_gr") {
            if let messageTypeIndex = topicSegments.firstIndex(of: "j2735_gr"),
               messageTypeIndex + 1 < topicSegments.count
            {
                print("topicSegments", topicSegments)
                let messageType = topicSegments[messageTypeIndex + 1]
                let idString = String(topicSegments.last ?? "")
                processPossibleGrMessage(message, messageType: String(messageType), id: idString, isGR: true)
                startMapTimer()
            }
        } else if topicSegments.contains("j2735") {
            if let messageTypeIndex = topicSegments.firstIndex(of: "j2735"),
               messageTypeIndex + 1 < topicSegments.count
            {
                print("topicSegments", topicSegments)
                let messageType = topicSegments[messageTypeIndex + 1]
                let idString = String(topicSegments.last ?? "")
                print(idString)
                print(String(messageType))
                print(message)
                processPossibleGrMessage(message, messageType: String(messageType), id: idString, isGR: false)
                startMapTimer()
            }
        } else {
            print("Ignoring message from unrelated topic: \(message.topic)")
        }
    }
    
    /// Processes a “GeoRouted” message.
    func processPossibleGrMessage(_ message: CocoaMQTTMessage, messageType: String, id: String, isGR: Bool) {
        print("processGrMessage Processing \(messageType) message")
        print("processGrMessage Processing \(id) id")
        
        do {
            var geoRoutedMsg = Georoutedmsg_GeoRoutedMsg()
            if isGR {
                geoRoutedMsg = try Georoutedmsg_GeoRoutedMsg(serializedBytes: Data(message.payload))
            }
            print("Decoded GeoRoutedMsg: \(String(describing: geoRoutedMsg))")
            if geoRoutedMsg.hasPosition {
                print("Latitude: \(geoRoutedMsg.position.latitude)")
                print("Longitude: \(geoRoutedMsg.position.longitude)")
            }
            var messageFrame = decodeMessage(messageType: messageType, j2735_en: isGR ? geoRoutedMsg.msgBytes : Data(message.payload))
            var grmAnnotationItem = GRMAnnotationItem(
                grm: geoRoutedMsg,
                messageFrame: messageFrame,
                messageType: messageType,
                id: id,
                showAlert: self.lastSeenGRMs[id]?.showAlert ?? false,
                lastAlertTimeStamp: self.lastSeenGRMs[id]?.lastAlertTimeStamp ?? nil,
                lastMessageTimeStamp: NSDate().timeIntervalSince1970
            )
            
            grmAnnotationItem.specificMessageType = grmAnnotationItem.messageType
            if messageType == "TIM" {
                grmAnnotationItem.specificMessageType = grmAnnotationItem.specificMessageType ?? "TIM" + msgToTIMString(grmAnnotationItem)
                var jsonBytes: [UInt8] = [UInt8](repeating: 0xFF, count: 22800)
                let json = asn_encode_to_buffer(nil, ATS_JER, &asn_DEF_MessageFrame, &messageFrame, &jsonBytes, 22800)
                let jsonData = Data(bytes: jsonBytes, count: json.encoded)
                grmAnnotationItem.timObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                guard
                    let (lat, long) = getTIMLLatLng(grmAnnotationItem)
                else {
                    print("unable to find TIM location")
                    timDecodeFailures = timDecodeFailures + 1
                    return
                }
                guard
                    let timContent = getTIMContenArray(grmAnnotationItem)
                else {
                    print("unable to find TIM type")
                    timDecodeFailures = timDecodeFailures + 1
                    return
                }
                if !isGR {
                    grmAnnotationItem.grm.position = Georoutedmsg_Position()
                    grmAnnotationItem.grm.position.latitude = Double(lat)/1e7
                    grmAnnotationItem.grm.position.longitude = Double(long)/1e7
                    grmAnnotationItem.grm.time = SwiftProtobuf.Google_Protobuf_Timestamp(date: Date())
                }
            }
            
            print("****************")
            print("****************")
            print("Alert check for \(id)")
            if AlertManager.sharedInstance.shouldShowAlert(grm: grmAnnotationItem) {
                print("processGrMessage: Should show alert")
                // If no previous GRM exists for this id, schedule hiding its alert.
                if
                    self.lastSeenGRMs[id] == nil
                        || self.lastSeenGRMs[id]?.lastAlertTimeStamp == nil
                        || NSDate().timeIntervalSince1970 - (self.lastSeenGRMs[id]?.lastAlertTimeStamp ?? NSDate().timeIntervalSince1970) >= AlertManager.sharedInstance.timeBetweenSameAlerts
                {
                    
                    print("processGrMessage: alert setting timer")
                    Timer.scheduledTimer(withTimeInterval: AlertManager.sharedInstance.timeToShowAlert, repeats: false) { _ in
                        print("processGrMessage: stop showing alert")
                        self.lastSeenGRMs[id]?.showAlert = false
                    }
                    
                    grmAnnotationItem.lastAlertTimeStamp = NSDate().timeIntervalSince1970 + AlertManager.sharedInstance.timeToShowAlert
                    
                    grmAnnotationItem.showAlert = true
                }
                
            }
            
            self.lastSeenGRMs[id] = grmAnnotationItem
            print("****************")
            print("****************")
            print("****************")
            
        } catch {
            print("Failed to decode GeoRoutedMsg: \(error)")
            if messageType == "TIM" {
                timDecodeFailures = timDecodeFailures + 1
            } else if messageType == "PSM" {
                psmDecodeFailures = psmDecodeFailures + 1
            }
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("MQTT didPublishMessage to topic \(message.topic)")
    }
    
    // MARK: - Timer Methods
    func startMessageTimer() {
        stopMessageTimer()  // Avoid duplicate timers.
        messageTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.sendMessage()
        }
        print("Message timer started, sending messages every second.")
    }
    
    func stopMessageTimer() {
        messageTimer?.invalidate()
        messageTimer = nil
        print("Message timer stopped.")
    }
    
    func startMapTimer() {
        stopMapTimer()  // Avoid duplicate timers.
        mapTimer = Timer.scheduledTimer(withTimeInterval: AlertManager.sharedInstance.timeToShowOnMapAfterLastMessage, repeats: false) { [weak self] _ in
            print("map should update")
            self?.mapUpdates = NSDate().timeIntervalSince1970
        }
    }
    
    func stopMapTimer() {
        mapTimer?.invalidate()
        mapTimer = nil
    }
    
    func startReconnectTimer() {
        stopReconnectTimer()  // Avoid duplicate timers.
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            print("MQTT trying to reconnect")
            _ = self?.mqtt?.connect()
        }
        print("MQTT reconnectTimer started, trying to reconnect every 5 second.")
    }
    
    func stopReconnectTimer() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
        print("MQTT reconnectTimer stopped.")
    }
    
    
    
    // MARK: - Certificate Helper
    /// Reads the client identity from a P12 file.
    func getClientCertFromP12File(certPath: String, certPassword: String) -> CFArray? {
        guard let p12Data = NSData(contentsOfFile: certPath) else {
            print("Failed to open the certificate file at \(certPath)")
            return nil
        }
        // Try import as-is first
        let options: NSDictionary = [kSecImportExportPassphrase as String: certPassword]
        var items: CFArray?
        var securityError = SecPKCS12Import(p12Data, options, &items)
        if securityError != errSecSuccess {
            // If import fails, attempt Base64 decode fallback
            if let ascii = String(data: p12Data as Data, encoding: .utf8) {
                let trimmed = ascii.trimmingCharacters(in: .whitespacesAndNewlines)
                if let decoded = Data(base64Encoded: trimmed) as NSData? {
                    items = nil
                    securityError = SecPKCS12Import(decoded, options, &items)
                }
            }
        }
        guard securityError == errSecSuccess else {
            print("Error importing P12 file: \(securityError)")
            return nil
        }
        guard let theArray = items, CFArrayGetCount(theArray) > 0 else {
            print("No items found in P12 file")
            return nil
        }
        let dictionary = (theArray as NSArray).object(at: 0)
        guard
            let identity = (dictionary as AnyObject).value(forKey: kSecImportItemIdentity as String)
        else {
            print("Failed to extract identity from P12 file")
            return nil
        }
        return [identity] as CFArray
    }
    
    // MARK: - Message Decoding Helpers
    
    func decodeMessage(messageType: String, j2735_en: Data) -> MessageFrame {
        let array = [UInt8](j2735_en)
        print("Array contents: \(array.map { String($0) }.joined(separator: ", "))")
        var message = MessageFrame()
        let results = libsm_decode_messageframe(array, array.count, &message)
        print("Decode results: \(String(describing: results))")
//        let stringId = getStringId(message)
//        print("String ID: \(String(describing: stringId))")
        
        if messageType == "BSM" {
            let bsm = message.value.choice.BasicSafetyMessage
            print("BSM: \(String(describing: bsm))")
        } else if (messageType == "PSM") {
            let psm = message.value.choice.PersonalSafetyMessage
            print("PSM: \(String(describing: psm))")
        } else {
            let tim = message.value.choice.TravelerInformation
            print("TIM: \(String(describing: tim))")
        }
        return message
    }
    
    // commented out because it was giving us crashes and it is just used for logs
    // handleBuffer should be fixed and safe now if we need it in the future
//    func getStringId(_ message: MessageFrame) -> String? {
//        print("getStringId")
//        let id = message.value.choice.PersonalSafetyMessage.id
//        print("Temporary ID: \(String(describing: id))")
//        let id2 = message.value.choice.BasicSafetyMessage.coreData.id
//        print("Core Data ID: \(String(describing: id2))")
//        let id3 = message.value.choice.TravelerInformation.packetID
//        print("TIM ID: \(String(describing: id3))")
//        return handleBuffer(id)
//    }
//
//    func handleBuffer(_ id: OCTET_STRING) -> String? {
//        guard let buf = id.buf else {
//            print("No buffer in id")
//            return nil
//        }
//        
//        // Validate size is reasonable
//        guard id.size > 0 && id.size <= 1024 else { // Arbitrary max size for safety
//            print("Invalid buffer size: \(id.size)")
//            return nil
//        }
//        
//        var stringId = ""
//        
//        // Use withUnsafeBytes for safe memory access
//        let buffer = UnsafeBufferPointer(start: buf, count: id.size)
//        for byte in buffer {
//            stringId += "\(byte)"
//        }
//        
//        return stringId
//    }
    
    func getPrivateSessionToken() {
        struct ResponseData: Decodable {
            let session_id: String
            let PK: String
            let timeSet: String
        }
        
        AF.request(
            "https://api.driveazapp.com/session_id", method: .get, encoding: JSONEncoding.default
        ).responseDecodable(of: ResponseData.self) { response in
            print("getPrivateSessionToken")
            switch response.result {
            case .success(let data):
                // Successfully decoded the response
                print("Session ID: \(data.session_id)")
                self.privateSessionToken = data.session_id
            case .failure(let error):
                // Handle the error
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func locationIsUpdated() {
        print("MQTT locationIsUpdated")
        print("MQTT timeSinceLastUpdate: \(NSDate().timeIntervalSince1970-lastLocationUpdateTime)")
        if lastLocationUpdateTime == 0.0 && !startedRegistration {
            start()
        }
        lastLocationUpdateTime = NSDate().timeIntervalSince1970
        let thingsToLog = [
            "lastSeenCourse \(LocationManager.sharedInstance.lastSeenCourse)",
            "lastSeenLocation.course \(LocationManager.sharedInstance.lastSeenLocation?.course)",
            "lastSeenLocation.speed \(LocationManager.sharedInstance.lastSeenLocation?.speed)",
            "lastSeenHeading \(LocationManager.sharedInstance.lastSeenHeading)",
            "lastSeenTrueHeading \(LocationManager.sharedInstance.lastSeenTrueHeading)",
        ]
        print(thingsToLog.reduce("", {res,el in
            return "\(res), \(el)"
        }))
        checkAllAlerts()
        if !isConnected {
            return
        }
        
        sendMessage()
        
        guard let mqttSessionToken = privateSessionToken else {
            return
        }
        
        if
            let lastLocation = LocationManager.sharedInstance.lastSeenLocation,
            lastLocation.coordinate.geohash(length: geohashPercission) != lastSeenGeohash
        {
            lastSeenGeohash = lastLocation.coordinate.geohash(length: geohashPercission)
            updatesSinceLastNewGeohash = 0
            
            sendPrivateMessage(mqttSessionToken)
        } else {
            updatesSinceLastNewGeohash += 1
            if updatesSinceLastNewGeohash >= 30 {
                updatesSinceLastNewGeohash = 0
                sendPrivateMessage(mqttSessionToken)
            }
        }
        
    }
    
    func sendPrivateMessage(_ mqttSessionToken: String) {
        var data = Georoutedmsg_GeoRoutedMsg()
        data.time = SwiftProtobuf.Google_Protobuf_Timestamp(date: Date())
        data.position = Georoutedmsg_Position()
        data.position.latitude = latitudeRangeMap.mapReverse(
            SafetyMessageManager.sharedInstance.psm.position.lat)!
        data.position.longitude = longitudeRangeMap.mapReverse(
            SafetyMessageManager.sharedInstance.psm.position.Long)!
        do {
            var mtype = "BSM"
            data.msgBytes = Data(SafetyMessageManager.sharedInstance.latestBSMBytes)
            if vruMode {
                mtype = "PSM"
                data.msgBytes = Data(SafetyMessageManager.sharedInstance.latestPSMBytes)
            }
            let bytes = try [UInt8](data.serializedData())
            mqtt?.publish(
                CocoaMQTTMessage(
                    topic:
                        "vzimp/1/Private/\(mqttSessionToken)/Vehicle/PassengerCar/\(self.vendor_id)/j2735_gr/\(mtype)",
                    payload: bytes, qos: .qos0))
        } catch {
            print("Error: unable to serialize data to bytes")
        }
    }
    
    func checkAllAlerts() {
        let newAlert = Array(lastSeenGRMs.values).filter({ NSDate().timeIntervalSince1970 - $0.lastMessageTimeStamp < 30 })
//        print("alertArray", newAlert.map({m in m.id}))
//        print("alertArray", alertArray.map({m in m.id}))
        if !(newAlert.count == alertArray.count && newAlert.sorted() == alertArray.sorted()) {
            print("alertArray updated")
            alertArray = newAlert
        }
//        print("checkAllAlerts")
//        print("checkAllAlerts #: \(lastSeenGRMs.keys.count)")
//        print("checkAllAlerts : \(lastSeenGRMs.keys)")
//        print("-------")
        for id in lastSeenGRMs.keys {
            var grm = lastSeenGRMs[id]!
            if NSDate().timeIntervalSince1970 - grm.lastMessageTimeStamp > maxSecondsToKeepOntoGRM {
                lastSeenGRMs[id] = nil
                continue
            }
            if
                let curLoc = LocationManager.sharedInstance.lastSeenLocation,
                curLoc.distance(from: CLLocation(latitude: grm.grm.position.latitude, longitude: grm.grm.position.longitude)) > maxDistanceToKeepOntoGRM
            {
                    lastSeenGRMs[id] = nil
                    continue
            }
            print("------- #: \(lastSeenGRMs.keys.count)")
            print("------- 2")
            print("check alert for \(id)")
            if AlertManager.sharedInstance.shouldShowAlert(grm: grm) {
                print("checkAllAlerts: Should show alert")
                // If no previous GRM exists for this id, schedule hiding its alert.
                if
                    self.lastSeenGRMs[id] == nil
                        || self.lastSeenGRMs[id]?.lastAlertTimeStamp == nil
                        || NSDate().timeIntervalSince1970 - (self.lastSeenGRMs[id]?.lastAlertTimeStamp ?? NSDate().timeIntervalSince1970) >= AlertManager.sharedInstance.timeBetweenSameAlerts
                {
                    
                    print("checkAllAlerts: alert setting timer")
                    Timer.scheduledTimer(withTimeInterval: AlertManager.sharedInstance.timeToShowAlert, repeats: false) { _ in
                        print("checkAllAlerts: stop showing alert")
                        self.lastSeenGRMs[id]?.showAlert = false
                    }
                    
                    grm.lastAlertTimeStamp = NSDate().timeIntervalSince1970 + AlertManager.sharedInstance.timeToShowAlert
                    
                    grm.showAlert = true
                    
                    
                }
                
            }
            print("------- 3")
            print("------- 4")
        }
        
    }

    func updateSendingOnPublicChannel(_ newValue: Bool) {
        sendingOnPublic = newValue
    }
    
    func updateSendingOnVendorChannel(_ newValue: Bool) {
        sendingOnVendor = newValue
    }
    
    func updateListeningOnPublicChannel(_ newValue: Bool) {
        listeningOnPublic = newValue
        if listeningOnPublic {
            publicTopics.forEach {publicTopic in
                mqtt?.subscribe(publicTopic, qos: .qos0)
            }
        } else {
            publicTopics.forEach {publicTopic in
                mqtt?.unsubscribe(publicTopic)
            }
        }
    }
    
    func updateListeningOnVendorChannel(_ newValue: Bool) {
        listeningOnVendor = newValue
        if listeningOnVendor {
            vendorTopics.forEach {vendorTopic in
                mqtt?.subscribe(vendorTopic, qos: .qos0)
            }
        } else {
            vendorTopics.forEach {vendorTopic in
                mqtt?.unsubscribe(vendorTopic)
            }
        }
    }
            
    func updateSendWhileNotMoving(_ newValue: Bool) {
        print("updateSendWhileNotMoving", newValue)
        sendWhileNotMoving = newValue
        if sendWhileNotMoving {
            startMessageTimer()
        } else {
            stopMessageTimer()
        }
    }
    
    func getTIMLLatLng(_ grm: GRMAnnotationItem) -> (Int, Int)? {
        if
            let timObject = grm.timObject,
            let v = timObject["value"] as? [String:Any],
            let t = v["TravelerInformation"] as? [String:Any],
            let d = t["dataFrames"] as? [[String:Any]],
            let d1 = d.first,
            let r = d1["regions"] as? [[String:Any]],
            let r1 = r.first,
            let a = r1["anchor"] as? [String:Any],
            let lat = a["lat"] as? Int,
            let long = a["long"] as? Int
        {
            return (lat, long)
        }
        return nil
    }
    
    func getTIMContenArray(_ grm: GRMAnnotationItem) -> [String:Any]? {
    
        if
            let timObject = grm.timObject,
            let v = timObject["value"] as? [String:Any],
            let t = v["TravelerInformation"] as? [String:Any],
            let d = t["dataFrames"] as? [[String:Any]],
            let d1 = d.first,
            let c = d1["content"] as? [String:Any]
        {
            return c
        }
        return nil
    }
    
    func msgToTIMString(_ grmAnnotation: GRMAnnotationItem) -> String {
        guard
            let c = MQTTManager.sharedInstance.getTIMContenArray(grmAnnotation)
        else {
            return "unknown"
        }
        
        let a = c["advisory"] as? [[String:Any]] ?? []
        let w = c["workZone"] as? [[String:Any]] ?? []
        
        var returnValue = "unknown"
        for obj in a {
            if let i = obj["item"] as? [String:Any] {
                if i["itis"] as? Int == 1025 || i["itis"] as? String == "1025" {
                    returnValue = "workzone"
                    break
                } else if i["itis"] as? Int == 257 || i["itis"] as? String == "257" {
                    returnValue = "boq"
                    break
                }
            }
        }
        for obj in w {
            if let i = obj["item"] as? [String:Any] {
                if i["itis"] as? Int == 1025 || i["itis"] as? String == "1025" {
                    returnValue = "workzone"
                    break
                } else if i["itis"] as? Int == 257 || i["itis"] as? String == "257" {
                    returnValue = "boq"
                    break
                }
            }
        }
        return returnValue
        
    }
}
