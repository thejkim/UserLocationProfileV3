//
//  LocationDisplayVC.swift
//  UserLocationProfile
//
//  Created by Joeun Kim on 6/11/22.
//

import UIKit
import CoreLocation

class LocationDisplayVC: UIViewController, LocationManagerDelegate, NetworkingManagerDelegate, UITextFieldDelegate {
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var stateNameLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var keywordTF: UITextField!
    @IBOutlet weak var articlesTV: UITableView!
    
    let locationManager = LocationManager.shared
    let networkingManager = NetworkingManager() // owns
    var articles = [ArticleData]() // datasource for articlesTV
    
    var targetUrlStr: String?
    var currentCountryCode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

        locationManager.delegate = self
        networkingManager.delegate = self
    }
    
    // got notified from LocationManager that location is updated
    // -> perform API call based on the given location
    func locationDidUpdateWith(city: String, state: String, country: String, countryCode: String) {
        JKLog.log(message: "\(Thread.current)")

        cityNameLabel.text = city
        stateNameLabel.text = state
        countryNameLabel.text = country
        
        currentCountryCode = countryCode.lowercased()
        
        // MARK: Controller -> Model : perform API call to generate articles

        // Method 1: Using Delegation Data Binding
        networkingManager.getArticlesFor(endPoint: Constants.END_POINT_TOP_HEADLINES, queries: ["country":currentCountryCode])

         // Method 2: Using Callbacks Data Binding (Completion Handler)
        networkingManager.getArticleData(endPoint: Constants.END_POINT_TOP_HEADLINES, queries: ["country":currentCountryCode]) { [weak self] data in
            self?.articles = Articles(articleData: data).list
            DispatchQueue.main.async {
                self?.articlesTV.reloadData()
            }
        } onFailure: { error in
            JKLog.log(message: error.localizedDescription)
        }
        
        
    }
    
    // Method 1: Using Delegation Data Binding
    // got notified from NetworkingManager that new articles fetched from API call
    // -> reload tableView with given articles
    func didUpdateArticles(withArticles: Articles) {
        articles = withArticles.list
        JKLog.log(message: "thread: \(Thread.current)")
        DispatchQueue.main.async {
            self.articlesTV.reloadData()
        }
    }
    
    // got notified from NetworkingManager that API call failed
    func didFailUpdateArticles(withError: Error) {
        JKLog.log(message: withError.localizedDescription)
    }
    
    // got notified from NetworkingManager that network is unreachable
    // -> inform user
    func didFailWithReachability() {
        let alert = UIAlertController(title: "Network Unreachable", message: "We cannot reach out the API service", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func refreshBarBtnTouched(_ sender: UIBarButtonItem) {
        networkingManager.getArticlesFor(endPoint: Constants.END_POINT_TOP_HEADLINES, queries: ["country":currentCountryCode, "q":keywordTF.text ?? ""])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Empty input will fetch all articles for given country code
        networkingManager.getArticlesFor(endPoint: Constants.END_POINT_TOP_HEADLINES, queries: ["country":currentCountryCode, "q":textField.text ?? ""])

        textField.resignFirstResponder()
        return true
    }
    
}

extension LocationDisplayVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        JKLog.log(message: "articles.count: \(articles.count)")
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell") as! ArticleCell
        
        // take it out articles[indexPath.row] -> var. reuse it
        cell.sourceName.text = articles[indexPath.row].sourceName
        cell.title.text = articles[indexPath.row].title
        
        // MARK: Check if image already exists in document directory
        // Load image data if exists from document directory in main queue serially
        if let loadedImageData = FileDataManager.loadImageIfAvailable(for: articles[indexPath.row].title, publishedAt: articles[indexPath.row].publishedAt, withExtension: "png") {
            cell.imageView?.image = UIImage(data: loadedImageData)
            JKLog.log(message: "File exists. Loaded image from document directory")
        } else {
            JKLog.log(message: "Downloading image file...")
            if let imageURL = URL(string: articles[indexPath.row].urlToImage) {
                if let imageData = try? Data(contentsOf: imageURL) {
                    let image = UIImage(data: imageData)
                    cell.imageView?.image = image
                } else {
                    cell.imageView?.image = UIImage(systemName: "rec")
                }
            }
            
            // MARK: Save first 10 images in document directory if needed
            if indexPath.row < 10 {
                JKLog.log(message: "Saving image file...")
                // Check # of files in doc dir and remove file if needed
                FileDataManager.removeOldestFileIfCountExceeds()
                                
                // Save image in document directory
                FileDataManager.saveImageFrom(for: articles[indexPath.row].title, publishedAt: articles[indexPath.row].publishedAt, withExtension: "png", url: self.articles[indexPath.row].urlToImage)
            } // end of saving images
        }

        cell.author.text = articles[indexPath.row].author
        cell.descriptionTextView.text = articles[indexPath.row].description
        cell.publishDate.text = articles[indexPath.row].publishedAt
        return cell
 
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        JKLog.log(message: "selected!")
        
        // Perform segue to load url in webview
        targetUrlStr = articles[indexPath.row].url
        
        // Present VC to load url in webview
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(identifier: "LoadUrlVC") as! LoadUrlVC
        destinationVC.targetUrlStr = targetUrlStr
        present(destinationVC, animated: true, completion: nil)
        
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 281
//    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
