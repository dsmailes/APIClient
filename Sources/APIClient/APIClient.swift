import Foundation
import RxSwift

public protocol APIClientProtocol {
    
    var baseUrl: String { get }
    var client: AuthenticationClientProtocol { get }
    var session: URLSession { get }
    
    func fetch<T: Codable>(type: T.Type, endpoint: EndPointProtocol) async throws -> T
    func fetch<T: Codable>(type: T.Type, endpoint: EndPointProtocol) -> Single<T>
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
    
    public func fetch<T: Codable>(type: T.Type, endpoint: EndPointProtocol) -> Single<T> {
        return Single<T>.create { single in
            guard let url = URL(string: baseUrl.appending(endpoint.urlSuffix)) else {
                single(.failure(APIError.invalidConfiguration))
                return Disposables.create()
            }
            
            var request = URLRequest(url: url)
            request.timeoutInterval = 15
            request.httpMethod = endpoint.httpMethod
            
            do {
                let authenticatedRequest = try client.authenticateRequest(request)
                
                let task = URLSession.shared.dataTask(with: authenticatedRequest) { data, response, error in
                    if let error = error {
                        single(.failure(error))
                    } else if let data = data, 
                              let response = response as? HTTPURLResponse, 
                              200..<300 ~= response.statusCode {
                        do {
                            let model = try JSONDecoder().decode(T.self, from: data)
                            single(.success(model))
                        } catch {
                            single(.failure(APIError.decodingFailure))
                        }
                    } else {
                        single(.failure(APIError.requestFailed(description: "Invalid response.")))
                    }
                }
                
                task.resume()
                
                return Disposables.create {
                    task.cancel()
                }
            } catch {
                single(.failure(error))
                return Disposables.create()
            }
        }
    }
}
