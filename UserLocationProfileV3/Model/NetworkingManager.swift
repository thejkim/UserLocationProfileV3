//
//  NetworkingManager.swift
//  UserLocationProfileV3
//
//  Created by Jo Eun Kim on 6/26/22.
//

import Foundation

// Weak references are only defined for reference types
// : if the object conforming to the protocol needs to be stored in a weak property then the protocol must be a class-only protocol.
protocol NetworkingManagerDelegate: AnyObject {
    func didUpdateArticles(withArticles: Articles) // Notify Controller with updated articles
    func didFailUpdateArticles(withError: Error) // Notify Controller API Request for articles failure
    func didFailWithReachability() // Notify Controller to inform user
}

class NetworkingManager {
    weak var delegate: NetworkingManagerDelegate?

    // Method 1: Using Callbacks Data Binding (Completion Handler)
    func getArticleData(endPoint: String, queries: [String:String], onSuccess: @escaping (Any) -> (), onFailure: @escaping(Error) -> () ) {
        
        // MARK: Network Checks
        let reachability = try? Reachability()
        if let isReachable = reachability?.isReachable {
            if !isReachable { // Notify Controller it's unreachable
                self.delegate?.didFailWithReachability()
            }
        }
        
        // MARK: URL Setup
        let baseURLStr = Constants.NEWSAPI_BASEURL + endPoint
        guard let key = FileDataManager.getAPIKey() else {return}
        guard var urlComponents = URLComponents(string: baseURLStr) else {return}
        urlComponents.queryItems = queries.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        urlComponents.queryItems?.append(URLQueryItem(name: "apiKey", value: key))
        
        // MARK: Request Setup
        guard let url = urlComponents.url else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            JKLog.log(message: "dataTask: \(Thread.current)")
            
            if let error = error {
                onFailure(error)
            }
            guard let data = data else { return }
            
            do {
                let jsondata = try JSONSerialization.jsonObject(with: data, options: [])
                onSuccess(jsondata)
            } catch {
                onFailure(APIRequestError.decodingError)
            }
            
        }).resume()
        
    }
    
    // Method 2: Using Delegation Data Binding - current
    func getArticlesFor(endPoint: String, queries: [String:String]) {
        
        // MARK: Network Checks
        let reachability = try? Reachability()
        if let isReachable = reachability?.isReachable {
            if !isReachable { // Notify Controller it's unreachable
                self.delegate?.didFailWithReachability()
            }
        }
        
        // MARK: URL Setup
        let baseURLStr = Constants.NEWSAPI_BASEURL + endPoint
        guard let key = FileDataManager.getAPIKey() else {return}
        guard var urlComponents = URLComponents(string: baseURLStr) else {return}
        urlComponents.queryItems = queries.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        urlComponents.queryItems?.append(URLQueryItem(name: "apiKey", value: key))
        
        // MARK: Request Setup
        guard let url = urlComponents.url else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            JKLog.log(message: "dataTask: \(Thread.current)")
            
            if let error = error {
                self.delegate?.didFailUpdateArticles(withError: error)
            } else {
                guard let data = data else { return }
                
                do {
                    let jsondata = try JSONSerialization.jsonObject(with: data, options: []) // include this too in model
                    let articles = Articles(articleData: jsondata)
                    self.delegate?.didUpdateArticles(withArticles: articles)

                } catch {
                    self.delegate?.didFailUpdateArticles(withError: APIRequestError.decodingError)
                }
            }
        }).resume()
    }
    
}

// TODO: Ask if need to handle each failure case of unwrapping optional
extension NetworkingManager {
    enum APIRequestError: Error {
        case requestError
        case decodingError
    }
}
