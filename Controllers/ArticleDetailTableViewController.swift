

import UIKit
import WebKit

class ArticleDetailTableViewController: UITableViewController {
    
    var article: Article?
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        self.tableView.estimatedRowHeight = 88.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        
        let webViewHeight = self.tableView.frame.size.height - self.tableView.estimatedRowHeight - (self.navigationController?.navigationBar.frame.size.height)! - UIApplication.sharedApplication().statusBarFrame.height
        
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: webViewHeight))
        webView.loadRequest(NSURLRequest(URL: NSURL(string: (self.article?.articuloURL)!)!))
        
        webView.navigationDelegate = self
        
        self.tableView.tableFooterView = webView
        
       
        self.spinner.center = self.view.center
        self.spinner.color = UIColor.purpleColor()
        self.view.addSubview(self.spinner)
        self.view.bringSubviewToFront(self.spinner)
        self.spinner.startAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

  
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("articleHeader", forIndexPath: indexPath) as! ArticleHeaderTableViewCell

        cell.articleTitleLabel.text = self.article?.titulo
        
        if let imageObj = self.article?.imagen {
            if let image: UIImage = imageObj as? UIImage {
                cell.articleImageView.image = image
            }
        } else {
            cell.articleImageView.image = UIImage(named: "img_thumb_placeholder")
        }

        return cell
    }

}



extension ArticleDetailTableViewController: WKNavigationDelegate {
    
  
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        // stop spinner
        spinner.stopAnimating()
        spinner.hidden = true
    }
    
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        print(error)
        
        var userMessage: String?
        
        switch error.code {
        case NSURLErrorNotConnectedToInternet:
            userMessage = NetworkError.NetworkFailure.localizedDescription
        
        default:
            userMessage = NetworkError.UnknownError.localizedDescription
        }
        
        self.alertUserWithTitleAndMessage("Error", message: userMessage)
    }
}
