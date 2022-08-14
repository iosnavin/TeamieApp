//
//  WikiHttpHelper.swift
//  SampleApp
//
//  Created by Naveen Reddy R on 14/08/22.
//

import Foundation

class WikiHelper {
    func fetchRandomContent(_ completion: @escaping (String, Error?) -> Void) {
        let url = URL(string:"https://en.wikipedia.org/w/api.php?format=json&action=query&generator=random&grnnamespace=0&prop=extracts&explaintext=")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if error == nil {
                if let dataRecieved = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: dataRecieved, options: .fragmentsAllowed) as? [String: Any]
                        if let hasQuery =  json?.keys.contains("query"),
                           let query = json?["query"] as? [String: Any] {
                            if  query.keys.contains("pages"){
                                if let pages = query["pages"] as? [String:Any],
                                   let firstPageKey = pages.keys.first,
                                   let firstPage = pages[firstPageKey]  as? [String: Any] {
                                    if firstPage.keys.contains("extract") {
                                        guard let content = firstPage["extract"] as? String else {return}
                                        print(firstPage["extract"])
                                        completion(content, nil)
                                    }
                                }
                            }
                        }
                    } catch (let error) {
                        print(error)
                        completion("", error)
                    }
                }
            }
        }.resume()
    }
}
