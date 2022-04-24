//
//  ScannerViewController.swift
//  QR AJ
//
//  Created by Ariana Esquivel on 21/04/22.
//

import AVFoundation
import Starscream
import UIKit

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, WebSocketDelegate {
    
    var captureSession:AVCaptureSession!
    var previewLayer:AVCaptureVideoPreviewLayer!
    var socket: WebSocket!
    var isConnected = false
    let server = WebSocketServer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var request = URLRequest(url: URL(string: "ws://192.168.100.9:3333/adonis-ws")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if captureSession.canAddInput(videoInput){
                captureSession.addInput(videoInput)
            }else{
                failed()
                
            }
        }catch {
            print("Error \(error)")
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)){
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
//        captureSession.startRunning()
        
        // Do any additional setup after loading the view.
    }
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (captureSession.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (captureSession.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readbleObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readbleObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            foundText(stringValue)
        }
//        dismiss(animated: true)
    }
    
    func foundText (_ textFromQR:String){
        print(textFromQR)
        guard let data = textFromQR.data(using: .utf8) else { return }
        let decoder = JSONDecoder()
        guard let dataQR = try? decoder.decode(DataQR.self, from: data) else { return }
        print(dataQR.email)
        let ac = UIAlertController(title: "Código correcto", message: "\(dataQR.email)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true) {
                self.captureSession = nil
                let intento = [
                    "t": 2,
                    "d": [
                        "topic": "chat",
                        "event": "message",
                        "data": [
                          "message": "Chi 🥺",
                          "email": dataQR.email
                        ]
                    ]
                ] as [String : Any]
                self.send(intento) {
                   print("listo")
//                  self.dismiss(animated: true)
                }
                
            }
//            let intento = [
//                "t": 2,
//                "d": [
//                    "topic": "chat",
//                    "event": "message",
//                    "data": [
//                      "message": "Chi 🥺",
//                      "email": dataQR.email
//                    ]
//                ]
//            ] as [String : Any]
//            self.send(intento) {
//               print("listo")
//
//            }
        }))
        present(ac, animated: true)
//        self.captureSession = nil
//        let dataws: String = "{\"t\": 2, \"d\": {\"topic\": \"chat\", \"event\": \"message\", \"data\" {\"message\": \"Chi 🥺\", \"email\": \"\(dataQR.email)\" } }"
//        send(dataws) {
//           (print("listo"))
//        }
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
    
    func send(_ value: Any, onSuccess: @escaping () -> Void ) {
        guard JSONSerialization.isValidJSONObject(value ) else {
            print("[WEBSOCKET] Value is not a valid JSON object.\n \(value)")
            return
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: value, options: [])
            socket.write(data: data){
                onSuccess()
            }
        } catch let error {
            print("[WEBSOCKET] Error serializing JSON:\n \(error)")
        }
    }
    
    // MARK: - WebSocketDelegate
       func didReceive(event: WebSocketEvent, client: WebSocket) {
           switch event {
           case .connected(let headers):
               isConnected = true
               print("websocket is connected: \(headers)")
               captureSession.startRunning()
           case .disconnected(let reason, let code):
               isConnected = false
               print("websocket is disconnected: \(reason) with code: \(code)")
           case .text(let string):
               print("Received text: \(string)")
           case .binary(let data):
               print("Received data: \(data.count)")
           case .ping(_):
               break
           case .pong(_):
               break
           case .viabilityChanged(_):
               break
           case .reconnectSuggested(_):
               break
           case .cancelled:
               isConnected = false
           case .error(let error):
               isConnected = false
               handleError(error)
           }
       }
       
       func handleError(_ error: Error?) {
           if let e = error as? WSError {
               print("websocket encountered an error: \(e.message)")
           } else if let e = error {
               print("websocket encountered an error: \(e.localizedDescription)")
           } else {
               print("websocket encountered an error")
           }
       }

}
