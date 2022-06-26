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
}