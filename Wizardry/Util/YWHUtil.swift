//
//  YWHUtil.swift
//  Wizardry
//
//  Created by YWH on 16/1/17.
//  Copyright © 2016年 YWH. All rights reserved.
//

import UIKit

class YWHUtil: NSObject {
    /**
     将CIImage转为UIImage
     
     - parameter ciimage: <#ciimage description#>
     
     - returns: <#return value description#>
     */
    static func toUIImage(ciimage:CIImage) -> UIImage{
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciimage, fromRect: ciimage.extent)
        let uiimage = UIImage(CGImage: cgImage)
        
        return uiimage
    }
}
