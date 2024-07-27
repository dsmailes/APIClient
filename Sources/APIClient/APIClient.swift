import Foundation
import RxSwift

public protocol APIClientProtocol {
    
    var baseUrl: String { get }
    var client: AuthenticationClientProtocol { get }
    var session: URLSession { get }
    
    func fetch<T: Codable>(type: T.Type, endpoint: EndPointProtocol) async throws -> T
    func fetch<T: Codable>(type: T.Type, endpoint: EndPointProtocol) -> Observable<T>
}

extension APIClientProtocol {
    
    public func fetch<T: Codable>(
        type: T.Type,
        endpoint: EndPointProtocol
    ) async throws -> T {
        guard let url = URL(string: baseUrl.appending(endpoint.urlSuffix))
        else { throw APIError.invalidConfiguration }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        request.httpMethod = endpoint.httpMethod
        
        let authenticatedRequest = try client.authenticateRequest(request)
        
        let (data, response) = try await session.dataTaskWithURL(authenticatedRequest)
        
        guard let httpResponse = response as? HTTPURLResponse
        else { throw APIError.requestFailed(description: "Invalid response.") }
        
        guard 200..<300 ~= httpResponse.statusCode
        else { throw APIError.requestFailed(description: "Failed with status \(httpResponse.statusCode)") }
        
        if let data {
           return try JSONDecoder().decode(T.self, from : data)
        } else {
            throw APIError.decodingFailure
        }
    }
    
    public func fetch<T: Codable>(type: T.Type, endpoint: EndPointProtocol) -> Observable<T> {
        return Observable<T>.create { observer in
            
            guard let url = URL(string: baseUrl.appending(endpoint.urlSuffix)) else {
                observer.onError(APIError.invalidConfiguration)
                return Disposables.create()
            }
            
            var request = URLRequest(url: url)
            request.timeoutInterval = 15
            request.httpMethod = endpoint.httpMethod
            
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
