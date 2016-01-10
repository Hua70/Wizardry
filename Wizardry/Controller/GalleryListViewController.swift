//
//  GalleryListViewController.swift
//  YWH_PhotoKit
//
//  Created by YWH on 15/12/24.
//  Copyright © 2015年 91. All rights reserved.
//

import UIKit
import Photos


class GalleryListViewController: UIViewController {
    let ScreenWidth = UIScreen.mainScreen().bounds.size.width
    let ScreenHeight = UIScreen.mainScreen().bounds.size.height
    let scale = UIScreen.mainScreen().scale
    
//    var selectedCollection : PHAssetCollection?
    @IBOutlet weak var tableView: UITableView!
    var allAlbums:PHFetchResult?
    lazy var imageManager:PHCachingImageManager = {
        
       return PHCachingImageManager()
    }()
    
  
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    
//       super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    // MARK: - Life Circle
    required init?(coder aDecoder: NSCoder) {
        print("init GlleryListViewController")
        super.init(coder: aDecoder)
    }
    
    deinit {
        print("deinit GlleryListViewController")
    }
    override func viewDidLoad() {
        //        let options = PHFetchOptions()
        //        options.sortDescriptors = NSSortDescriptor(key: "creationDate", ascending: true)
         self.allAlbums = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.SmartAlbum, subtype: PHAssetCollectionSubtype.AlbumRegular, options: nil)
        tableView.backgroundView = UIView(frame:  tableView.frame)
        tableView.backgroundView?.backgroundColor = UIColor.blackColor()
        
//        let view = UIView(frame: CGRectMake(0, 0, ScreenWidth, 40))
//        view.backgroundColor = UIColor.redColor()
//        UIApplication.sharedApplication().keyWindow?.addSubview(view)
        
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    @IBAction func backToGallery(segue:UIStoryboardSegue) {

    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
 
        
        
        if !segue.destinationViewController.isKindOfClass(PhotoGridViewController) {
            return
        }
        
        
        let photoGridCtrl = segue.destinationViewController as! PhotoGridViewController
        let cell = sender as! GalleryCell
        photoGridCtrl.title = cell.galleryTitle.text
        
        let indexPath = tableView.indexPathForCell(cell)
//        let fetchResult = allAlbums![(indexPath?.row)!]
        
        if segue.identifier == "ToPhotoGrid"{
//            photoGridCtrl.fetchResult = fetchResult as! PHFetchResult
            let collection = self.allAlbums![indexPath!.row]
            if !collection.isKindOfClass(PHAssetCollection){
                return
            }
            
           let assetsFetchResult = PHAsset.fetchAssetsInAssetCollection(collection as! PHAssetCollection, options: nil)
            photoGridCtrl.collection = collection as? PHAssetCollection
            photoGridCtrl.fetchResult = assetsFetchResult
            photoGridCtrl.galleryTitle = cell.galleryTitle.text
        }
    }
}






// MARK: - Table view data source
extension GalleryListViewController{

     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allAlbums!.count
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GalleryCell", forIndexPath: indexPath) as! GalleryCell
        
        
        //        let player = players[indexPath.row] as GalleryCell
        //        cell.player = player
        
        let collection = self.allAlbums![indexPath.row]
        if collection.isKindOfClass(PHAssetCollection){
            let assetCollection = collection as! PHAssetCollection
            let fetchResult = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: nil)
            if fetchResult.count > 0{
                 let asset = fetchResult[0]
                imageManager .requestImageForAsset(asset as! PHAsset, targetSize: CGSize(width: 50*scale, height: 50*scale), contentMode: .AspectFill, options: nil, resultHandler: { (image, info) -> Void in
                    cell.galleryImageView.image = image
                })

            }
           
            
            cell.galleryTitle.text = assetCollection.localizedTitle
            cell.photoCount.text = "\(fetchResult.count)" + "张"
        }
        
//        cell.textLabel!.text = "\(indexPath.row)"
        return cell
        
    }
//    
//     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//           let selectedCollection = self.allAlbums![indexPath.row] as? PHAssetCollection
//        
//        let photoGridViewController = PhotoGridViewController()
//        photoGridViewController.collection = selectedCollection!
//        photoGridViewController.test = "test"
//        navigationController?.pushViewController(photoGridViewController, animated: true)
//      
//
//           
//    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 40
        }else{
            return 0
        }
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.width,40))
        view.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.7)
        return view
    }
    
}