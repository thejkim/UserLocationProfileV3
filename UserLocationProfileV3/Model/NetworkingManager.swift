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
    func didUpdateArticles(withArticles: [Article]) // Notify Controller with updated articles
    func didFailWithReachability() // Notify Controller to inform user
}

class NetworkingManager {
    
    static let shared = NetworkingManager()
    weak var delegate: NetworkingManagerDelegate?
    
    private init() {
        
    }

    func getArticles(forCountry countryCode: String, withKeyword keyword: String) {
        JKLog.log(message: "\(countryCode), \(keyword)")
        var articles = [Article]()

        // TODO: get url info from Controller?
        let baseURLStr = "https://newsapi.org"
        let endpointURLStr = "/v2/top-headlines"
        guard let key = FileDataManager.shared.getAPIKey() else {return}
        
        let params = "?country=\(countryCode)&q=\(keyword)&apiKey=\(key)"
        let urlStr = "\(baseURLStr)\(endpointURLStr)\(params)"

        guard let url = URL(string: urlStr) else { return }

        // MARK: Network Checks
        let reachability = try? Reachability()
        if let isReachable = reachability?.isReachable {
            if !isReachable { // Notify Controller it's unreachable
                self.delegate?.didFailWithReachability()
            }
        }
        
        // MARK: Request Setup
        var request = URLRequest(url: url)

        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            JKLog.log(message: "dataTask::: \(Thread.current)")
            
            guard let data = data else { return }
            
            do {
                let jsondata = try JSONSerialization.jsonObject(with: data, options: [])
                
                // "Understand responsibility!!! it should only have api related task"
                // TODO: pass dic["articles"] to Article model, and model does below(loop over array of article) in there
                let dic = jsondata as! Dictionary<String, Any>
                guard let fetchedArticles = dic["articles"] as? Array<Dictionary<String, Any>> else { return }
                for article in fetchedArticles {
                    let newArticle = article

                    let newArticleInstance = Article()
                    // TODO: use init
                    newArticleInstance.author = newArticle["author"] as? String ?? "N/A"
                    newArticleInstance.content = newArticle["content"] as? String ?? "N/A"
                    newArticleInstance.description = newArticle["description"] as? String ?? "N/A"
                    newArticleInstance.publishedAt = newArticle["publishedAt"] as? String ?? "N/A"
                    
                    // get source id, name
                    guard let source = newArticle["source"] as? Dictionary<String, Any> else { return } // NSDictionary
                    newArticleInstance.sourceID = source["id"] as? String ?? "N/A"
                    newArticleInstance.sourceName = source["name"] as? String ?? "N/A"
                    
                    newArticleInstance.title = newArticle["title"] as? String ?? "N/A"
                    newArticleInstance.url = newArticle["url"] as? String ?? "N/A"
                    newArticleInstance.urlToImage = newArticle["urlToImage"] as? String ?? "N/A"
                    
                    // append - will be passed out to controller
                    articles.append(newArticleInstance)
                    
                }
                // Model -> Controller : Notify delegator with updated data
                self.delegate?.didUpdateArticles(withArticles: articles)
                    

            } catch {
                JKLog.log(message: "Failed to fetch articles")
            }
            
        })
        
        task.resume()
        
    }
}
