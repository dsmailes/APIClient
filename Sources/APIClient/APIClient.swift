import Foundation

import Foundation

public protocol APIClientProtocol {
    var baseUrl: String { get }
    var session: URLSession { get }
    
    func fetch<T: Codable>(type: T.Type, endpoint: EndPointProtocol) async throws -> T
}

open class APIClient: APIClientProtocol {
    public var baseUrl: String
    public var session: URLSession
    
    public init(baseUrl: String, session: URLSession = .shared) {
        self.baseUrl = baseUrl
        self.session = session
    }
    
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
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.requestFailed(description: "Invalid HTTP response.")
        }
        
        guard 200..<300 ~= httpResponse.statusCode else {
            throw APIError.requestFailed(description: "Request failed with status \(httpResponse.statusCode)")
        }
        
        do {
            let model = try JSONDecoder().decode(T.self, from: data)
            return model
        } catch {
            throw APIError.decodingFailure(description: "Decoding failed with error \(error.localizedDescription)")
        }
    }
}
