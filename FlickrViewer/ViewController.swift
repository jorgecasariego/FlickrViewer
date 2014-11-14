//
//  ViewController.swift
//  FlickrViewer
//
//  Created by Jorge Casariego on 12/11/14.
//  Copyright (c) 2014 Jorge Casariego. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet  var flickrImageView: UIImageView!
    @IBOutlet  var searchTextField: UITextField!
    @IBOutlet  var flickrIconImageView: UIImageView!
    @IBOutlet  var activity: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func searchForImage(sender: AnyObject) {
        searchTextField.resignFirstResponder()
        
        flickrIconImageView.backgroundColor = UIColor.blackColor()
        activity.startAnimating()
        
        let flickr:FlickrHelper = FlickrHelper()
        
        //Chequeamos si el usuario ha ingresado algo en el textField
        if searchTextField.text.isEmpty{
            let alert:UIAlertController = UIAlertController(title: "Opps", message: "Por favor ingresar algun text", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
        } else{
            
            flickr.searchFlickrForString(searchTextField.text, completion: {
                (searchString:String!, flickrPhotos:NSMutableArray!, error:NSError!)->() in
                
                if error == nil {
                    let flickrPhoto:FlickrPhoto = flickrPhotos.objectAtIndex(Int(arc4random_uniform(UInt32(flickrPhotos.count)))) as FlickrPhoto
                    
                    let image:UIImage = flickrPhoto.thumbnail
                    
                    //Ya que es el hilo principal debemos hacer lo siguiente para no bloquear la pantalla
                    dispatch_async(dispatch_get_main_queue(), {
                    self.flickrImageView.image = image
                    self.activity.stopAnimating()
                    self.flickrIconImageView.backgroundColor = UIColor.clearColor()
                    })
                }
                
                
                
                
            })
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

