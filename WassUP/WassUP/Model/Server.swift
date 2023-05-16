//
//  Server.swift
//  WassUP
//
//  Created by 김진웅 on 2023/05/09.
//

import Foundation
class Server {
    var baseURL = "http://43.202.6.236:8080/"
    var result: String = ""
    
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
    
    func emailVerify(requestURL: String, requestBody:[String:Any], completion: @escaping (String) -> Void) {
        guard let url = URL(string: Server().baseURL + requestURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        request.httpBody = data
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                completion("") // 응답 데이터가 없을 경우 빈 문자열 전달
                return
            }
            completion(responseString) // 응답 데이터를 completion 핸들러를 통해 전달
        }
        task.resume()
    }
    
    
    func signIn(requestURL: String, requestBody: [String:Any], completion: @escaping (String?) -> Void) {
        guard let url = URL(string: Server().baseURL + requestURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        request.httpBody = data
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completion(nil) // 응답 데이터가 없는 경우 nil 반환
                return
            }
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                let token = jsonResponse?["token"] as? String
                completion(token) // 응답 데이터 중 "token" 값을 반환
            } catch {
                completion(nil) // 파싱 오류 발생 시 nil 반환
            }
        }
        task.resume()
    }
    
    func createSchedule(requestURL: String, requestData: [String: Any], token: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let url = URL(string: Server().baseURL + requestURL) else {
            completion(nil, nil, nil) // 잘못된 URL이면 completion에 nil 전달
            return
        }
        
        var request = URLRequest(url: url)
        var header = "Bearer \(token)"
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(header, forHTTPHeaderField: "Authorization")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestData)
            request.httpBody = jsonData
        } catch {
            completion(nil, nil, error) // JSON 데이터 변환 오류 발생 시 completion에 오류 전달
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            completion(data, response, error) // 요청 결과를 completion에 전달
        }
        task.resume()
    }
    
    func getAllData(requestURL: String, token: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let url = URL(string: Server().baseURL + requestURL) else {
            completion(nil, nil, nil) // 잘못된 URL이면 completion에 nil 전달
            return
        }
        
        var request = URLRequest(url: url)
        let header = "Bearer \(token)"
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(header, forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            completion(data, response, error) // 요청 결과를 completion에 전달
        }
        task.resume()
    }

}
