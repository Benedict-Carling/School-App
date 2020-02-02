//
//  APIRequest.swift
//  map2.0
//
//  Created by Benedict on 30/01/2020.
//  Copyright © 2020 Benedict. All rights reserved.
//

import Foundation

enum APIError:Error {
    case responseProblem
    case decodingProblem
    case encodingProblem
}

struct APIRequest {
    let resourceURL: URL
    
    init(endpoint: String) {
        let resourceString = "https://ukschools.guide:4000/\(endpoint)"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        
        self.resourceURL = resourceURL
    }
    
    func getSchools (_ coordinatesToSend: Message, completion: @escaping(Result<[SchoolDetail], APIError>) -> Void ) {
        
        do {
            var urlRequest = URLRequest(url: resourceURL)
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(coordinatesToSend)
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let
                    jsonData = data else {
                    completion(.failure(.responseProblem))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let schoolListResponse = try decoder.decode([SchoolDetail].self, from: jsonData)
                    completion(.success(schoolListResponse))
                }catch{
                    completion(.failure(.decodingProblem))
                }
            }
            dataTask.resume()
        }catch{
            completion(.failure(.encodingProblem))
        }
        
    }
}
