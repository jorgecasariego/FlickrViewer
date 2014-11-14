//
//  FlickrHelper.swift
//  FlickrViewer
//
//  Created by Jorge Casariego on 12/11/14.
//  Copyright (c) 2014 Jorge Casariego. All rights reserved.
//

import UIKit

class FlickrHelper: NSObject {
    
    class func URLforSearchString(searchString:String) ->String {
        let apiKey:String = "b5eb19d75e54198bdba148be58fb35fb"
        let search:String = searchString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\(search)&per_page=20&format=json&nojsoncallback=1"

    }
    
    //Lo que hacemos en este metodo es pasarle un objeto del tipo FlickrPhoto el cual contiene todos los
    //datos de la foto que queremos mostrar
    //Este objeto con toda la información usamos con la url para obtener la foto
    class func URLforFlickrPhoto(photo:FlickrPhoto, size:String) ->String{
        var _size:String = size
        
        if _size.isEmpty{
            _size = "m"
        }
        
        return "http://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.photoID)_\(photo.secret)_\(_size).jpg"
    }

    
    
    func searchFlickrForString(searchString:String, completion:(searchString:String!, flickrPhotos:NSMutableArray!, error:NSError!)->()){
        let searchURL:String = FlickrHelper.URLforSearchString(searchString)
        let queue:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        
        dispatch_async(queue, {
            var error:NSError?
            
            let searchResultString:String! = String(contentsOfURL: NSURL(string: searchURL)!, encoding: NSUTF8StringEncoding, error: &error)
            
            //String.stringWithContentsOfURL(NSURL.URLWithString(searchURL), encoding:NSUTF8StringEncoding, error:&error)
            
            //Si hubo error
            if error != nil{
                completion(searchString: searchString, flickrPhotos: nil, error: error)
            } else{
                //Aquí lo que debemos hacer es parsear el archivo json recibido
                //Parse JSON RESPONSE
                let jsonData:NSData! = searchResultString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                
                //El resultado vamos a guardar en un diccionario
                let resultDict:NSDictionary! = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: &error) as NSDictionary
                
                //En este momento podríamos llagar a tener un error por lo que primero controlamos si hubo algun error
                //Si hubo un error entonces llamamos al metodo completion
                if(error != nil){
                    completion(searchString: searchString, flickrPhotos: nil, error: error)
                } else{
                    //Primero controlamos por la variable "stat" que nos devuelve el API de Flickr si es que hubo algun error
                    //Obtenemos el valor del objeto "stat"
                    let status:String = resultDict.objectForKey("stat") as String
                    
                    if status == "fail"{
                        //Buscamos el mensaje de error
                        let messageString:String = resultDict.objectForKey("message") as String
                        
                        //Creamos un objeto del tipo error
                        let error:NSError? = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:messageString])
                        
                        
                        completion(searchString: searchString, flickrPhotos: nil, error: error)
                    } else{
                        //En este punto sabemos que no hubo ningun error
                        //Creamos un dictionary para guardar las fotos que vienene en el json
                        //EL formato del objeto json es de esta forma http//igrali.files.wordpress.com/2013/03/json.jpg
                        //Accedemos a todas las fotos accediendo a los keys "Photos"->"Photo"
                        let resultArray:NSArray = resultDict.objectForKey("photos")?.objectForKey("photo") as NSArray
                        
                        //Ahora creamos nuestro primero objeto del tipo Flickr
                        let flickrPhotos:NSMutableArray = NSMutableArray()
                        
                        for photoObject in resultArray{
                            let photoDict:NSDictionary = photoObject as NSDictionary

                            var flickrPhoto:FlickrPhoto = FlickrPhoto()
                            flickrPhoto.farm = photoDict.objectForKey("farm") as Int
                            flickrPhoto.server = photoDict.objectForKey("server") as String
                            flickrPhoto.secret = photoDict.objectForKey("secret") as String
                            flickrPhoto.photoID = photoDict.objectForKey("id") as String
                            
                            //Ahora lo que debemos hacer es obtener la url de la foto
                            //m es el tamaño de la foto a ser mostrada
                            let searchURL:String = FlickrHelper.URLforFlickrPhoto(flickrPhoto, size: "m")
                            
                            //flickrPhotos.addObject(searchURL)
                            
                            //Bajamos la foto
                            //let imageData:NSData = NSData(contentsOfURL: NSURL.URLWithString(searchURL), options: nil, error: &error)!
                            let imageData:NSData = NSData(contentsOfURL: NSURL(string: searchURL)!, options: nil, error: &error)!
                            let image:UIImage = UIImage(data: imageData)!
                            flickrPhoto.thumbnail = image
                            
                            flickrPhotos.addObject(flickrPhoto)
                            
                        }
                        
                        completion(searchString: searchString, flickrPhotos: flickrPhotos, error: nil)
                    }
                }
            }
        })
    }
   
}
