

import Foundation
import CoreData
import UIKit

class Article: NSManagedObject {
    
    convenience init(prototype: ArticlePrototype, inManagedObjectContext context: NSManagedObjectContext) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let entity = NSEntityDescription.entityForName("Article", inManagedObjectContext: context)!
        
        self.init(entity: entity, insertIntoManagedObjectContext: appDelegate.managedObjectContext)
        
        self.titulo = prototype.title
        self.descripArticulo = prototype.description
        self.imagenURL = prototype.imageURL
        self.fecha = prototype.date
        self.articuloURL = prototype.articleURL
        
      
        if let image = prototype.image as UIImage! {
            self.imagen = image
        }
    }

}
