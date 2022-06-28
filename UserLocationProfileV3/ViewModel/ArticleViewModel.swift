//
//  ViewModel.swift
//  UserLocationProfileV3
//
//  Created by Jo Eun Kim on 6/28/22.
//

import Foundation
protocol ArticleViewModelDelegate: AnyObject {
    func didUpdateArticles2(with: Articles)
}

class ArticleViewModel {
    var networkingManager: NetworkingManager!
    weak var delegate: ArticleViewModelDelegate?
    
    init() {
        networkingManager = NetworkingManager.shared
//        networkingManager.delegate = self
        
    }
    
    func getArticleData(forCountry: String, withKeyword: String) {
        networkingManager.getArticleData(forCountry: forCountry, withKeyword: withKeyword) { (articleData) in
            let dic = articleData as! Dictionary<String, Any>
//            guard let fetchedArticles = dic["articles"] as? Array<Dictionary<String, Any>> else { return }
            let fetchedArticles = Articles.generate(data: dic)
            let articles = Articles(data: fetchedArticles)
            self.delegate?.didUpdateArticles2(with: articles)
            
        }
    }
}
