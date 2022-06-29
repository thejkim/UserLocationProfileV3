//
//  Articles.swift
//  UserLocationProfileV3
//
//  Created by Jo Eun Kim on 6/28/22.
//

import Foundation

struct Articles: Codable {
    var list = [ArticleData]()
    
    init(articleData: Any) {
        self.list = generate(data: articleData)
    }
    
    private func generate(data: Any) -> [ArticleData] {
        var articles = [ArticleData]()
        
        let dic = data as! Dictionary<String, Any>
        guard let fetchedArticles = dic["articles"] as? Array<Dictionary<String, Any>> else { return [] }
        for article in fetchedArticles {
            let newArticle = article

            guard let source = newArticle["source"] as? Dictionary<String, Any> else { return [] } // NSDictionary
            let newArticleInstance = ArticleData(author: newArticle["author"] as? String ?? "N/A",
                                             content: newArticle["content"] as? String ?? "N/A",
                                             description: newArticle["description"] as? String ?? "N/A",
                                             publishedAt: newArticle["publishedAt"] as? String ?? "N/A",
                                             sourceID: source["id"] as? String ?? "N/A",
                                             sourceName: source["name"] as? String ?? "N/A",
                                             title: newArticle["title"] as? String ?? "N/A",
                                             url: newArticle["url"] as? String ?? "N/A",
                                             urlToImage: newArticle["urlToImage"] as? String ?? "N/A")
            
//            let newArticleInstance = ArticleData(author: newArticle["author"] as? String ?? "N/A",
//                                             content: newArticle["content"] as? String ?? "N/A",
//                                             description: newArticle["description"] as? String ?? "N/A",
//                                             publishedAt: newArticle["publishedAt"] as? String ?? "N/A",
//                                             sourceID: newArticle["source"]["id"] as? String ?? "N/A",
//                                             sourceName: newArticle["source"]["id"] as? String ?? "N/A",
//                                             title: newArticle["title"] as? String ?? "N/A",
//                                             url: newArticle["url"] as? String ?? "N/A",
//                                             urlToImage: newArticle["urlToImage"] as? String ?? "N/A")
//
            
            articles.append(newArticleInstance)
        }
        return articles
    }
}



struct ArticleData: Codable {
    var author: String
    var content: String
    var description: String
    var publishedAt: String
    var sourceID: String
    var sourceName: String
    var title: String
    var url: String
    var urlToImage: String
}

