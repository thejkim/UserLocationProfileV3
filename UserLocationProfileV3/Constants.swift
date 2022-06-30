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
}
