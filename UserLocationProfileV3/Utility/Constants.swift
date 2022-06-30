//
//  Constants.swift
//  NewsAPIRequest
//
//  Created by Jo Eun Kim on 6/13/22.
//

import Foundation

struct Constants {
    static let KEY_PLIST_NAME = "Key"
    static let API_KEY = "api_key"
    static let NEWSAPI_BASEURL = "https://newsapi.org"
    static let END_POINT_TOP_HEADLINES = "/v2/top-headlines"
    static let NEWSAPI_TOP_HEADLINES = NEWSAPI_BASEURL + END_POINT_TOP_HEADLINES
    static let NEWSAPI_COUNTRY_PARAM_KEY = "country"
    static let NEWSAPI_QUERY_PARAM_KEY = "q"
    static let NEWSAPI_APIKEY_KEY = "apiKey"
    static let IMAGE_EXTENSION = "png"
    
    struct Identifiers {
        static let LOCATION_SERVICE_AUTH_VC = "LocationServiceAuthorizationVC"
        static let ARTICLE_CELL = "ArticleCell"
        static let LOAD_URL_VC = "LoadUrlVC"
        static let MAIN_STORYBOARD = "Main"
    }
    
    struct Assets {
        static let DEFAULT_SYSTEM_IMAGE = "photo"
    }
    
    struct AlertMessages {
        static let USER_REGISTER_FAIL_TITLE = "Register Failed"
        static let USER_REGISTER_FAIL_MESSAGE = "Please enter username."
        
        static let LOCATION_SERVICE_DISABLED_TITLE = "Location Service Disabled"
        static let LOCATION_SERVICE_DISABLED_MESSAGE = "Location service is disabled. Please go to Settings, enabled the location service to allow the app access to your current location."
        static let LOCATION_SERVICE_NOT_AUTH_TITLE = "App Not Authorized"
        static let LOCATION_SERVICE_NOT_AUTH_MESSAGE = "We are not authorized to access your location information. Please go to App Settings, enabled the location service of the app to give access to your current location."
        
        static let API_CALL_FAIL_TITLE = "Articles Not Available"
        static let API_CALL_FAIL_MESSAGE = "We cannot find articles at the moment. Please try again by tapping \"Refresh\" button on the top-right corner."
        
        static let NETWORK_REACHABILITY_FAIL_TITLE = "Network Unreachable"
        static let NETWORK_REACHABILITY_FAIL_MESSAGE = "We cannot reach out the API service"
        
        
    }
}
