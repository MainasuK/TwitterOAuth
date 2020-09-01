//
//  TwitterOAuthController.swift
//  
//
//  Created by Cirno MainasuK on 2020-9-1.
//

import Fluent
import Vapor

struct TwitterOAuthController: RouteCollection {
    
    static let consumerKey: String = {
        guard let key = Environment.process.CONSUMER_KEY else {
            fatalError("CONSUMER_KEY not set in environment")
        }
        return key
    }()
    
    static let consumerSecret: String = {
        guard let key = Environment.process.CONSUMER_SECRET_KEY else {
            fatalError("CONSUMER_KEY not set in environment")
        }
        return key
    }()
    
    static let requestTokenURL = URL(string: "https://api.twitter.com/oauth/request_token")!
    static let authorizeURL = URL(string: "https://api.twitter.com/oauth/authorize")!
    static let accessTokenURL = URL(string: "https://api.twitter.com/oauth/access_token")!
    static let callbackURL = URL(string: "https://twitter.mainasuk.com/oauth/callback")!
    
    func boot(routes: RoutesBuilder) throws {
        let grouped = routes.grouped("oauth")
        grouped.get(use: oauth)
        grouped.get("callback", use: callback)
    }
    
    func oauth(req: Request) throws -> EventLoopFuture<Response> {
        let requestURL = TwitterOAuthController.requestTokenURL
        let headers: HTTPHeaders = {
            var headers = HTTPHeaders()
            let authorizationHeader = TwitterOAuthController.authorizationHeader(
                requestURL: requestURL,
                callbackURL: TwitterOAuthController.callbackURL,
                consumerKey: TwitterOAuthController.consumerKey,
                consumerSecret: TwitterOAuthController.consumerSecret,
                oauthToken: nil,
                oauthTokenSecret: nil
            )
            headers.add(name: "Authorization", value: authorizationHeader)
            return headers
        }()
        
        let uri = URI(string: requestURL.absoluteString + "?oauth_callback=\(TwitterOAuthController.callbackURL.absoluteString.urlEncoded)")
        return req.client
            .post(uri, headers: headers) { request in
                request.headers.contentType = .urlEncodedForm
                print(request)
            }
            .flatMapThrowing { response  in
                print(response)
                guard response.status == .ok else {
                    throw Abort(.badRequest, reason: "Twitter OAuth request token request failed.")
                }
                
                do {
                    let bodyContent = response.body.flatMap {
                        $0.getString(at: $0.readerIndex, length: $0.readableBytes)
                    } ?? ""
                    let requestToken = try URLEncodedFormDecoder().decode(RequestToken.self, from: bodyContent)
                    var urlComponents = URLComponents(string: "https://api.twitter.com/oauth/authorize")!
                    urlComponents.queryItems = [
                        URLQueryItem(name: "oauth_token", value: requestToken.oauthToken),
                    ]
                    return req.redirect(to: urlComponents.url!.absoluteString)
                    
                } catch {
                    throw Abort(.badRequest, reason: "Twitter OAuth request token response decode failed. \(error.localizedDescription)")
                }
            }
    }
    
    func callback(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        print(req.content)
        return req.eventLoop.future(.ok)
    }
    
}

extension TwitterOAuthController {
    struct RequestTokenParameter: Codable {
        let oauthCallback: String
        
        enum CodingKeys: String, CodingKey {
            case oauthCallback = "oauth_callback"
        }
    }
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
    private static func authorizationHeader(requestURL url: URL, callbackURL: URL, consumerKey: String, consumerSecret: String, oauthToken: String?, oauthTokenSecret: String?) -> String {
        var authorizationParameters = Dictionary<String, String>()
        authorizationParameters["oauth_version"] = "1.0"
        authorizationParameters["oauth_callback"] = callbackURL.absoluteString
        authorizationParameters["oauth_consumer_key"] = consumerKey
        authorizationParameters["oauth_signature_method"] = "HMAC-SHA1"
        authorizationParameters["oauth_timestamp"] = String(Int(Date().timeIntervalSince1970))
        authorizationParameters["oauth_nonce"] = UUID().uuidString
        
        authorizationParameters["oauth_token"] = oauthToken
        
        authorizationParameters["oauth_signature"] = oauthSignature(requestURL: url, consumerSecret: consumerSecret, parameters: authorizationParameters, oauthTokenSecret: oauthTokenSecret)
        
        
        var parameterComponents = authorizationParameters.urlEncodedQuery.components(separatedBy: "&") as [String]
        parameterComponents.sort { $0 < $1 }
        
        var headerComponents = [String]()
        for component in parameterComponents {
            let subcomponent = component.components(separatedBy: "=") as [String]
            if subcomponent.count == 2 {
                headerComponents.append("\(subcomponent[0])=\"\(subcomponent[1])\"")
            }
        }
        
        return "OAuth " + headerComponents.joined(separator: ", ")
    }
    
    private static func oauthSignature(requestURL url: URL, consumerSecret: String, parameters: Dictionary<String, String>, oauthTokenSecret: String?) -> String {
        let encodedConsumerSecret = consumerSecret.urlEncoded
        let encodedTokenSecret = oauthTokenSecret?.urlEncoded ?? ""
        let signingKey = "\(encodedConsumerSecret)&\(encodedTokenSecret)"
        
        var parameterComponents = parameters.urlEncodedQuery.components(separatedBy: "&")
        parameterComponents.sort {
            let p0 = $0.components(separatedBy: "=")
            let p1 = $1.components(separatedBy: "=")
            if p0.first == p1.first { return p0.last ?? "" < p1.last ?? "" }
            return p0.first ?? "" < p1.first ?? ""
        }
        
        let parameterString = parameterComponents.joined(separator: "&")
        let encodedParameterString = parameterString.urlEncoded
        
        let encodedURL = url.absoluteString.urlEncoded
        
        let signatureBaseString = "POST&\(encodedURL)&\(encodedParameterString)"
        
        let key = signingKey.data(using: .utf8)!
        let msg = signatureBaseString.data(using: .utf8)!
        
        let sha1 = HMAC.sha1(key: key, message: msg)!
        return sha1.base64EncodedString(options: [])
    }
}
