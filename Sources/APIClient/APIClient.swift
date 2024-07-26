import Foundation

public protocol APIClientProtocol {
    
    var baseUrl: String { get }
    var client: AuthenticationClientProtocol { get }
    var session: URLSession { get }
    
    func fetch<T: Codable>(type: T.Type, endpoint: EndPointProtocol) async throws -> T
}

public final class DefaultAPIClient: APIClientProtocol {
    
    public let baseUrl: String
    public let client: AuthenticationClientProtocol
    public let session: URLSession
    
    public init(
        baseUrl: String,
        client: AuthenticationClientProtocol,
        session: URLSession
    ) {
        self.baseUrl = baseUrl
        self.client = client
        self.session = session
    }
    
    public func fetch<T: Codable>(
        type: T.Type,
        endpoint: EndPointProtocol
    ) async throws -> T {
        guard let url = URL(string: baseUrl.appending(endpoint.urlSuffix))
        else { throw APIError.invalidConfiguration }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        request.httpMethod = endpoint.httpMethod
        
        let authenticatedRequest = try await client.authenticateRequest(request)
        
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
}
