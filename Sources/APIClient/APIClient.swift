import Foundation

protocol APIClientProtocol {
    
    var baseUrl: String { get }
    var session: URLSession { get }
    
    func fetch<T: Codable>(type: T.Type, endpoint: EndPointProtocol) async throws -> T
}

final class DefaultAPIClient: APIClientProtocol {
    
    internal let baseUrl: String
    internal let session: URLSession
    
    init(
        baseUrl: String,
        session: URLSession
    ) {
        self.baseUrl = baseUrl
        self.session = session
    }
    
    func fetch<T: Codable>(
        type: T.Type,
        endpoint: EndPointProtocol
    ) async throws -> T {
        guard let url = URL(string: baseUrl.appending(endpoint.urlSuffix))
        else { throw APIError.invalidConfiguration }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        request.httpMethod = endpoint.httpMethod
        
        let (data, response) = try await session.dataTaskWithURL(request)
        
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
}
