//
//  NetworkingManager.swift
//  UserLocationProfileV3
//
//  Created by Jo Eun Kim on 6/26/22.
//

import Foundation

class NetworkingManager {
    func getData(urlRequest: URLRequest, onSuccess: @escaping (Any)->(), onFailure: @escaping (Error)->()) {
        // MARK: GET Request Setup
        var request = urlRequest
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            // MARK: Validation
            if let error = error {
                onFailure(error)
            }
            guard let data = data else {
                onFailure(APIRequestError.dataNotFound)
                return
            }
            
            // MARK: Data Decoding
            do {
                let jsondata = try JSONSerialization.jsonObject(with: data, options: [])
                onSuccess(jsondata)
            } catch {
                onFailure(APIRequestError.decodingFailed)
            }
            
        }).resume()
    }
}

// TODO: Ask if need to handle each failure case of unwrapping optional - DONE
extension NetworkingManager {
    enum APIRequestError: Error {
        case requestFailed
        case decodingFailed
        case dataNotFound
        case urlUnwrappingFailed
        case urlComponentNotFound
        case keyNotFound
    }
}
