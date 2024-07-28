import Foundation
import RxSwift

public protocol APIClientProtocol {
    
    var baseUrl: String { get }
    var client: AuthenticationClientProtocol { get }
    var session: URLSession { get }
    
    func fetch<T: Codable>(type: T.Type, endpoint: EndPointProtocol) -> Observable<T>
}

extension APIClientProtocol {
        
    public func fetch<T: Codable>(type: T.Type, endpoint: EndPointProtocol) -> Observable<T> {
        return Observable<T>.create { observer in
            
            guard var urlComponents = URLComponents(string: baseUrl.appending(endpoint.urlSuffix)) else {
                observer.onError(APIError.invalidConfiguration)
                return Disposables.create()
            }
                        
            if let queryItems = endpoint.queryItems {
                urlComponents.queryItems = queryItems
            }
            
            guard let url = urlComponents.url else {
                observer.onError(APIError.invalidConfiguration)
                return Disposables.create()
            }
            
            var request = URLRequest(url: url)
            request.timeoutInterval = 15
            request.httpMethod = endpoint.httpMethod
            
            if let body = endpoint.body {
                do {
                    let jsonData = try JSONEncoder().encode(body)
                    request.httpBody = jsonData
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                } catch {
                    observer.onError(APIError.requestFailed(description: "Encoding body failed."))
                    return Disposables.create()
                }
            }
            
            do {
                let authenticatedRequest = try client.authenticateRequest(request)
                
                let task = session.dataTask(with: authenticatedRequest) { data, response, error in
                    
                    guard let httpResponse = response as? HTTPURLResponse
                    else {
                        observer.onError(APIError.requestFailed(description: "Invalid response."))
                        return
                    }
                    
                    guard 200..<300 ~= httpResponse.statusCode
                    else {
                        observer.onError(APIError.requestFailed(description: "Failed with status \(httpResponse.statusCode)"))
                        return
                    }
                    
                    if let error {
                        observer.onError(error)
                    }
                    
                    guard let data
                    else {
                        observer.onError(APIError.requestFailed(description: "Invalid response."))
                        return
                    }
                    
                    do {
                        let model = try JSONDecoder().decode(T.self, from: data)
                        observer.onNext(model)
                    } catch {
                        observer.onError(APIError.decodingFailure)
                    }
                }
                
                task.resume()
                
                return Disposables.create {
                    task.cancel()
                }
            } catch {
                observer.onError(error)
                return Disposables.create()
            }
        }
    }
}
