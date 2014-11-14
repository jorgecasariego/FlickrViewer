//
//  FlickrPhoto.swift
//  FlickrViewer
//
//  Created by Jorge Casariego on 12/11/14.
//  Copyright (c) 2014 Jorge Casariego. All rights reserved.
//

import UIKit

class FlickrPhoto: NSObject {
    var thumbnail:UIImage
    var largeImage:UIImage
    
    var photoID:String
    var farm:Int
    var server:String
    var secret:String
    
    override init() {
        thumbnail = UIImage()
        largeImage = UIImage()
        
        photoID = String()
        farm = 0
        server = String()
        secret = String()
    }
   
}
