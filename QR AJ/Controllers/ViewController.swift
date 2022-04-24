//
//  ViewController.swift
//  QR AJ
//
//  Created by Ariana Esquivel on 21/04/22.
//

import UIKit
import Starscream

class ViewController: UIViewController, WebSocketDelegate {
    @IBOutlet weak var btnEscanear: UIButton!
    var socket: WebSocket!
    var isConnected = false
    let server = WebSocketServer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnEscanear.layer.cornerRadius = btnEscanear.bounds.height / 3
        var request = URLRequest(url: URL(string: "ws://192.168.100.9:3333/adonis-ws")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
//        let susc: String = "{ \"t\": 1, \"d\": { \"topic\": \"chat\", \"event\": \"message\", \"data\": \"probando\"} }"
        let intento = [
            "t": 1,
            "d": [
                "topic": "chat",
                "event": "message",
                "data": [
                  "message": "",
                  "email": ""
                ]
            ]
        ] as [String : Any]
//        let data: WSdata = WSdata.init(message: "", email: "")
//        let d: WSd = WSd.init(topic: "chat", event: "message", data: data)
//        let ws: WS = WS.init(t: 1, d: d)
//        let en = try! JSONEncoder().encode(ws)
        send(intento) {
           (print("listo"))
        }
        // Do any additional setup after loading the view.
    }
    
    // MARK: - WebSocketDelegate
       func didReceive(event: WebSocketEvent, client: WebSocket) {
           switch event {
           case .connected(let headers):
               isConnected = true
               print("websocket is connected: \(headers)")
               let intento = [
                   "t": 1,
                   "d": [
                       "topic": "chat",
                       "event": "message",
                       "data": [
                         "message": "",
                         "email": ""
                       ]
                   ]
               ] as [String : Any]
               send(intento) {
                  (print("listo"))
               }
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
        func send(_ value: Any, onSuccess: @escaping () -> Void ) {
            guard JSONSerialization.isValidJSONObject(value ) else {
                print("[WEBSOCKET] Value is not a valid JSON object.\n \(value)")
//                let intent = try JSONEncoder().encode(value)
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
    
}

struct WS: Encodable {
    let t: Int
    let d: WSd
}
struct WSd: Encodable {
    let topic: String
    let event: String
    let data: WSdata
}
struct WSdata: Encodable {
    let message: String
    let email: String
}

