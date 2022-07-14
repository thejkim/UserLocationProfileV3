//
//  APIViewModel.swift
//  UserLocationProfileV3
//
//  Created by Jo Eun Kim on 6/29/22.
//

import Foundation

// Weak references are only defined for reference types
// : if the object conforming to the protocol needs to be stored in a weak property then the protocol must be a class-only protocol.
protocol APIViewModelDelegate: AnyObject {
    func didUpdateArticles(withArticles: ArticlesToDisplay)
    func didFailUpdateArticles(withError: Error)
    func didFailWithReachability()
}

struct APIViewModel {
    private let networkingManager = NetworkingManager() // owns
    weak var delegate: APIViewModelDelegate?
    
    func sendGetRequest(endPoint: String, queries: [String: String]) {
        // MARK: 1. Network Check
        let reachability = try? Reachability() // Service provider
        if let isReachable = reachability?.isReachable {
            if !isReachable { // Notify Controller it's unreachable
                self.delegate?.didFailWithReachability()
            }
        }
        
        // MARK: 2. Generate Full URL
        let baseURLStr = Constants.NEWSAPI_BASEURL + endPoint
        guard let key = FileDataManager.getAPIKey() else { // get api key from plist
            self.delegate?.didFailUpdateArticles(withError: NetworkingManager.APIRequestError.keyNotFound) // Notify V
            return
        }
        guard var urlComponents = URLComponents(string: baseURLStr) else {
            self.delegate?.didFailUpdateArticles(withError: NetworkingManager.APIRequestError.urlComponentNotFound) // Notify V
            return
        }
        urlComponents.queryItems = queries.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        urlComponents.queryItems?.append(URLQueryItem(name: Constants.NEWSAPI_APIKEY_KEY, value: key))
        guard let url = urlComponents.url else {
            self.delegate?.didFailUpdateArticles(withError: NetworkingManager.APIRequestError.urlUnwrappingFailed) // Notify V
            return
        }
        
        // MARK: URLRequest Setup for HTTPHeaderField
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // MARK: VM <-> M : Data Processing & Binding
        networkingManager.getData(urlRequest: request) { data in
            // Prepare business model
            prepareBusinessModel(with: Articles(articleData: data))
        } onFailure: { err in
            JKLog.log(message: "\(err)")
            self.delegate?.didFailUpdateArticles(withError: err) // Notify V
        }
        
    }
    
    private func prepareBusinessModel(with data: Articles) {
        var articlesToDisplay = [ArticleToDisplay]()
        for article in data.list {
            // 1. Generate full filename of image
            let fullFilename = generateFullFilename(source1: article.author, source2: article.publishedAt, fileExtension: Constants.IMAGE_EXTENSION)

            // 2. Get image data from document directory or download it from imageURL
            var imageData: Data?
            if let image = FileDataManager.getImage(of: fullFilename) { // Service provider
                JKLog.log(message: "Image found")
                imageData = image
            } else { // TODO: Ask if it's bad approach that cause slow performance. If so, move it to VC, (maybe)modify business model
                if let imageURL = URL(string: article.urlToImage) {
                    if let data = try? Data(contentsOf: imageURL) {
                        imageData = data
                    }
                }
            }
            
            // 3. Construct business model
            articlesToDisplay.append(ArticleToDisplay(author: article.author,
                                                      description: article.description,
                                                      publishedAt: article.publishedAt,
                                                      sourceName: article.sourceName,
                                                      title: article.title,
                                                      url: article.url,
                                                      imageData: imageData))
        }
        // 4. Notify View
        self.delegate?.didUpdateArticles(withArticles: ArticlesToDisplay(articles: articlesToDisplay))
    }
    
    // Image data file name conversion logic
    func saveImage(for title: String, publishedAt: String, withExtension: String, imageData: Data) {
        let fullFilename = generateFullFilename(source1: title, source2: publishedAt, fileExtension: withExtension)
        
        FileDataManager.saveImage(of: fullFilename, withImage: imageData) // Service provider
    }
    
    // Helper function to generate full file name with extension to use in FileManager related task
    private func generateFullFilename(source1: String, source2:String, fileExtension: String) -> String {
        let fullFileName = "\(source1)_\(source2).\(fileExtension)"
        return FileDataManager.updateFilenameToProperFormat(from: fullFileName) // Service provider helper func
        
    }
    
}
