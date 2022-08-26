//
//  WebSocket.swift
//  WebSocketTest
//
//  Created by Ahmad on 15/06/2022.
//

import UIKit
@available(iOS 13.0, *)
public class WebSocket: NSObject, URLSessionWebSocketDelegate {
    
    public var webSocket: URLSessionWebSocketTask?
    public var session: URLSession?
    //lo
    
   public var name: String?
    
    public func openWebSocketConnection() {
        
        let url = URL(string:"wss://demo.piesocket.com/v3/channel_1?api_key=VCXCEuvhGcBDP7XhiJJUDvR1e1D3eiVjgZ9VRiaV&notify_self")
        session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocket = session?.webSocketTask(with: url!)
        webSocket?.resume()
    }
    
    public func openWebSocketConnectionWithToken(token: String) {
        
        let url = URL(string:"wss://s3906.fra1.piesocket.com/v3/1?api_key=\(token)&notify_self")
        session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocket = session?.webSocketTask(with: url!)
        webSocket?.resume()
    }
    
    public func disconnectConnection(with message: String) {
        webSocket?.cancel(with: .goingAway, reason: message.data(using: .utf8))
    }
    
    public func authenticateUser(username: String, password: String) {
        
        let loginParameters: [String: Any] = [
            "grant_type": "password",
            "username": username,
            "password": password
        ]
        ServiceManager.postApiCall(parameters: loginParameters)
    }
    
    public func sendMessage(name: String, message: String) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(User.init(name: name, message: message))
            let string = String(data: data, encoding: .utf8)!
            let message = URLSessionWebSocketTask.Message.string(string)
            print(message)
            
            webSocket?.send(message) { error in
              if let error = error {
                // handle the error
                print(error)
              }
            }
          } catch {
            // handle the error
            print(error)
          }
    }
    
    public func printMessage() {
        print("hello Ahmed!")
    }
    
    public func sendData(name: String, message: String) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(User.init(name: name, message: message))
          //  let string = String(data: data, encoding: .utf8)
            let message = URLSessionWebSocketTask.Message.data(data)

            webSocket?.send(message) { error in
              if let error = error {
                // handle the error
                print(error)
              }
            }
          } catch {
            // handle the error
            print(error)
          }
    }
    
    public func ping() {
        webSocket?.sendPing(pongReceiveHandler: { error in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                    print("Connection is alive")
                    self.ping()
                }
            }
        })
    }
    
    public func receiveMessage() {
        webSocket?.receive(completionHandler: { [weak self] result in
            switch result {
            case .success(let message):
                DispatchQueue.main.async {
                    switch message {
                    case .data(let data):
                        print("Data is \(data)")
                    case .string(let string):
                       print("Receive Message \(string)")
                        
                    @unknown default:
                        break
                    }
                }
            case .failure(let error):
                print(error)
            }
            self?.receiveMessage()
        })
    }
}

@available(iOS 13.0, *)
extension WebSocket {
    
    public func connection() {
         func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
            print("Connected with server successfully!")
            ping()
        }
         func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
            print("Server connection is closed.")
        }
    }

}



