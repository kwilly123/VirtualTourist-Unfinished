//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Kyle Wilson on 2020-03-11.
//  Copyright © 2020 Xcode Tips. All rights reserved.
//

import Foundation
import UIKit

class FlickrClient {
    
    enum Endpoints {
        static let flickrAPIKey = "aed2488cdf52eca5a0537d095675300f"
        static let flickrAPISecret = "9cc6ccddbc853415"
        static let baseURL = "https://www.flickr.com/services/rest/?method=flickr.photos.search"
        static let searchMethod = "flickr.photos.search"
        static let numOfPhotos = 20
        case searchURL(Double, Double, Int, Int)
        
        var urlString: String {
            switch self {
            case .searchURL(let lat, let lon, let perPage, let pageNum):
                return Endpoints.baseURL + "&api_key=\(Endpoints.flickrAPIKey)" + "&lat=\(lat)" + "&lon=\(lon)" + "&radius=\(Endpoints.numOfPhotos)" + "&per_page=\(perPage)" + "&page=\(pageNum)" + "&format=json&nojsoncallback=1&extras=url_m"
                
            }
        }
        
        var url: URL {
            return URL(string: urlString)!
        }
    }
    
    class func getRandomPageNumber(totalPictures: Int, picturesDisplayed: Int) -> Int {
        let flickrLimit = 4000
        let numberOfPages = min(totalPictures, flickrLimit) / picturesDisplayed
        let randomPageNumber = Int.random(in: 0...numberOfPages)
        return randomPageNumber
    }
    
    class func getFlickrURL(latitude: Double, longitude: Double, totalPages: Int = 0, picturesPerPage: Int = 15) -> URL {
        let perPage = picturesPerPage
        let pageNum = getRandomPageNumber(totalPictures: totalPages, picturesDisplayed: picturesPerPage)
        let searchURL = Endpoints.searchURL(latitude, longitude, perPage, pageNum).url
        return searchURL
    }
    
    class func searchPhotos(lat: Double, lon: Double, totalPageAmt: Int = 0, completion: @escaping ([PhotoStruct], Int, Error?) -> Void) {
        let url = getFlickrURL(latitude: lat, longitude: lon, totalPages: totalPageAmt)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if error != nil {
                completion([], 0, error)
                print(error?.localizedDescription ?? "error")
                return
            }
            
            guard let data = data else {
                completion([], 0, nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(PhotoResponse.self, from: data)
                print(response)
                completion(response.photos.photo, response.photos.pages, nil)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    class func downloadImage(imageURL: String, completion: @escaping (Data?, Error?) -> Void) {
        let url = URL(string: imageURL)
        guard let imageURL = url else {
            completion(nil, nil)
            return
        }
        let request = URLRequest(url: imageURL)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                completion(data, nil)
            }
        }
        task.resume()
    }
}
