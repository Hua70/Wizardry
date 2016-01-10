//
//  PhotoFilterViewController.swift
//  Wizardry
//
//  Created by YWH on 16/1/10.
//  Copyright © 2016年 YWH. All rights reserved.
//

import UIKit
import Photos

class PhotoFilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var imageView: FilteredImageView!
    @IBOutlet weak var collectionView: UICollectionView!

    var asset:PHAsset?
    var assetCollection: PHAssetCollection?
    var filters = [CIFilter]()
    
    let filterDescriptors: [(filterName: String, filterDisplayName: String)] = [
        ("CIColorControls", "None"),
        ("CIPhotoEffectMono", "Mono"),
        ("CIPhotoEffectTonal", "Tonal"),
        ("CIPhotoEffectNoir", "Noir"),
        ("CIPhotoEffectFade", "Fade"),
        ("CIPhotoEffectChrome", "Chrome"),
        ("CIPhotoEffectProcess", "Process"),
        ("CIPhotoEffectTransfer", "Transfer"),
        ("CIPhotoEffectInstant", "Instant"),
    ]
    

       // MARK: - Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()

        for descriptor in filterDescriptors {
            filters.append(CIFilter(name: descriptor.filterName)!)
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    
       // MARK: - Private Method
    func updateImage(){
        let options = PHImageRequestOptions.init()
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.HighQualityFormat
        options.networkAccessAllowed = true
//        options.progressHandler = {(a) in
//
//            
//        }
        
        PHImageManager.defaultManager().requestImageForAsset(self.asset!, targetSize: self.targetSize(), contentMode: PHImageContentMode.AspectFit, options: options) { (image, object) -> Void in
            if image == nil{
                return
            }
            self.imageView.inputImage  = image
            self.imageView.contentMode = .ScaleAspectFit
            self.imageView.filter = self.filters[0]
            self.collectionView.reloadData()
        }
    }

    
    func targetSize() ->CGSize{
        let scale = UIScreen.mainScreen().scale
        let targetSize =  CGSizeMake(CGRectGetWidth(self.imageView.bounds) * scale, CGRectGetHeight(self.imageView.bounds) * scale)
        return targetSize
    }
    
    
    
    // MARK: - Collection View
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterDescriptors.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoFilterCell", forIndexPath: indexPath) as! PhotoFilterCollectionViewCell
        cell.filteredImageView.contentMode = .ScaleAspectFill
        cell.filteredImageView.inputImage = imageView.inputImage
        cell.filteredImageView.filter = filters[indexPath.item]
        cell.filterNameLabel.text = filterDescriptors[indexPath.item].filterDisplayName
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        imageView.filter = filters[indexPath.item]
    }

}
