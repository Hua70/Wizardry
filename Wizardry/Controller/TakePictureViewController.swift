//
//  TakePictureViewController.swift
//  Wizardry
//
//  Created by YWH on 16/1/17.
//  Copyright © 2016年 YWH. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

class TakePictureViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate , AVCaptureMetadataOutputObjectsDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var captureSession: AVCaptureSession!
    @IBOutlet weak var flashAutoBtn: UIButton!
    @IBOutlet weak var flashOnBtn: UIButton!
    @IBOutlet weak var flashOffBtn: UIButton!
    @IBOutlet weak var containView: UIView!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var filter: CIFilter!
     var deviceInput:AVCaptureDeviceInput?
    lazy var context: CIContext = {
        let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        let options = [kCIContextWorkingColorSpace : NSNull()]
        return CIContext(EAGLContext: eaglContext, options: options)
    }()
    
    @IBOutlet weak var focusCursor: UIImageView!
    var filters = [CIFilter]()
    lazy var filterData:FilterData = {
        return FilterData()
    }()
    var ciImage: CIImage!
    
    // 标记人脸
    // var faceLayer: CALayer?
    var faceObject: AVMetadataFaceObject?
    
    // Video Records
    //    @IBOutlet var recordsButton: UIButton!
    var assetWriter: AVAssetWriter?
    var assetWriterPixelBufferInput: AVAssetWriterInputPixelBufferAdaptor?
    var isWriting = false
    var currentSampleTime: CMTime?
    var currentVideoDimensions: CMVideoDimensions?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: -Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for descriptor in filterData.filterDescriptors {
            filters.append(CIFilter(name: descriptor.filterName)!)
        }

        
        previewLayer = AVCaptureVideoPreviewLayer()
        // previewLayer.bounds = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width);
        // previewLayer.position = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
        // previewLayer.setAffineTransform(CGAffineTransformMakeRotation(CGFloat(M_PI / 2.0)));
        previewLayer.anchorPoint = CGPointZero
        previewLayer.frame = self.view              .bounds
//        var frame = previewLayer.bounds
//        frame.size.height -= collectionView.frame.height;
//        previewLayer.frame = frame;
        
