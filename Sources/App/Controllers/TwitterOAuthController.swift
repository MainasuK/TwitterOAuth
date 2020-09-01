//
//  TwitterOAuthController.swift
//  
//
//  Created by Cirno MainasuK on 2020-9-1.
//

import Fluent
import Vapor

struct TwitterOAuthController: RouteCollection {
    
    let consumerKey: String? = Environment.process.CONSUMER_KEY
    let consumerSecret: String? = Environment.process.CONSUMER_SECRET_KEY
    
    func boot(routes: RoutesBuilder) throws {
        let grouped = routes.grouped("oauth")
        grouped.get(use: oauth)
        grouped.get("callback", use: callback)
    }
    
    func oauth(req: Request) throws -> EventLoopFuture<Response> {
        let consumerKey = self.consumerKey ?? ""
        let consumerSecret = self.consumerSecret ?? ""
        let callbackURL = URL(string: "https://twitter.mainasuk.com/oauth/callback")!
        
        let headers: HTTPHeaders = {
            var headers = HTTPHeaders()
            headers.add(name: .authorization, value: TwitterOAuthController.authorizationHeader(consumerKey: consumerKey, consumerSecret: consumerSecret, callbackURL: callbackURL))
            return headers
        }()
        
        return req.client
            .post("https://api.twitter.com/oauth/request_token", headers: headers)
            .flatMapThrowing { response  in
                guard response.status == .ok else {
                    throw Abort(.badRequest, reason: "Twitter OAuth request token request failed.")
                }
                
                guard let requestToken = try? response.content.decode(RequestToken.self) else {
                    throw Abort(.badRequest, reason: "Twitter OAuth request token response decode failed.")
                }

                var urlComponents = URLComponents(string: "https://api.twitter.com/oauth/authorize")!
                urlComponents.queryItems = [
                    URLQueryItem(name: "oauth_token", value: requestToken.oauthToken),
                ]
                return req.redirect(to: urlComponents.url!.absoluteString)
            }
    }
    
    func callback(req: Request) throws -> EventLoopFuture<Response> {
        print(req.content)
        return req.eventLoop.future(Response())
    }
    
}

extension TwitterOAuthController {
    struct RequestToken: Codable {
        let oauthToken: String
        let oauthTokenSecret: String
        let oauthCallbackConfirmed: Bool
        
        enum CodingKeys: String, CodingKey {
            case oauthToken = "oauth_token"
            case oauthTokenSecret = "oauth_token_secret"
            case oauthCallbackConfirmed = "oauth_callback_confirmed"
        }
    }
}

extension TwitterOAuthController {
    private static func authorizationHeader(consumerKey: String, consumerSecret: String, callbackURL: URL, oauthToken: String? = nil) -> String {
        var authorizationParameters = Dictionary<String, String>()
        authorizationParameters["oauth_callback"] = "oob"
        authorizationParameters["oauth_version"] = "1.0"
        authorizationParameters["oauth_signature_method"] = "HMAC-SHA1"
        authorizationParameters["oauth_consumer_key"] = consumerKey
        authorizationParameters["oauth_timestamp"] = String(Int(Date().timeIntervalSince1970))
        authorizationParameters["oauth_nonce"] = UUID().uuidString
        
        if let oauth_token = oauthToken {
            authorizationParameters["oauth_token"] = oauth_token
        }
        
        authorizationParameters["oauth_signature"] = self.oauthSignature(callbackURL: callbackURL, consumerSecret: consumerSecret, parameters: authorizationParameters)
        
        let authorizationParameterComponents = authorizationParameters.urlEncodedQueryString(using: .utf8).components(separatedBy: "&").sorted()
        
        var headerComponents = [String]()
        for component in authorizationParameterComponents {
            let subcomponent = component.components(separatedBy: "=")
            if subcomponent.count == 2 {
                headerComponents.append("\(subcomponent[0])=\"\(subcomponent[1])\"")
            }
        }
        
        return "OAuth " + headerComponents.joined(separator: ", ")
    }
    
    private static func oauthSignature(callbackURL: URL, consumerSecret: String, parameters: Dictionary<String, String>) -> String {
        let tokenSecret = ""    // accessTokenSecret
        let encodedConsumerSecret = consumerSecret.urlEncodedString()
        let signingKey = "\(encodedConsumerSecret)&\(tokenSecret)"
        let parameterComponents = parameters.urlEncodedQueryString(using: .utf8).components(separatedBy: "&").sorted()
        let parameterString = parameterComponents.joined(separator: "&")
        let encodedParameterString = parameterString.urlEncodedString()
        let encodedURL = callbackURL.absoluteString.urlEncodedString()
        let signatureBaseString = "POST&\(encodedURL)&\(encodedParameterString)"
        
        let key = signingKey.data(using: .utf8)!
        let msg = signatureBaseString.data(using: .utf8)!
        let sha1 = HMAC.sha1(key: key, message: msg)!
        return sha1.base64EncodedString(options: [])
    }
}
