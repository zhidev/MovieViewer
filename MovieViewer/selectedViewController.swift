//
//  selectedViewController.swift
//  MovieViewer
//
//  Created by Douglas on 1/24/16.
//  Copyright © 2016 Dougli. All rights reserved.
//

import UIKit

class selectedViewController: UIViewController {
    @IBOutlet var posterImage: UIImageView!
    @IBOutlet var titleLabel: UITextView!

    @IBOutlet var overviewLabel: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("test in 2nd segue")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    


}
