//
//  GithubService.swift
//  
//
//  Created by User on 4/14/15.
//
//

import Foundation

class GithubService {
  
  static let defaultService: GithubService = GithubService()
  
  let githubSearchRepoURL = "https://api.github.com/search/repositories"
  let githubSearchUserURL = "https://api.github.com/search/users"
  let localURL = "http://127.0.0.1:3000"
  
  
  func fetchRepositories(searchTerm: String, completionHandler: ([Repository]?, String?) -> (Void)) {
    
    let searchString = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    //  Need to implement check on other 'nonURL-friendly' characters

    let requestString = self.githubSearchRepoURL + "?q=\(searchString)"
    let requestUrl = NSURL(string: requestString)
    let request = NSMutableURLRequest(URL: requestUrl!)
    
    if let token = NSUserDefaults.standardUserDefaults().objectForKey(kUserDefaultTokenKey) as? String {
      request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
    }
    
    let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
      if error == nil {
        if let httpResponse = response as? NSHTTPURLResponse {
          switch httpResponse.statusCode {
          case 200:
            let repos = GithubJSONParser.reposFromJSONData(data)
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
              completionHandler(repos, nil)
            })
          default:
            println(httpResponse.statusCode)
          }
        }
      }
    })
    dataTask.resume()
  }
  
  
  func fetchUsers(searchTerm: String, completionHandler: ([User]?, String?) -> (Void)) {
    let searchString = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    //  Need to implement check on other 'nonURL-friendly' characters  }
   
    let searchURLString = self.githubSearchUserURL + "?q=" + searchString
    let searchRequest = NSMutableURLRequest(URL: NSURL(string: searchURLString)!)
    if let token = NSUserDefaults.standardUserDefaults().objectForKey(kUserDefaultTokenKey) as? String {
      searchRequest.setValue("token \(token)", forHTTPHeaderField: "Authorization")
    }
    
    let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(searchRequest, completionHandler: { (data, response, error) -> Void in
      if error != nil {
        completionHandler(nil, error!.description)
      }
      else if data != nil {
        let users = GithubJSONParser.usersFromJSONData(data)
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
          completionHandler(users, nil)
        })
      }
    })
    dataTask.resume()
  }
}
