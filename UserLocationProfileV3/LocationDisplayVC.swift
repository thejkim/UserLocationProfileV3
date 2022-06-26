//
//  LocationDisplayVC.swift
//  UserLocationProfile
//
//  Created by Joeun Kim on 6/11/22.
//

import UIKit
import CoreLocation

class LocationDisplayVC: UIViewController, LocationManagerDelegate { 

    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var stateNameLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var articlesTV: UITableView!
    
    let locationManager = ST_LocationManager.shared
    var articles = [Article]()
    var apiKey: String?
    var targetUrlStr: String?
    
    var pendingIndexPath: [IndexPath] = []
    
    // MARK: NSCache for image
    var cacheInstance = NSCache<NSString, NSData>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = Bundle.main.path(forResource: Constants.KEY_PLIST_NAME, ofType: "plist") {
            if let dic = NSDictionary(contentsOfFile: path) as? Dictionary<String, String> {
                if let value = dic[Constants.API_KEY] {
                    apiKey = value
                }
            }
        }
        
        // MARK: Check Location Service Authorization Status
        switch locationManager.checkAuthorizationStatus() {
        case .notDetermined:
            print("notDetermined")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationVC = storyboard.instantiateViewController(identifier: "LocationServiceAuthorizationVC")
            present(destinationVC, animated: true, completion: nil)
        case .systemNotAllowed:
            print("location service disabled")
            let alert = UIAlertController(title: "Location Service Disabled", message: "Location service is disabled. Please go to Settings, enabled the location service to allow the app access to your current location.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        case .appNotAllowed:
            let alert = UIAlertController(title: "App Not Authorized", message: "We are not authorized to access your location information. Please go to App Settings, enabled the location service of the app to give access to your current location.", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let openSettings = UIAlertAction(title: "Open Settings", style: .default, handler: {(action ) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
            alert.addAction(cancel)
            alert.addAction(openSettings)
            self.present(alert, animated: true, completion: nil)
            print("app not allowed to access location info")
        default:
            print("\(locationManager.checkAuthorizationStatus())")
        }
        
        locationManager.delegate = self // make new instance of delegate, not changing/assigning to old one
        
        //MARK: NSCache for image
        cacheInstance.name = "imageCache"

    }
    
    func locationDidUpdateWith(city: String, state: String, country: String, countryCode: String) {
        JKLog.log(message: "\(Thread.current)")

        cityNameLabel.text = city
        stateNameLabel.text = state
        countryNameLabel.text = country
        
        fetchArticlesFor(currentCountry: countryCode.lowercased())
        
    }
    @IBAction func refreshBarBtnTouched(_ sender: UIBarButtonItem) {
        
    }
    
    func fetchArticlesFor(currentCountry countryCode: String) {// TODO:
        let baseURLStr = "https://newsapi.org"
        let endpointURLStr = "/v2/top-headlines"
        guard let key = apiKey else {return}
        let params = "?country=\(countryCode)&apiKey=\(key)"
        let urlStr = "\(baseURLStr)\(endpointURLStr)\(params)"

        guard let url = URL(string: urlStr) else { return }

        // MARK: Network, Server Checks
        // try? url.checkResourceIsReachable()
        let reachability = try? Reachability()
        if let isReachable = reachability?.isReachable {
            if !isReachable {
                let alert = UIAlertController(title: "Network Unreachable", message: "We cannot reach out the API service", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        }
//        if let isServerAvailable = reachability?.isInternetAvailable(websiteToPing: baseURLStr) {
//            if !isServerAvailable {
//                let alert = UIAlertController(title: "Server Unavailable", message: "We cannot reach out the API service", preferredStyle: .alert)
//                let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                alert.addAction(ok)
//                self.present(alert, animated: true, completion: nil)
//            }
//        }
        
        // MARK: Request Setup
        var request = URLRequest(url: url)

        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            JKLog.log(message: "dataTask::: \(Thread.current)")
            
            guard let data = data else { return }
            
            do {
                let jsondata = try JSONSerialization.jsonObject(with: data, options: [])
                
                let dic = jsondata as! Dictionary<String, Any>
                guard let fetchedArticles = dic["articles"] as? Array<Dictionary<String, Any>> else { return }
                for article in fetchedArticles {
                    let newArticle = article

                    let newArticleInstance = Article()
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
                    
                    /*// MARK: NSCache for image
                    // if cachedImageData found, skip to cache imageData
                    if let cachedImageData = self.cacheInstance.object(forKey: newArticle["urlToImage"] as? NSString ?? "N/A") {
                        JKLog.log(message: "Cached image found")
                    } else { // if cachedImageData not found, cache imageData
                        if let imageURL = URL(string: newArticle["urlToImage"] as? String ?? "N/A") {
                            if let imageData = try? Data(contentsOf: imageURL) {
                                JKLog.log(message: "Caching imageData...")
                                self.cacheInstance.setObject(imageData as NSData, forKey: imageURL.absoluteString as NSString)
                            }
                        }
                    }*/ // end of caching imageData
                    
                    // append
                    self.articles.append(newArticleInstance)
                    
                    // if getting one article by one, reloadRow

                    
                }
                DispatchQueue.main.async {
                    self.articlesTV.reloadData()
                }

            } catch {
                JKLog.log(message: "Failed to fetch articles")
            }
            
        })
        
        task.resume()
        
    }
    
    func checkIfFileExists(for title: String, publishedAt: String) -> Bool {
        print("title=\(title)")
        var isFound = false
        JKLog.log(message: "\(Thread.current)")

        if let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first { // go to document directory
            let path = documentURL.appendingPathComponent("\(title)_\(publishedAt).png").path
            
            print("Searching for file: \(path)")

            
            if FileManager.default.fileExists(atPath: path) {
                JKLog.log(message: "file found.")
                isFound = true
            } else {
                JKLog.log(message: "file not found.")
            }
        }
        return isFound
    }
    
    func loadImageIfAvailable(for title: String, publishedAt: String) -> UIImage? {
        var loadedImage: UIImage?

        if checkIfFileExists(for: title, publishedAt: publishedAt) {
            JKLog.log(message: "Loading image from doc dir...")

            if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(title)_\(publishedAt).png").path {
                
                let image = UIImage(contentsOfFile: path)
                loadedImage = image
            }
                
        }
        return loadedImage
    }
    
    func loadImage(for title: String, publishedAt: String, at indexPath: IndexPath) {
        var loadedImage: UIImage?
        JKLog.log(message: "Loading image from doc dir...")

        ///* DispatchQueue.global.async
//        if checkIfFileExists(for: title, publishedAt: publishedAt) {
            DispatchQueue.global(qos: .userInitiated).async { // Need Completion handler
        
                if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(title)_\(publishedAt).png").path {
                    
                    let image = UIImage(contentsOfFile: path)
                    loadedImage = image
                }
                
                DispatchQueue.main.async {
                    if let cellImageViewAt = self.articlesTV.cellForRow(at: indexPath)?.imageView {
                        cellImageViewAt.image = loadedImage // assign image to imageView for the given cell
//                        self.articlesTV.reloadRows(at: [indexPath], with: .automatic) // reload the TV for the given indexPath
                        JKLog.log(message: "Given cell is updated with loaded image")
                    }
                }
            }
//        }
        //*/ // end of global dispatch queue
        
        
        /* Operation Queue
        let opQueue = OperationQueue()
        
        let blockOperation = BlockOperation {
            if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(title)_\(publishedAt).png").path {
                
                let image = UIImage(contentsOfFile: path)
                loadedImage = image
                JKLog.log(message: "Saved image loaded at \(indexPath)")
                self.pendingIndexPath.append(indexPath)
            }
        }
        
        opQueue.addOperation(blockOperation)
        
        blockOperation.completionBlock = {
            // UPDATE TABLEVIEW ROW AT
            DispatchQueue.main.async {
                
                if let cellImageViewAt = self.articlesTV.cellForRow(at: indexPath)?.imageView {
                    cellImageViewAt.image = loadedImage // assign image to imageView for the given cell
                    self.articlesTV.reloadRows(at: [indexPath], with: .automatic) // reload the TV for the given indexPath
                    JKLog.log(message: "Given cell is updated with loaded image")
                    self.pendingIndexPath.remove(at: indexPath.row)
                }
            }
        }
        
         */ // end of Operation Queue
        
        
    }
    
    func removeOldestFileIfCountExceeds() {
        var oldestFile = ""
        let delimiter = "_"
        var publishedDate = ""
        let username = "test1" // TODO: properly get username
        DispatchQueue.global(qos: .utility).async {
            if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let path = url.path
                if let files = try? FileManager.default.contentsOfDirectory(atPath: path) {
                    if files.count >= 10 {
                        // REMOVE OLDEST FILE
                        for file in files {
                            if !files.description.hasPrefix("\(username)_") { // prevent from removing user profile image
                                publishedDate = file.description.components(separatedBy: delimiter).last ?? ""
                                if publishedDate > oldestFile{
                                    oldestFile = file
                                }
                            }
                        }
                        
                        do {
                            let targetFilePath = url.appendingPathComponent(oldestFile).path
                            try FileManager.default.removeItem(atPath: targetFilePath)
                            JKLog.log(message: "File removed.")
                        } catch {
                            JKLog.log(message: "Failed to remove file")
                        }
                    }
                    
                    
                }
            }
        } // end of subthread
    }
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let destination = segue.destination as! LoadUrlVC
//        if let targetUrlStr = targetUrlStr {
//            destination.targetUrlStr = targetUrlStr
//        }
//    }
    
}

