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
    @IBOutlet var bgView: UIView!
    
    
    let baseUrl = "http://image.tmdb.org/t/p/w500"

    var theme: String?
    var movie: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("test in 2nd segue")
        setBackgroundGradient()

        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        

        if let title = movie?["title"] as? String{
            self.titleLabel.text = title
        }
        
        if let overview = movie?["overview"] as? String{
            overviewLabel.text = overview
        }
        
        
        if let posterPath = movie?["poster_path"] as? String{
            let imageUrl = NSURL(string: baseUrl + posterPath)
            posterView.setImageWithURL(imageUrl!)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setBackgroundGradient(){
        let rect = self.bgView.bounds
        let layer = Color.makeLayer(rect, input: theme!)
        self.bgView.layer.addSublayer(layer)
    }

}
