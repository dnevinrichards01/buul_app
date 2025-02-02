//
//  ServerCommunicator.swift
//  SamplePlaidClient
//
//  Created by Todd Kerpelman on 8/18/23.
//

import Foundation

///
/// Just a helper class that simplifies some of the work involved in calling our server
///
class ServerCommunicator {
    
    private let baseURL: String

    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }

    enum Error: LocalizedError {
        case invalidUrl
        case networkError
        case statusCodeError
        case invalidResponseError
        case encodingError
        case decodingError
        case nilData

        var errorMessage: String {
            switch self {
            case .invalidUrl: return "Invalid URL"
            case .networkError: return "Network Error"
            case .statusCodeError: return "Status Code"
            case .invalidResponseError: return "Invalid Response"
            case .encodingError: return "Encoding Error"
            case .decodingError: return "Decoding Error"
            case .nilData: return "Server return null data"
            }
        }
    }


    init(baseURL: String = "https://localhost:8000/") {
        self.baseURL = baseURL
    }

    func callMyServer<T: Decodable>(
        path: String,
        httpMethod: HTTPMethod,
        params: [String: Any]? = nil,
        responseType: T.Type
    ) throws -> T {

        let path = path.hasPrefix("/") ? String(path.dropFirst()) : path
        let urlString = baseURL + path

        guard let url = URL(string: urlString) else {
            throw Error.invalidUrl
        }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 3

        switch httpMethod {
        case .post where params != nil:
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: params!, options: [])
                request.httpBody = jsonData
            } catch {
                throw Error.encodingError
            }
        default:
            break
        }

            // Create the task
        let semaphore = DispatchSemaphore(value: 0)
        var dataFinal: T?
        var errorFinal: Error?
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let response = response as? HTTPURLResponse else {
                errorFinal = Error.invalidResponseError
                semaphore.signal()
                return
            }
            if !(200...299).contains(response.statusCode) {
                errorFinal = Error.statusCodeError
                semaphore.signal()
                return
            }
            
            guard let data = data else {
                errorFinal = Error.nilData
                semaphore.signal()
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                dataFinal = try decoder.decode(T.self, from: data)
                semaphore.signal()
                return
            } catch {
                errorFinal = Error.decodingError
                semaphore.signal()
                return
            }
        }
        task.resume()
        semaphore.wait()
        
        if let errorFinal = errorFinal {
            throw errorFinal
        }
        if let dataFinal = dataFinal {
            return dataFinal
        } else {
            throw Error.nilData
        }
    }
}
        
        // "try" bc this method throws an error
        // try? would return nil, try! would cause a crash. both avoid do-catch
            
            
//        No internet connection (NSURLErrorNotConnectedToInternet)
//        Timeout (NSURLErrorTimedOut)
//        Network unreachable (NSURLErrorNetworkConnectionLost)
//        Invalid URL (NSURLErrorUnsupportedURL)
//        SSL errors (NSURLErrorSecureConnectionFailed)
        
        