extension LocationDisplayVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleCell
        cell.sourceName.text = articles[indexPath.row].sourceName
        cell.title.text = articles[indexPath.row].title
        // When saved, white space will be replaced by %
        //              : by /
        // MARK: Handling the special character cases for file name
        let titleWithoutWhiteSpace = self.articles[indexPath.row].title.replacingOccurrences(of: " ", with: "")
        let titleSavingFormat = titleWithoutWhiteSpace.replacingOccurrences(of: ":", with: "")
        let publishedAtWithoutWhiteSpace = self.articles[indexPath.row].publishedAt.replacingOccurrences(of: " ", with: "")
        let publishedAtSavingFormat = publishedAtWithoutWhiteSpace.replacingOccurrences(of: ":", with: "")
        
        
        /*// MARK: NSCache for image
        // Check if imageData is in cache
        if let cachedImageData = cacheInstance.object(forKey: articles[indexPath.row].urlToImage as NSString) {
            JKLog.log(message: "Using cached image!")
            let image = UIImage(data: cachedImageData as Data)
//            if let imageView = cell.imageView {
//                JKLog.log(message: "::: imageView unwrapped")
//                imageView.image = image
//            } else {
//                JKLog.log(message: "::: imageView failed to unwrap")
//            }
            cell.imageView?.image = image
        } else { */
            // MARK: Check if image already exists in document directory
            /* Case: if file exists, load image from document directory asynchronously, update specific row
            if checkIfFileExists(for: titleSavingFormat, publishedAt: publishedAtSavingFormat) {
                // Load image file from document directory, update UI once loaded
    //            loadImage(for: titleSavingFormat, publishedAt: publishedAtSavingFormat, at: indexPath)
            */
            // Case: Load image if exists from document directory in main queue serially
            if let loadedImage = loadImageIfAvailable(for: titleSavingFormat, publishedAt: publishedAtSavingFormat) {
                cell.imageView?.image = loadedImage
                cell.imageView?.clipsToBounds = true
                JKLog.log(message: "File exists. Loaded image from document directory")
            } else {
                JKLog.log(message: "Downloading image file...")
                if let imageURL = URL(string: articles[indexPath.row].urlToImage) {
                    if let imageData = try? Data(contentsOf: imageURL) {
                        let image = UIImage(data: imageData)
                        cell.imageView?.image = image
//                        cell.imageView?.sizeToFit()
                        cell.imageView?.clipsToBounds = true
//                        cell.imageView?.contentMode = .scaleAspectFill
                    } else {
                        cell.imageView?.image = UIImage(systemName: "rec")
                    }
                }
                
                
                // MARK: Save first 10 images in document directory if needed
                if indexPath.row < 10 {
                    JKLog.log(message: "Saving image file...")
                    // Check # of files in doc dir and remove file if needed
                    removeOldestFileIfCountExceeds()
                    
                    let fileName = "\(titleSavingFormat)_\(publishedAtSavingFormat)"
                    
                    // Save image in document directory
                    DispatchQueue.global(qos: .background).async {
                        if let imageURL = URL(string: self.articles[indexPath.row].urlToImage) {
                            do {
                                let imageData = try Data(contentsOf: imageURL)
                                if let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                                    let outputFileURL = documentURL.appendingPathComponent("\(fileName).png")
                                 
                                    do {
                                        try imageData.write(to: outputFileURL)
                                        print("File saved: \(outputFileURL)")
                                    } catch {
                                        JKLog.log(message: "Failed to save image: \(error)")
                                    }
                                }
                            } catch {
                                JKLog.log(message: "Failed to download imageData: \(error)")
                            }
                        }
                    } // end of subthread */
                } // end of saving images
                
            }
        /* } */ // NSCache else block end
        cell.author.text = articles[indexPath.row].author
        cell.descriptionTextView.text = articles[indexPath.row].description
        cell.publishDate.text = articles[indexPath.row].publishedAt
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        JKLog.log(message: "selected!")
        
        // Perform segue to load url in webview
        targetUrlStr = articles[indexPath.row].url
