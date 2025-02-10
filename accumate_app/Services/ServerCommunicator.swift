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

    enum NetworkError: LocalizedError {
        case invalidUrl
        case networkError
        case statusCodeError(Int)
        case invalidResponseError
        case encodingError
        case decodingError
        case nilData

        var errorMessage: String {
            switch self {
            case .invalidUrl: return "Invalid URL. Please try again or contact Accumate"
            case .networkError: return "Network Error. Please try again later, check your internet connection, or contact Accumate"
            case .statusCodeError(let status): return "Internal server error \(status). Please try again or contact Accumate"
            case .invalidResponseError: return "Network Error. Please try again later, check your internet connection, or contact Accumate"
            case .encodingError: return "We couldn't encode your web request. Please check your inputs or contact Accumate"
            case .decodingError: return "Invalid server response. Please try again or contact Accumate"
            case .nilData: return "Server returned no data. Please try again or contact Accumate"
            }
        }
    }


    init(baseURL: String = "http://10.0.0.100:8000/") { //"http://localhost:8000/"
        self.baseURL = baseURL
    }

    func callMyServer<T: Decodable>(
        path: String,
        httpMethod: HTTPMethod,
        params: [String: Any]? = nil,
        accessToken: String? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {

        guard let url = URL(string: baseURL + path) else {
            completion(.failure(.invalidUrl))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let accessToken = accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
//        maybe add the host field here, and make sure it matches server_name in nginx
        request.timeoutInterval = 3

        if httpMethod == .post, let params = params {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: params, options: [])
                request.httpBody = jsonData
            } catch {
                completion(.failure(.encodingError))
                return
            }
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                
                if error != nil {
                    completion(.failure(.networkError))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.invalidResponseError))
                    return
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(.statusCodeError(httpResponse.statusCode)))
                    return
                }

                guard let data = data else {
                    completion(.failure(.nilData))
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decodedResponse = try decoder.decode(T.self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    print(data)
                    completion(.failure(.decodingError))
                }
            }
        }
        
        task.resume()
    }
}
