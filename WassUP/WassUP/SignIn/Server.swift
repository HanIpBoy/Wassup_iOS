//
//  Server.swift
//  WassUP
//
//  Created by 김진웅 on 2023/05/09.
//

import Foundation
class Server {
    var baseURL = "http://13.209.11.142:8080/"
    
    func postEmailServer(requestURL: String, requestBody:[String:Any]){
        guard let url = URL(string: Server().baseURL + requestURL) else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        request.httpBody = data
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return } // 응답 데이터가 nil이 아닌지 확인.
            if let responseString = String(data: data, encoding: .utf8) {
                print(responseString) // 응답 데이터를 콘솔에 출력
            }
        }
        task.resume()
    }
    
    func postSignInServer(requestURL: String, requestBody:[String:Any]) -> String{
        var result : String = ""
        guard let url = URL(string: Server().baseURL + requestURL) else { return "" }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        request.httpBody = data
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return } // 응답 데이터가 nil이 아닌지 확인.
            if let responseString = String(data: data, encoding: .utf8) {
                print(responseString) // 응답 데이터를 콘솔에 출력
                result = responseString
            
            }
        }
        task.resume()
        
        return result
        
    }
}