//        performSegue(withIdentifier: "LoadUrlVC", sender: self)
        
        // Present VC to load url in webview
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(identifier: "LoadUrlVC") as! LoadUrlVC
        destinationVC.targetUrlStr = targetUrlStr
        present(destinationVC, animated: true, completion: nil)
        
        
        
        
        /* MARK:- Saving image file once cell selected
        // Check if file already exists
        let titleWithoutWhiteSpace = self.articles[indexPath.row].title.replacingOccurrences(of: " ", with: "%")
        
        if !checkIfFileExists(for: titleWithoutWhiteSpace
                             , publishedAt: articles[indexPath.row].publishedAt) {
            JKLog.log(message: "Saving image file...")
            
            // Check # of files in doc dir and remove file if needed
            removeOldestFileIfCountExceeds()
            
            let fileName = "\(titleWithoutWhiteSpace)_\(self.articles[indexPath.row].publishedAt)"
            
            
            // Save image in document directory
            DispatchQueue.global(qos: .utility).async {
                if let imageURL = URL(string: self.articles[indexPath.row].urlToImage) {
                    do {
                        let imageData = try Data(contentsOf: imageURL)
                        if let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                            let outputFileURL = documentURL.appendingPathComponent("\(fileName).png")
                            
                            do {
                                try imageData.write(to: outputFileURL)
                                print("File saved: \(outputFileURL)")
                            } catch {
                                JKLog.log(message: "Failed to save image: \(error)")
                            }
                        }
                    } catch {
                        JKLog.log(message: "Failed to download imageData: \(error)")
                    }
                }
            } // end of subthread
        }
        */
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 281
//    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
