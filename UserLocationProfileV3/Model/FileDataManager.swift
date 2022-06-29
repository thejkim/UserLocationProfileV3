//
//  FileManager.swift
//  UserLocationProfileV3
//
//  Created by Jo Eun Kim on 6/26/22.
//

import Foundation

class FileDataManager {
//    static let shared = FileDataManager()
//    private init() {
//
//    }
    
    static func getAPIKey() -> String? {
        if let path = Bundle.main.path(forResource: Constants.KEY_PLIST_NAME, ofType: "plist") {
            if let dic = NSDictionary(contentsOfFile: path) as? Dictionary<String, String> {
                if let value = dic[Constants.API_KEY] {
                    return value
                }
            }
        }
        return nil
    }
    
    static func updateFilenameToProperFormat(from givenFileName: String) -> String {
        /* When saved, white space will be replaced by %
                       :                            by /
         */
        
        // MARK: Handling the special character cases for file name
        var titleSavingFormat = givenFileName.replacingOccurrences(of: " ", with: "")
        titleSavingFormat = titleSavingFormat.replacingOccurrences(of: ":", with: "")
        
        return titleSavingFormat
    }
    
    // TODO: modify param to get full file name and extension (.extension) for better reusability - DONE
    static func checkIfFileExists(for title: String, publishedAt: String, withExtension: String) -> Bool {
        print("title=\(title)")
        var givenFileName = "\(title)_\(publishedAt).\(withExtension)"
        givenFileName = updateFilenameToProperFormat(from: givenFileName)
        JKLog.log(message: "\(givenFileName)")

        var isFound = false
        JKLog.log(message: "\(Thread.current)")

        if let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first { // go to document directory
            let path = documentURL.appendingPathComponent(givenFileName).path
            
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
    
    static func loadImageIfAvailable(for title: String, publishedAt: String, withExtension: String) -> Data? { // String
        var loadedImageData: Data?
        
        var givenFileName = "\(title)_\(publishedAt).\(withExtension)"
        givenFileName = updateFilenameToProperFormat(from: givenFileName)
        JKLog.log(message: "\(givenFileName)")

        if checkIfFileExists(for: title, publishedAt: publishedAt, withExtension: withExtension) {
            JKLog.log(message: "Loading image from doc dir...")

            if let targetURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(givenFileName) {
                do {
                    loadedImageData = try Data(contentsOf: targetURL)
                } catch {
                    print("Failed to download image data from document directory")
                }
            }
                
        }
        return loadedImageData
    }
    
    static func saveImageFrom(for title: String, publishedAt: String, withExtension: String, url: String) {
        var givenFileName = "\(title)_\(publishedAt).\(withExtension)"
        givenFileName = updateFilenameToProperFormat(from: givenFileName)
        
        // Save image in document directory
        DispatchQueue.global(qos: .background).async {
            if let imageURL = URL(string: url) {
                do {
                    let imageData = try Data(contentsOf: imageURL)
                    if let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        let outputFileURL = documentURL.appendingPathComponent(givenFileName)
                     
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
    
    static func removeOldestFileIfCountExceeds() {
        var oldestFile = ""
        let delimiter = "_"
        var publishedDate = ""
        let username = "test1" // TODO: properly get username
        DispatchQueue.global(qos: .background).async {
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
}
