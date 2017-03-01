//
//  ViewController.swift
//  SleepingInTheLibrary
//
//  Created by Jarrod Parkes on 11/3/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: - ViewController: UIViewController

class ViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoTitleLabel: UILabel!
    @IBOutlet weak var grabImageButton: UIButton!
    var keyValuePairs:[String] = []
    // MARK: Actions
    
    @IBAction func grabNewImage(_ sender: AnyObject) {
        setUIEnabled(false)
        getImageFromFlickr()
    }
    
    // MARK: Configure UI
    
    fileprivate func setUIEnabled(_ enabled: Bool) {
        photoTitleLabel.isEnabled = enabled
        grabImageButton.isEnabled = enabled
        
        if enabled {
            grabImageButton.alpha = 1.0
        } else {
            grabImageButton.alpha = 0.5
        }
    }
    
    // MARK: Make Network Request
    
    fileprivate func getImageFromFlickr() {
        let methodParameters = [
            Constants.FlickrParameterKeys.Method : Constants.FlickrParameterValues.GalleryPhotosMethod,
            Constants.FlickrParameterKeys.APIKey : Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.GalleryID : Constants.FlickrParameterValues.GalleryID,
            Constants.FlickrParameterKeys.Extras : Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format : Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback : Constants.FlickrParameterValues.DisableJSONCallback
        ]
        
        // TODO: Write the network code here!
        let urlString = Constants.Flickr.APIBaseURL + escapedParameters(methodParameters as [String : AnyObject])
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            
            if error == nil {
                if let data = data {
                    //Parse the JSON response into a format swift can read
                    let parsedResult: AnyObject!
                    do {
                        parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! AnyObject
                    } catch {
                        print("Could not parse the data as JSON: \(data)")
                        return
                    }
                    
                    // Search for the keyword "photos" in the JSON response, and grab the keyword "photos" from that dictionary,
                    // and assign them to a new array of dictionaries
                    if let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String: AnyObject],
                        let photoArray = photosDictionary["photo"] as? [[String:AnyObject]] {
                        
                        
                        let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
                        let photoDictionary = photoArray[randomPhotoIndex] as [String: AnyObject]
                        
                        if let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String,
                            let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String {
                            
                            let imageURL = URL(string: imageUrlString)
                            if let imageData = try? Data(contentsOf: imageURL!) {
                                performUIUpdatesOnMain() {
                                    self.photoImageView.image = UIImage(data: imageData)
                                    self.photoTitleLabel.text = photoTitle
                                    self.setUIEnabled(true)
                                }
                            }
                        }
                    }
                
                }
            }
        }) 
        task.resume()
    }
    
    
    fileprivate func escapedParameters(_ parameters: [String:AnyObject]) -> String {
        
        if parameters.isEmpty {
            return ""
        } else {
            
            for (key, value) in parameters {
                let stringValue = "\(value)"
                
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
            }
            return "?\(keyValuePairs.joined(separator: "&"))"
        }
        
        
        
        
        
        
    }
    
    
    
    
    
    
    
    
    
}
