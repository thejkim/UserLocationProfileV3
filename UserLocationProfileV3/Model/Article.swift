//
//  Article.swift
//  NewsAPIRequest
//
//  Created by Jo Eun Kim on 6/14/22.
//

import Foundation

class Article: Codable {
    var author: String
    var content: String
    var description: String
    var publishedAt: String
    var sourceID: String
    var sourceName: String
    var title: String
    var url: String
    var urlToImage: String
    
    init() {
        self.author = ""
        self.content = ""
        self.description = ""
        self.publishedAt = ""
        self.sourceID = ""
        self.sourceName = ""
        self.title = ""
        self.url = ""
        self.urlToImage = ""
    }
    
    
    init(author: String, content: String, description: String, publishedAt: String, sourceID: String, sourceName: String, title:String, url: String, urlToImage: String) {
        self.author = author
        self.content = content
        self.description = description
        self.publishedAt = publishedAt
        self.sourceID = sourceID
        self.sourceName = sourceName
        self.title = title
        self.url = url
        self.urlToImage = urlToImage
    }
    
    func constructBusinessModel(root: Dictionary<String, Any>) {
        var articles = [Article]()
        guard let fetchedArticles = root["articles"] as? Array<Dictionary<String, Any>> else { return }
        for article in fetchedArticles {
            let newArticle = article

            guard let source = newArticle["source"] as? Dictionary<String, Any> else { return } // NSDictionary
            let newArticleInstance = Article(author: newArticle["author"] as? String ?? "N/A",
                                             content: newArticle["content"] as? String ?? "N/A",
                                             description: newArticle["description"] as? String ?? "N/A",
                                             publishedAt: newArticle["publishedAt"] as? String ?? "N/A",
                                             sourceID: source["id"] as? String ?? "N/A",
                                             sourceName: source["name"] as? String ?? "N/A",
                                             title: newArticle["title"] as? String ?? "N/A",
                                             url: newArticle["url"] as? String ?? "N/A",
                                             urlToImage: newArticle["urlToImage"] as? String ?? "N/A")
            
            // append - will be passed out to controller
            articles.append(newArticleInstance)
        }
        
    }
}

