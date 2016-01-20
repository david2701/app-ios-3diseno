

import UIKit


struct ArticlePrototype {
    var title: String!
    var description: String!
    var imageURL: String!
    var image: UIImage?
    var date: NSDate!
    var articleURL: String!
}

class ArticleParser: NSObject {
    
    var parser: NSXMLParser!

    var element = ""
    var articles = [ArticlePrototype]()
    var articleTitle = ""
    var articleDescription = ""
    var articleImageURL = ""
    var articleDate = ""
    var articleURL = ""
 
    convenience init (data: NSData) {
        self.init()
        
        self.parser = NSXMLParser(data: data)
        self.parser.delegate = self
    }
    
  
    func parseDataWithCompletion(completion: (success: Bool) -> Void) {
        
        if self.parser.parse() {
    
            
            NetworkManager().downloadImagesForArticles(self.articles, completion: { (articlesWithImages) -> Void in
                self.articles = articlesWithImages
                completion(success: true)
            })
        } else {
     
            completion(success: false)
        }
        
    }
    

    func stringByStrippingHTML(input: String) -> String {
        
        let stringlength = input.characters.count
        var newString = ""
        
        do {
            let regex = try NSRegularExpression(pattern: "<[^>]+>", options: NSRegularExpressionOptions.CaseInsensitive)
            
            newString = regex.stringByReplacingMatchesInString(input, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, stringlength), withTemplate: "")
            
        } catch {
            print("Error al mostrar la cadena HTML: \(error)")
        }
        
        return newString
    }
    
  
    func getImageLinkFromImgTag(input:String) -> String {
        
    
        
        do {
            let regex = try NSRegularExpression(pattern: kImgTagRegEx, options: NSRegularExpressionOptions.CaseInsensitive)
            
            let results = regex.matchesInString(input, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, input.characters.count))
            
            if let match = results.first as NSTextCheckingResult! {
            
                let str = input as NSString
                let imgTag = str.substringWithRange(match.range)
                
                
                do {
                    
                    let imgRegex = try NSRegularExpression(pattern: kImgTagUrlRegEx, options: NSRegularExpressionOptions.CaseInsensitive)
                    
                    let imgResults = imgRegex.matchesInString(imgTag, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, imgTag.characters.count))
                    
                    if let imgMatch = imgResults.first as NSTextCheckingResult! {
                       
                        let tagStr = imgTag as NSString
                        let imgURL = "http:" + tagStr.substringWithRange(imgMatch.range).stringByReplacingOccurrencesOfString("\"", withString: "")
                        
                        return imgURL
                    }
                    
                } catch {
                    print("Error parsing URL from <img> tag: \(error)")
                }
            }
        } catch {
            print("Error parsing <img> tag: \(error)")
        }
        
        return ""
    }
    
        func dateFromString(input: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = kGoogleNewsArticleDateFormat
        
        if let date = dateFormatter.dateFromString(input) {
            return date
        }
        
        return NSDate()
    }
}



extension ArticleParser: NSXMLParserDelegate {
    
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        self.element = elementName
        
        if self.element == "item" {
            
            self.articleTitle = ""
            self.articleDescription = ""
            self.articleImageURL = ""
            self.articleDate = ""
            self.articleURL = ""
        }
    }

    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        switch self.element {
        case "titulo":
            self.articleTitle += string
            
        case "descripcion":
            self.articleDescription += string
            
        case "link":
            self.articleURL += string
        
        case "pubDate":
            self.articleDate += string
        
        default:
            break
        }
        
        // image link is in description HTML string
    }
    
    // Once an item has been completely parsed, I take the information stored in the class variables and construct an ArticlePrototype object with their content
    // I then add each ArticlePrototype object to an array to be returned by the class
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "item" {
            if !self.articleTitle.isEmpty && !self.articleDescription.isEmpty {
                
                // article prototype constructor
                let article = ArticlePrototype(title: self.articleTitle, description: self.stringByStrippingHTML(self.articleDescription), imageURL: self.getImageLinkFromImgTag(self.articleDescription), image: nil, date: self.dateFromString(self.articleDate), articleURL: self.articleURL)
                
                self.articles.append(article)
            }
        }
    }
}
