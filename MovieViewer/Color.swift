//
//  Color.swift
//  MovieViewer
//
//  Created by Douglas on 1/24/16.
//  Copyright © 2016 Dougli. All rights reserved.
//

import UIKit

public class Color{
    class func makeLayer(rect: CGRect ) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()

        gradientLayer.frame = rect
        let color1 = UIColor.purpleColor().CGColor as CGColorRef
        let color2 = UIColor(red: 1.0, green: 0, blue: 0, alpha: 1.0).CGColor as CGColorRef
        let color3 = UIColor.blackColor().CGColor as CGColorRef
        //let color4 = UIColor(white: 0.7, alpha: 0.3).CGColor as CGColorRef
        let color4 = UIColor.blueColor().CGColor as CGColorRef
        gradientLayer.colors = [color1, color2, color3, color4]
        gradientLayer.locations = [0.0, 0.6, 0.85, 1.0]
        return gradientLayer
    }
    
    
}
