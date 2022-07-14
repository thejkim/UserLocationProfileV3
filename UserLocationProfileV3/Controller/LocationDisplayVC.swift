//
//  LocationDisplayVC.swift
//  UserLocationProfile
//
//  Created by Joeun Kim on 6/11/22.
//

import UIKit
import CoreLocation

class LocationDisplayVC: UIViewController, LocationManagerDelegate, APIViewModelDelegate, UITextFieldDelegate {
    func locationDidUpdateWith(location: CLLocation?) {
        // NOT USING HERE. CURRENTLY TESTING MAPKIT WITH THIS DELEGATE
    }
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var stateNameLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var keywordTF: UITextField!
    @IBOutlet weak var articlesTV: UITableView!
    
    let locationManager = LocationManager.shared // Service provider
    var apiComminicator = APIViewModel() // owns
    var articles = [ArticleToDisplay]() // datasource for articlesTV
    
    var targetUrlStr: String?
    var currentCountryCode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Check Location Service Authorization Status
        switch locationManager.checkAuthorizationStatus() {
        case .notDetermined:
            let storyboard = UIStoryboard(name: Constants.Identifiers.MAIN_STORYBOARD, bundle: nil)
            let destinationVC = storyboard.instantiateViewController(identifier: Constants.Identifiers.LOCATION_SERVICE_AUTH_VC)
            present(destinationVC, animated: true, completion: nil)
        case .systemNotAllowed: // location service disabled
            JKAlert.showOK(title: Constants.AlertMessages.LOCATION_SERVICE_DISABLED_TITLE, message: Constants.AlertMessages.LOCATION_SERVICE_DISABLED_MESSAGE, on: self)
        case .appNotAllowed: // authorization denied by user
            JKAlert.showAndOpenURL(title: Constants.AlertMessages.LOCATION_SERVICE_NOT_AUTH_TITLE, message: Constants.AlertMessages.LOCATION_SERVICE_NOT_AUTH_MESSAGE, open: URL(string: UIApplication.openSettingsURLString), on: self)
        default:
            print("\(locationManager.checkAuthorizationStatus())")
        }

        locationManager.delegate = self
        apiComminicator.delegate = self
    }
    
    // got notified from LocationManager that location is updated
    // -> perform API call based on the given location
    func locationDidUpdateWith(city: String, state: String, country: String, countryCode: String) {
        JKLog.log(message: "\(Thread.current)")

        cityNameLabel.text = city
        stateNameLabel.text = state
        countryNameLabel.text = country
        
        currentCountryCode = countryCode.lowercased()
        
        // MARK: View -> ViewModel : perform API call to generate articles
        apiComminicator.sendGetRequest(endPoint: Constants.END_POINT_TOP_HEADLINES, queries: [Constants.NEWSAPI_COUNTRY_PARAM_KEY: currentCountryCode])
    }
    
    // MARK: Data Binding Delegate Functions - MVVM
    // got notified from NetworkingViewModel that new business model is ready to be displayed
    func didUpdateArticles(withArticles: ArticlesToDisplay) {
        articles = withArticles.list
        DispatchQueue.main.async {
            self.articlesTV.reloadData()
        }
    }
    
    // got notified from NetworkingViewModel that fetching articles from newsAPI failed for given reason(error)
    func didFailUpdateArticles(withError: Error) {
        switch withError as? NetworkingManager.APIRequestError {
        case .dataNotFound: // inform user
            JKAlert.showOK(title: Constants.AlertMessages.API_CALL_FAIL_TITLE, message: Constants.AlertMessages.API_CALL_FAIL_MESSAGE, on: self)
        default: // got error from server OR .decodingFailed, .keyNotFound, .urlComponentNotFound, .urlUnwrappingFailed
            JKLog.log(message: "\(withError.localizedDescription)")
        }
    }
    
    // got notified from NetworkingViewModel that there's network issue before API call
    func didFailWithReachability() {
        JKAlert.showOK(title: Constants.AlertMessages.NETWORK_REACHABILITY_FAIL_TITLE, message: Constants.AlertMessages.NETWORK_REACHABILITY_FAIL_MESSAGE, on: self)
    }
    
    // MARK: User Action Binding: Refresh
    @IBAction func refreshBarBtnTouched(_ sender: UIBarButtonItem) {
        // MARK: MVVM
        apiComminicator.sendGetRequest(endPoint: Constants.END_POINT_TOP_HEADLINES, queries: [Constants.NEWSAPI_COUNTRY_PARAM_KEY: currentCountryCode, Constants.NEWSAPI_QUERY_PARAM_KEY: keywordTF.text ?? ""])
    }
    
    // MARK: User Action Binding: Search
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // MARK: MVVM
        // Empty input will fetch all articles for given country code
        apiComminicator.sendGetRequest(endPoint: Constants.END_POINT_TOP_HEADLINES, queries: [Constants.NEWSAPI_COUNTRY_PARAM_KEY: currentCountryCode, Constants.NEWSAPI_QUERY_PARAM_KEY: textField.text ?? ""])
        
        textField.resignFirstResponder()
        return true
    }
}


// MARK: TableView Delegate & DataSource
extension LocationDisplayVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.ARTICLE_CELL) as! ArticleCell
        let targetArticle = articles[indexPath.row]

        cell.sourceName.text = targetArticle.sourceName
        cell.title.text = targetArticle.title
        
        // Load image data if available
        if let imageData = targetArticle.imageData {
            cell.imageView?.image = UIImage(data: imageData)
            // MARK: Save first 10 images in document directory if needed
            if indexPath.row < 10 {
                JKLog.log(message: "Saving image file...")
                // Check # of files in doc dir and remove file if needed
                FileDataManager.removeOldestFileIfCountExceeds()
                
                // Save image in document directory
                apiComminicator.saveImage(for: targetArticle.author, publishedAt: targetArticle.publishedAt, withExtension: Constants.IMAGE_EXTENSION, imageData: imageData)

            } // end of saving images
        } else {
            cell.imageView?.image = UIImage(systemName: Constants.Assets.DEFAULT_SYSTEM_IMAGE) // default image for case of no image fetched from API
        }
        
        cell.author.text = targetArticle.author
        cell.descriptionTextView.text = targetArticle.description
        cell.publishDate.text = targetArticle.publishedAt
        return cell
 
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        // Perform segue to load url in webview
        targetUrlStr = articles[indexPath.row].url
        
        // Present VC to load url in webview
        let storyboard = UIStoryboard(name: Constants.Identifiers.MAIN_STORYBOARD, bundle: nil)
        let destinationVC = storyboard.instantiateViewController(identifier: Constants.Identifiers.LOAD_URL_VC) as! LoadUrlVC
        destinationVC.targetUrlStr = targetUrlStr
        present(destinationVC, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
