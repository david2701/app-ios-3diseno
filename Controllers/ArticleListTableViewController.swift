

import UIKit
import CoreData

class ArticleListTableViewController: UITableViewController {
    
    var context: NSManagedObjectContext!
        lazy var fetchedResultsController: NSFetchedResultsController = {
        let articlesFetchRequest = NSFetchRequest(entityName: "Article")
        articlesFetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let frc = NSFetchedResultsController(fetchRequest: articlesFetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        
        return frc
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        

        do {
            try self.fetchedResultsController.performFetch()
            
            self.tableView.reloadData()
        } catch {
            print("Error performing initial fetch: \(error)")
        }
        
        self.reloadTableWithArticles()
    }
    
    func reloadTableWithArticles() {
        
        NetworkManager().fetchAllArticlesWithCompletion { (data, error) -> Void in
            
            if error != nil {
                
                if let networkError = error as? NetworkError {
                    switch networkError{
                    case .NetworkFailure:
                        self.alertUserWithTitleAndMessage("Error de red", message: kNetworkFailureMessage)
                        return
                        
                    default:
                        self.alertUserWithTitleAndMessage("Error Desconocido", message: kUnknownErrorMessage)
                        return
                    }
                }
            }
            
            if let unwrappedData = data as? NSData {
                NetworkManager().parseAllArticleData(unwrappedData, completion: { (content, error) -> Void in
                    
                    if error == nil {
                    
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            do {
                                try self.fetchedResultsController.performFetch()
                                
                                self.tableView.reloadData()
                            } catch {
                                print("Error: \(error)")
                                                            }
                        })
                    } else {
                   
                        if let networkError = error as? NetworkError {
                            switch networkError {
                            case .ParsingError:
                                self.alertUserWithTitleAndMessage("Red Error", message: kParsingErrorMessage)
                                return
                                
                            default:
                                self.alertUserWithTitleAndMessage("Unknown Error", message: kUnknownErrorMessage)
                            }
                        }
                    }
                    
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func refreshTable(sender: AnyObject) {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.reloadTableWithArticles()
            sender.endRefreshing()
        }
    }

    

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let results = self.fetchedResultsController.fetchedObjects?.count {
            return results
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("articleListCell", forIndexPath: indexPath) as! ArticleListTableViewCell
        
        if let dataSource = self.fetchedResultsController.fetchedObjects as? [Article] {
            cell.articleTitleLabel.text = dataSource[indexPath.row].titulo
            cell.articleDescriptionLabel.text = dataSource[indexPath.row].descripArticulo
            
            if let cellImage: UIImage = dataSource[indexPath.row].imagen as? UIImage {
                cell.articleImageView.image = cellImage
            } else {
                cell.articleImageView.image = UIImage(named: "img_thumb_placeholder")
            }
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showArticleDetail", sender: indexPath)
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      
        if let detailVC = segue.destinationViewController as? ArticleDetailTableViewController {
                        if let indexPath = sender as? NSIndexPath {
               
                if let dataSource = self.fetchedResultsController.fetchedObjects as? [Article] {
                    detailVC.article = dataSource[indexPath.row]
                }
                
            }
        }
    }
}
