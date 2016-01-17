//
//  PhotoGridViewController.swift
//  Wizardry
//
//  Created by YWH on 15/12/26.
//  Copyright © 2015年 YWH. All rights reserved.
//

import UIKit
import Photos

class PhotoGridViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var galleryTitleLabel: UILabel!
    
    var galleryTitle: String?
     let scale = UIScreen.mainScreen().scale
    var collection:PHAssetCollection?
    var fetchResult:PHFetchResult?

 
    
    let gridWidth = (UIScreen.mainScreen().bounds.size.width - 3)/4

    lazy var imageManager:PHCachingImageManager = {
        
        return PHCachingImageManager()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        galleryTitleLabel.text = galleryTitle
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        
        if !segue.destinationViewController.isKindOfClass(PhotoFilterViewController) {
            return
        }
    
        let photoFilterCtrl = segue.destinationViewController as! PhotoFilterViewController
        
        let cell = sender as! PhotoCollectionCell
        
        let indexPath = collectionView.indexPathForCell(cell)
        
        
        if segue.identifier == "ToPhotoFilter"{
            let asset = self.fetchResult![(indexPath?.item)!] as? PHAsset
            photoFilterCtrl.asset = asset
            photoFilterCtrl.assetCollection = self.collection;
        }
}

    
    @IBAction func backToGrid(segue:UIStoryboardSegue)  {
        
    }
}


extension PhotoGridViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
     func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return (fetchResult?.count)!
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
     func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let photoCollectionCell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCollectionCell", forIndexPath: indexPath) as! PhotoCollectionCell
         let asset = fetchResult![indexPath.row]
        
        imageManager .requestImageForAsset(asset as! PHAsset, targetSize: CGSize(width: gridWidth*scale, height: gridWidth*scale), contentMode: .AspectFill, options: nil, resultHandler: { (image, info) -> Void in
            photoCollectionCell.photoThum.image = image
        })

        return photoCollectionCell
    }

      func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(gridWidth, gridWidth*1.02)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
       return UIEdgeInsetsZero
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 1
    }
 //    collection

}
