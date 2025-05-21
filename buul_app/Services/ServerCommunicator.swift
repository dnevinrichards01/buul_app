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
    
    let baseURL: String

    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
    }

    enum NetworkError: LocalizedError {
        case invalidUrl
        case networkError
        case statusCodeError(Int)
        case invalidResponseError
        case encodingError
        case decodingError
        case nilData
        case refreshError

        var errorMessage: String {
            switch self {
            case .invalidUrl: return "Invalid URL. Please try again or contact Buul."
            case .networkError: return "Network Error. Please try again later, check your internet connection, or contact Buul."
            case .statusCodeError(let status): return "Internal server error \(status). Please try again or contact Buul."
            case .invalidResponseError: return "Invalid server response. Please try again later, check your internet connection, or contact Buul."
            case .encodingError: return "We couldn't encode your web request. Please check your inputs or contact Buul."
            case .decodingError: return "Invalid server response format. Please try again or contact Buul."
            case .nilData: return "Server returned no data. Please try again or contact Buul."
            case .refreshError: return "Your session has timed out and we were unable to renew it. "
            }
        }
    }


    init(baseURL: String = "https://shad-enormous-skink.ngrok-free.app/" ) { //"http://localhost:8000/", "http://10.0.0.206:8000/", "https://prod.buul-load-balancer.link/" "https://shad-enormous-skink.ngrok-free.app/"
        self.baseURL = baseURL
    }
    

    func callMyServer<T: Decodable>(
        path: String,
        httpMethod: HTTPMethod,
        params: [String: Any]? = nil,
        sessionManager: UserSessionManager? = nil,
        responseType: T.Type,
        tryRefresh: Bool = true,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        print("params", params as Any)
        guard let url = URL(string: baseURL + path) else {
            completion(.failure(.invalidUrl))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let accessToken = sessionManager?.accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
//        maybe add the host field here, and make sure it matches server_name in nginx
        request.timeoutInterval = 3

        if let params = params {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: params, options: [])
                request.httpBody = jsonData
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.encodingError))
                }
                return
            }
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            Task {
                
                if let data = data, let body = String(data: data, encoding: .utf8) {
                    print("unprocessed body", body)
                }
                // need to let users log out in sign up flow if errors happening befpre status code guard block
                
                if error != nil {
                    print(error?.localizedDescription as Any)
                    DispatchQueue.main.async {
                        completion(.failure(.networkError))
                    }
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        completion(.failure(.invalidResponseError))
                    }
                    return
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    if let sessionManager = sessionManager, httpResponse.statusCode == 401 {
                        if tryRefresh {
                            print("refresh")
                            self.refresh(
                                sessionManager: sessionManager,
                                path: path,
                                httpMethod: httpMethod,
                                params: params,
                                responseType: responseType,
                                tryRefresh: false,
                                completion: completion
                            )
                            return
                        } else {
                            sessionManager.refreshFailedMessage = "Your session has timed out. To update or get new information, please log out and sign back in."
                            sessionManager.refreshFailed = true
                        }
                    }
                    DispatchQueue.main.async {
                        completion(.failure(.statusCodeError(httpResponse.statusCode)))
                    }
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(.nilData))}
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decodedResponse = try decoder.decode(T.self, from: data)
//                    print(decodedResponse)
                    DispatchQueue.main.async {
                        completion(.success(decodedResponse))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.decodingError))
                    }
                }
            }
        }
        
        task.resume()
    }
    
    
    func refresh<T: Decodable>(
        sessionManager: UserSessionManager,
        refreshRetries: Int = 2,
        path: String,
        httpMethod: HTTPMethod,
        params: [String: Any]? = nil,
        responseType: T.Type,
        tryRefresh: Bool,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard let url = URL(string: baseURL + "api/token/refresh/") else {
            sessionManager.refreshFailed = true
            sessionManager.refreshFailedMessage = "Your session has timed out and due to an internal error we could not refresh your session. To update or get new information, please log out and sign back in."
            completion(.failure(.invalidUrl))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
//        print("refresh HTTP method: ", HTTPMethod.post.rawValue, request.httpMethod)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 3
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ["refresh": sessionManager.refreshToken], options: [])
            request.httpBody = jsonData
        } catch {
            sessionManager.refreshFailed = true
            sessionManager.refreshFailedMessage = "Your session has timed out and due to an internal error we could not refresh your session. To update or get new information, please log out and sign back in."
            completion(.failure(.encodingError))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            Task {
                
                if let data = data, let body = String(data: data, encoding: .utf8) {
                    print(body)
                }
                
                if error != nil {
                    print(error?.localizedDescription as Any)
                    DispatchQueue.main.async {
                        sessionManager.refreshFailed = true
                        sessionManager.refreshFailedMessage = "Your session has timed out and due to a connection error we not refresh your session. To update or get new information, please check your internet connection or log out and sign back in."
                        completion(.failure(.networkError))
                    }
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        sessionManager.refreshFailed = true
                        sessionManager.refreshFailedMessage = "Your session has timed out and due to an invalid server response we could not refresh your session. To update or get new information, please log out and sign back in."
                        completion(.failure(.invalidResponseError))
                    }
                    return
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    if refreshRetries > 0 {
                        print("refresh retry")
                        self.refresh(
                            sessionManager: sessionManager,
                            refreshRetries: refreshRetries - 1,
                            path: path,
                            httpMethod: httpMethod,
                            params: params,
                            responseType: responseType,
                            tryRefresh: false,
                            completion: completion
                        )
                    } else {
                        DispatchQueue.main.async {
                            sessionManager.refreshFailed = true
                            sessionManager.refreshFailedMessage = "Your session has timed out. To update or get new information, please log out and sign back in."
                            completion(.failure(.statusCodeError(httpResponse.statusCode)))
                        }
                    }
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        sessionManager.refreshFailed = true
                        sessionManager.refreshFailedMessage = "Your session has timed out and due to an empty server response we could refresh your session. To update or get new information, please log out and sign back in."
                        completion(.failure(.nilData))
                    }
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decodedResponse = try decoder.decode(LoginResponse.self, from: data)
                    print(decodedResponse)
                    DispatchQueue.main.async {
//                        print("refresh complete", "sessionManager.refreshToken", "sessionManager.accessToken")
                        sessionManager.refreshFailed = false
                        sessionManager.refreshFailedMessage = ""
                        sessionManager.refreshToken = decodedResponse.refresh
                        sessionManager.accessToken = decodedResponse.access
                        print("Refresh: ", decodedResponse.refresh, sessionManager.refreshToken)
                        print("refresh failed?: ", sessionManager.refreshFailed)
                        
                        self.callMyServer(
                            path: path,
                            httpMethod: httpMethod,
                            params: params,
                            sessionManager: sessionManager,
                            responseType: responseType,
                            tryRefresh: false,
                            completion: completion
                        )
                    }
                    
                } catch {
                    DispatchQueue.main.async {
                        sessionManager.refreshFailed = true
                        sessionManager.refreshFailedMessage = "Your session has timed out. To update or get new information, please log out and sign back in."
                        completion(.failure(.decodingError))
                        return
                    }
                }
            }
        }
        
        task.resume()
    }
}