//        filterButtonsContainer.hidden = true
        
        containView.layer.insertSublayer(previewLayer, atIndex: 0)
        
     
        if TARGET_IPHONE_SIMULATOR == 1 {
            UIAlertView(title: "提示", message: "不支持模拟器", delegate: nil, cancelButtonTitle: "确定").show()
        } else {
            setupCaptureSession()
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
          captureSession.startRunning()
        addGenstureRecognizer()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        previewLayer.bounds.size = size
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: -Private Method
    
    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        var error:NSError?
       
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        //         try AVCaptureDeviceInput(device: self.currentCameraDevice)
        //        let deviceInput =try! AVCaptureDeviceInput.deviceInputWithDevice(captureDevice, error: nil) as! AVCaptureDeviceInput
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
        }catch let error1 as NSError {
            error = error1
            deviceInput = nil
        }
        
        if captureSession.canAddInput(deviceInput) {
            captureSession.addInput(deviceInput)
        }
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey : NSNumber(unsignedInt:kCVPixelFormatType_32BGRA)]
        dataOutput.alwaysDiscardsLateVideoFrames = true
        
        if captureSession.canAddOutput(dataOutput) {
            captureSession.addOutput(dataOutput)
        }
        
        let queue = dispatch_queue_create("VideoQueue", DISPATCH_QUEUE_SERIAL)
        dataOutput.setSampleBufferDelegate(self, queue: queue)
        
        // 为了检测人脸
        /*
        let metadataOutput = AVCaptureMetadataOutput()
        metadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            print(metadataOutput.availableMetadataObjectTypes)
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeFace]
        }*/
        
        captureSession.commitConfiguration()
    }
    
    
    /**
     给输入设备添加通知
     */
    func addNotificationToCaptureDevice(captureDevice:AVCaptureDevice){
          //注意添加区域改变捕获通知必须首先设置设备允许捕获
        changeDeviceProperty { (captureDevice) -> () in
            captureDevice.subjectAreaChangeMonitoringEnabled = true
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "areaChange:", name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: captureDevice)
    }
    
    func removeNotificationFromCaptureDevice(captureDevice:AVCaptureDevice){
         NSNotificationCenter.defaultCenter().removeObserver(self, name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: captureDevice)
    }

   
    
    //MARK:- Notification Action
    func areaChange(sender:AnyObject){
        print("捕获区域改变")
    }
    
    
    
    //MARK:Camera Setting
     /**
     闪光灯模式
     */
    
    func setFlashMode(flashModel:AVCaptureFlashMode){
        changeDeviceProperty { (captureDevice) -> () in
            if captureDevice.isFlashModeSupported(flashModel){
                do{
                    try captureDevice.lockForConfiguration()
                }catch{
                    return
                }
                captureDevice.flashMode = flashModel
                captureDevice.unlockForConfiguration()
            }
        }
    }
    /**
     设置聚焦模式
     */
    func setFocusMode(focusMode:AVCaptureFocusMode){
        changeDeviceProperty { (captureDevice) -> () in
            if captureDevice.isFocusModeSupported(focusMode){
                 captureDevice.focusMode = focusMode
            }
        }
    }
    
    /**
     *  设置曝光模式
     */
    func setExposureMode(exposureMode:AVCaptureExposureMode){
        changeDeviceProperty { (captureDevice) -> () in
            if captureDevice.isExposureModeSupported(exposureMode){
                 captureDevice.exposureMode = exposureMode
            }
           
        }
    }
    
    /**
     *  设置聚焦点
     *
     *  @param point 聚焦点
     */
    func focusWithMode(focusMode:AVCaptureFocusMode, exposureMode:AVCaptureExposureMode,point:CGPoint){
        changeDeviceProperty { (captureDevice) -> () in
            if captureDevice.isFocusModeSupported(focusMode){
                captureDevice.focusMode = focusMode
            }
            if captureDevice.isExposureModeSupported(exposureMode){
                captureDevice.exposureMode = exposureMode
            }

            if captureDevice.focusPointOfInterestSupported{
                captureDevice.focusPointOfInterest = point
            }
            
            if captureDevice.exposurePointOfInterestSupported{
                captureDevice.exposurePointOfInterest  = point
            }
        }
    }
    
    /**
     *  设置聚焦光标位置
     *
     *  @param point 光标位置
     */
    func setFocusCursorWithPoint(point:CGPoint){
        focusCursor.center = point
        focusCursor.transform = CGAffineTransformMakeScale(1.5, 1.5)
        focusCursor.alpha = 1.0
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.focusCursor.transform = CGAffineTransformIdentity
            }) { (finished) -> Void in
                self.focusCursor.alpha = 0;
        }
    }
    
    /**
     *  添加点按手势，点按时聚焦
     */
    func addGenstureRecognizer(){
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapScreen:")
        containView.addGestureRecognizer(tapGesture)

    }
    
    /**
     *  取得指定位置的摄像头
     *
     *  @param position 摄像头位置
     *
     *  @return 摄像头设备
     */
    func getCameraDeviceWithPosition(position:AVCaptureDevicePosition) -> AVCaptureDevice?{
        let cameras = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for camera in cameras{
            if camera.position == position{
                return camera as? AVCaptureDevice
            }
        }
        return nil
    }
    
    func tapScreen(tapGesture:UITapGestureRecognizer){
        let point = tapGesture.locationInView(containView)
        //将UI坐标转化为摄像头坐标
        let cameraPoint = previewLayer.captureDevicePointOfInterestForPoint(point)
        setFocusCursorWithPoint(point)
        focusWithMode(AVCaptureFocusMode.AutoFocus, exposureMode: AVCaptureExposureMode.AutoExpose, point: cameraPoint)
    }
    
    
    func changeDeviceProperty(propertyChange:AVCaptureDevice ->()){
        let captureDevice = self.deviceInput?.device
        
        if ((try! captureDevice?.lockForConfiguration()) != nil){
            propertyChange(captureDevice!)
        }else
        {
            print("设置设备属性过程发生错误")
        }
    }
    
    func makeFaceWithCIImage(inputImage: CIImage, faceObject: AVMetadataFaceObject) -> CIImage {
        let filter = CIFilter(name: "CIPixellate")
        filter!.setValue(inputImage, forKey: kCIInputImageKey)
        // 1.
        filter!.setValue(max(inputImage.extent.size.width, inputImage.extent.size.height) / 60, forKey: kCIInputScaleKey)
        
        let fullPixellatedImage = filter!.outputImage
        
        var maskImage: CIImage!
        let faceBounds = faceObject.bounds
        
        // 2.
        let centerX = inputImage.extent.size.width * (faceBounds.origin.x + faceBounds.size.width / 2)
        let centerY = inputImage.extent.size.height * (1 - faceBounds.origin.y - faceBounds.size.height / 2)
        let radius = faceBounds.size.width * inputImage.extent.size.width / 2
        let radialGradient = CIFilter(name: "CIRadialGradient",
            withInputParameters: [
                "inputRadius0" : radius,
                "inputRadius1" : radius + 1,
                "inputColor0" : CIColor(red: 0, green: 1, blue: 0, alpha: 1),
                "inputColor1" : CIColor(red: 0, green: 0, blue: 0, alpha: 0),
                kCIInputCenterKey : CIVector(x: centerX, y: centerY)
            ])
        
        let radialGradientOutputImage = radialGradient!.outputImage!.imageByCroppingToRect(inputImage.extent)
        if maskImage == nil {
            maskImage = radialGradientOutputImage
        } else {
            print(radialGradientOutputImage)
            maskImage = CIFilter(name: "CISourceOverCompositing",
                withInputParameters: [
                    kCIInputImageKey : radialGradientOutputImage,
                    kCIInputBackgroundImageKey : maskImage
                ])!.outputImage
        }
        
        let blendFilter = CIFilter(name: "CIBlendWithMask")
        blendFilter!.setValue(fullPixellatedImage, forKey: kCIInputImageKey)
        blendFilter!.setValue(inputImage, forKey: kCIInputBackgroundImageKey)
        blendFilter!.setValue(maskImage, forKey: kCIInputMaskImageKey)
        
        return blendFilter!.outputImage!
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(captureOutput: AVCaptureOutput!,didOutputSampleBuffer sampleBuffer: CMSampleBuffer!,fromConnection connection: AVCaptureConnection!) {
        autoreleasepool {
            let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            
            let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer)
            self.currentVideoDimensions = CMVideoFormatDescriptionGetDimensions(formatDescription!)
            self.currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer)
            
            // CVPixelBufferLockBaseAddress(imageBuffer, 0)
            // let width = CVPixelBufferGetWidthOfPlane(imageBuffer, 0)
            // let height = CVPixelBufferGetHeightOfPlane(imageBuffer, 0)
            // let bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0)
            // let lumaBuffer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)
            //
            // let grayColorSpace = CGColorSpaceCreateDeviceGray()
            // let context = CGBitmapContextCreate(lumaBuffer, width, height, 8, bytesPerRow, grayColorSpace, CGBitmapInfo.allZeros)
            // let cgImage = CGBitmapContextCreateImage(context)
            var outputImage = CIImage(CVPixelBuffer: imageBuffer!)
            
            if self.filter != nil {
                self.filter.setValue(outputImage, forKey: kCIInputImageKey)
                outputImage = self.filter.outputImage!
            }
            if self.faceObject != nil {
                outputImage = self.makeFaceWithCIImage(outputImage, faceObject: self.faceObject!)
            }
            
            // 录制视频的处理
            if self.isWriting {
                if self.assetWriterPixelBufferInput?.assetWriterInput.readyForMoreMediaData == true {
                    var newPixelBuffer:  CVPixelBuffer? = nil
                    //                    CVPixelBufferPoolCreatePixelBuffer(nil, (self.assetWriterPixelBufferInput?.pixelBufferPool)!, newPixelBuffer!)
                    CVPixelBufferPoolCreatePixelBuffer(nil, (self.assetWriterPixelBufferInput?.pixelBufferPool)!, &newPixelBuffer)
                    
                    self.context.render(outputImage, toCVPixelBuffer: (newPixelBuffer)!, bounds: outputImage.extent, colorSpace: nil)
                    
                    let success = self.assetWriterPixelBufferInput?.appendPixelBuffer((newPixelBuffer)!, withPresentationTime: self.currentSampleTime!)
                    
                    
                    if success == false {
                        print("Pixel Buffer没有附加成功")
                    }
                }
            }
            
            let orientation = UIDevice.currentDevice().orientation
            var t: CGAffineTransform!
            if orientation == UIDeviceOrientation.Portrait {
                t = CGAffineTransformMakeRotation(CGFloat(-M_PI / 2.0))
            } else if orientation == UIDeviceOrientation.PortraitUpsideDown {
                t = CGAffineTransformMakeRotation(CGFloat(M_PI / 2.0))
            } else if (orientation == UIDeviceOrientation.LandscapeRight) {
                t = CGAffineTransformMakeRotation(CGFloat(M_PI))
            } else {
                t = CGAffineTransformMakeRotation(0)
            }
            outputImage = outputImage.imageByApplyingTransform(t)
            
            let cgImage = self.context.createCGImage(outputImage, fromRect: outputImage.extent)
            self.ciImage = outputImage
            
            dispatch_sync(dispatch_get_main_queue(), {
                self.previewLayer.contents = cgImage
            })
        }
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        // println(metadataObjects)
        if metadataObjects.count > 0 {
            //识别到的第一张脸
            faceObject = metadataObjects.first as? AVMetadataFaceObject
            
            /*
            if faceLayer == nil {
            faceLayer = CALayer()
            faceLayer?.borderColor = UIColor.redColor().CGColor
            faceLayer?.borderWidth = 1
            view.layer.addSublayer(faceLayer)
            }
            let faceBounds = faceObject.bounds
            let viewSize = view.bounds.size
            
            faceLayer?.position = CGPoint(x: viewSize.width * (1 - faceBounds.origin.y - faceBounds.size.height / 2),
            y: viewSize.height * (faceBounds.origin.x + faceBounds.size.width / 2))
            
            faceLayer?.bounds.size = CGSize(width: faceBounds.size.height * viewSize.width,
            height: faceBounds.size.width * viewSize.height)
            print(faceBounds.origin)
            print("###")
            print(faceLayer!.position)
            print("###")
            print(faceLayer!.bounds)
            */
        }
    }
    
    //MARK:- Action

    @IBAction func takePicture(sender: AnyObject) {
        if ciImage == nil || isWriting {
            return
        }
        let camera = sender as! UIButton
        camera.enabled = false
        captureSession.stopRunning()
        
        let cgImage = context.createCGImage(ciImage, fromRect: ciImage.extent)
        ALAssetsLibrary().writeImageToSavedPhotosAlbum(cgImage, metadata: ciImage.properties)
            {(url: NSURL!, error :NSError!) -> Void in
                if error == nil {
                    print("保存成功")
                    print(url)
                } else {
                    let alert = UIAlertView(title: "错误", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "确定")
                    alert.show()
                }
                self.captureSession.startRunning()
                camera.enabled = true
        }

    }
    
    @IBAction func flipCamera(sender: AnyObject) {
        
        let currentDevice = self.deviceInput?.device
        let currentPosition = currentDevice!.position
        removeNotificationFromCaptureDevice(currentDevice!)
        var toChangeDevice:AVCaptureDevice?
        var toChangePosition = AVCaptureDevicePosition.Front
        if currentPosition == AVCaptureDevicePosition.Unspecified||currentPosition == AVCaptureDevicePosition.Front{
            toChangePosition = AVCaptureDevicePosition.Back
        }
        toChangeDevice = getCameraDeviceWithPosition(toChangePosition)
        addNotificationToCaptureDevice(toChangeDevice!)
        
        let toChangeDeviceInput = try! AVCaptureDeviceInput(device: toChangeDevice)
        
        self.captureSession.beginConfiguration()
        self.captureSession.removeInput(self.deviceInput)
        if self.captureSession.canAddInput(toChangeDeviceInput){
            self.captureSession.addInput(toChangeDeviceInput)
            self.deviceInput = toChangeDeviceInput
        }
        self.captureSession.commitConfiguration()
        
        
        
    }
    @IBAction func turnFlashAuto(sender: AnyObject) {
        setFlashMode(AVCaptureFlashMode.Auto)
        flashOffBtn.selected = false
        flashOnBtn.selected = false
        flashAutoBtn.selected = true
    }
    @IBAction func turnFlashOn(sender: AnyObject) {
         setFlashMode(AVCaptureFlashMode.On)
        flashOffBtn.selected = false
        flashOnBtn.selected = true
        flashAutoBtn.selected = false
    }
    @IBAction func turnFlashOff(sender: AnyObject) {
         setFlashMode(AVCaptureFlashMode.Off)
        flashOffBtn.selected = true
        flashOnBtn.selected = false
        flashAutoBtn.selected = false
    }
    @IBAction func touchSwitch(sender: AnyObject) {
        let device = deviceInput?.device
        var torchMode = AVCaptureTorchMode.On
        if device?.torchMode == AVCaptureTorchMode.Off{
            torchMode = AVCaptureTorchMode.On
        }else{
            torchMode = AVCaptureTorchMode.Off
        }
        do{
            try device?.lockForConfiguration()
            device?.torchMode = torchMode
            device?.unlockForConfiguration()
        }catch{
            
        }
    }
}





extension TakePictureViewController{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PictureCell", forIndexPath: indexPath) as! PhotoFilterCollectionViewCell
        cell.filteredImageView.contentMode = .ScaleAspectFill
        cell.filteredImageView.inputImage = UIImage(named: "2.png")
        cell.filteredImageView.filter = filters[indexPath.item]
        cell.filterNameLabel.text = filterData.filterDescriptors[indexPath.item].filterDisplayName
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        imageView.filter = filters[indexPath.item]
         filter = filters[indexPath.item]
    }
    
}