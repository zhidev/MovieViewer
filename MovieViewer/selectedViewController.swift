//
//  selectedViewController.swift
//  MovieViewer
//
//  Created by Douglas on 1/24/16.
//  Copyright © 2016 Dougli. All rights reserved.
//

import UIKit

class selectedViewController: UIViewController {
    @IBOutlet var posterView: UIImageView!
    @IBOutlet var overviewLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var infoView: UIView!
    
    
    let baseUrl = "http://image.tmdb.org/t/p/w500"

    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("test in 2nd segue")
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        
        let title = movie["title"] as? String
        titleLabel.text = title
        
        let overview = movie["overview"] as? String
        overviewLabel.text = overview
        
        
        if let posterPath = movie["poster_path"] as? String{
            let imageUrl = NSURL(string: baseUrl + posterPath)
            posterView.setImageWithURL(imageUrl!)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    


}
