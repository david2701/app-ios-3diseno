

import UIKit

enum NetworkError: ErrorType {
    case NetworkFailure
    case ParsingError
    case UnknownError
    
    var localizedDescription: String {
        switch self {
        case .NetworkFailure:
            return "Sin Conexion"
            
        case .ParsingError:
            return "Error en los datos"
            
        default:
            return "Error Desconocido"
        }
    }
}

class NetworkManager: NSObject {

        func fetchAllArticlesWithCompletion(completion: (data: AnyObject?, error: ErrorType?) -> Void) {
        
        let request = NSURLRequest(URL: NSURL(string: kGoogleNewsRSSURL)!)
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            if let parsedResponse = response as? NSHTTPURLResponse {
                
                if (data != nil) && (error == nil) && (parsedResponse.statusCode == kHTTPResponseStatusCodeSuccess) {
                    
                    completion(data: data, error: nil)
                } else {
                    if error != nil {
                        
                        if let errorCode = error?.code {
                            switch errorCode {
                            case NSURLErrorNotConnectedToInternet:
                                completion(data: nil, error: NetworkError.NetworkFailure)
                                
                            default:
                                completion(data: nil, error: NetworkError.UnknownError)
                            }
                        }
                    } else {
                        
                        completion(data: nil, error: NetworkError.UnknownError)
                    }
                }
            }
        }.resume()
    }
    
   
    func parseAllArticleData(data: NSData, completion: (content: [ArticlePrototype]?, error: ErrorType?) -> Void) {
        
        let articleParser = ArticleParser(data: data)
        
        articleParser.parseDataWithCompletion { (success) -> Void in
            if success {
                
             
                CoreDataManager().cacheFetchedArticles(articleParser.articles)
                
                completion(content: articleParser.articles, error: nil)
            } else {
                completion(content: nil, error: NetworkError.ParsingError)
            }
        }
    }
    
    
    func downloadImagesForArticles(articles: [ArticlePrototype], completion: (articles: [ArticlePrototype]) -> Void) {
        
        if articles.isEmpty {
            completion(articles: articles)
        }
        
        var articlesWithImages = [ArticlePrototype]()
        
        var index = 0
        
        for var article in articles {
            self.fetchImageFromURL(article.imageURL, completion: { (image) -> Void in
                article.image = image
                
                articlesWithImages.append(article)
                
                index++
                
                if index == articles.count {
                    completion(articles: articlesWithImages)
                }
                
            })
        }
    }
    
   
    func fetchImageFromURL(url: String, completion:(image: UIImage?) -> Void) {
        let request = NSURLRequest(URL: NSURL(string: url)!)
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            if data != nil {
                
                if let unwrappedData = data as NSData! {
                    completion(image: UIImage(data: unwrappedData))
                }
            } else {
                completion(image: nil)
            }
        }.resume()
    }
}