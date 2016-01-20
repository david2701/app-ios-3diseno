

import UIKit
import CoreData

class CoreDataManager: NSObject {

    func cacheFetchedArticles(articles: [ArticlePrototype]) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        var managedArray = [Article]()
        
      
        let fetchRequest = NSFetchRequest(entityName:"Article")
        
        do {
            let fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            
            if let managedObjects = fetchedResults as [NSManagedObject]! {
                for managedObject in managedObjects {
                    managedContext.deleteObject(managedObject)
                }
                
                try managedContext.save()
            }
        } catch {
            
            print("Error: \(error)")
        }
        
   
        
        for articleProto in articles {
            let managedArticle = Article(prototype: articleProto, inManagedObjectContext: managedContext)
            managedArray.append(managedArticle)
        }
        
        
        do {
            try managedContext.save()
        } catch {
            print("Error: \(error)")
        }
        
        // try fetch
        // For debugging only
//                let fetchRequest = NSFetchRequest(entityName:"Article")
//
//                do {
//                    let fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
//
//                    print(fetchedResults)
//                } catch {
//                    print("Error: \(error)")
//                }
        
    }
}
