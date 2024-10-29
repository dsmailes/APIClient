import Foundation

import Foundation

public protocol APIClientProtocol {
    var baseUrl: String { get }
    var client: AuthenticationClientProtocol { get }
    var session: URLSession { get }
    
    func fetch<T: Codable>(type: T.Type, endpoint: EndPointProtocol) async throws -> T
}

extension APIClientProtocol {
    public func fetch<T: Decodable>(type: T.Type, endpoint: EndPointProtocol) async throws -> T {
        guard var urlComponents = URLComponents(string: baseUrl.appending(endpoint.urlSuffix)) else {
            throw APIError.invalidConfiguration
        }
        
        if let queryItems = endpoint.queryItems {
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            throw APIError.invalidConfiguration
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        request.httpMethod = endpoint.httpMethod
        
        if let body = endpoint.body {
            let jsonData = try JSONEncoder().encode(body)
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let authenticatedRequest = try client.authenticateRequest(request)
        
        let (data, response) = try await session.data(for: authenticatedRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.requestFailed(description: "Invalid response.")
        }
        
        guard 200..<300 ~= httpResponse.statusCode else {
            throw APIError.requestFailed(description: "Failed with status \(httpResponse.statusCode)")
        }
        
        do {
            let model = try JSONDecoder().decode(T.self, from: data)
            return model
        } catch {
            throw APIError.decodingFailure
        }
    }
}
