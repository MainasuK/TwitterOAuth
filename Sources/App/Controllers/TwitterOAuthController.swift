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
        let callback = callbackURL.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let headers: HTTPHeaders = {
            var headers = HTTPHeaders()
            headers.add(name: .authorization, value: "OAuth")
            headers.add(name: "oauth_consumer_key", value: consumerKey)
            headers.add(name: "oauth_callback", value: callback)
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
