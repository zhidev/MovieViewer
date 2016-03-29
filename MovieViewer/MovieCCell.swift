//
//  movieCell.swift
//  MovieViewer
//
//  Created by Douglas on 1/23/16.
//  Copyright © 2016 Dougli. All rights reserved.
//

import UIKit

class MovieCCell: UICollectionViewCell {
    /*@IBOutlet var titleLabel: UILabel!
    @IBOutlet var overviewLabel: UILabel!*/
    @IBOutlet var posterView: UIImageView!
    
    
    var filteredMovieData: NSDictionary?{
        didSet{
            //Low res + high res images
            let low_resolution = "https://image.tmdb.org/t/p/w45"
            let high_resolution = "https://image.tmdb.org/t/p/original"
            if let posterPath = filteredMovieData?["poster_path"] as? String {
                let lowRes = NSURL(string: low_resolution + posterPath)
                let highRes = NSURL(string: high_resolution + posterPath)
                
                //let imageURL = NSURL(string: baseUrl + posterPath)
                //let imageRequest = NSURLRequest(URL: imageURL!)
                let lowImageRequest = NSURLRequest(URL: lowRes!)
                let highImageRequest = NSURLRequest(URL: highRes!)
                self.posterView.setImageWithURLRequest(
                    lowImageRequest,
                    placeholderImage: nil,
                    success: { (lowImageRequest, lowImageResponse, lowImage) -> Void in
                        
                        // smallImageResponse will be nil if the smallImage is already available
                        // in cache (might want to do something smarter in that case).
                        self.posterView.alpha = 0.0
                        self.posterView.image = lowImage;
                        
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            
                            self.posterView.alpha = 1.0
                            
                            }, completion: { (sucess) -> Void in
                                
                                // The AFNetworking ImageView Category only allows one request to be sent at a time
                                // per ImageView. This code must be in the completion block.
                                self.posterView.setImageWithURLRequest(
                                    highImageRequest,
                                    placeholderImage: lowImage,
                                    success: { (highImageRequest, highImageResponse, highImage) -> Void in
                                        
                                        self.posterView.image = highImage;
                                        
                                    },
                                    failure: { (request, response, error) -> Void in
                                        // do something for the failure condition of the large image request
                                        // possibly setting the ImageView's image to a default image
                                })
                        })
                    },
                    failure: { (request, response, error) -> Void in
                        // do something for the failure condition
                        // possibly try to get the large image
                })
            }
            else {
                // No poster image. Can either set to nil (no image) or a default movie poster image
                // that you include as an asset
                self.posterView.image = nil
            }

        }
    }
    
}
