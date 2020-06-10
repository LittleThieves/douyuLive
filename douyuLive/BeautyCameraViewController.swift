//
//  BeautyCameraViewController.swift
//  douyuLive
//
//  Created by it on 2020/6/10.
//  Copyright © 2020 房趣科技. All rights reserved.
//

import UIKit
import GPUImage

class BeautyCameraViewController: UIViewController {

    @IBOutlet var imageView : UIImageView!
    /// 参数一 分辨率 参数二 前置后置
    fileprivate lazy var camera : GPUImageStillCamera = GPUImageStillCamera(sessionPreset: AVCaptureSession.Preset.high.rawValue, cameraPosition: .front)
    fileprivate lazy var filter = GPUImageBrightnessFilter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 1.创建GPUImageStillCamera
        //方向。
        camera.outputImageOrientation = .portrait
        // 2.创建滤镜(美白/曝光)
        // let filter = GPUImageBrightnessFilter()
        filter.brightness = 0.3
        let blurFilter = GPUImageGaussianBlurFilter()
        // 纹理
        blurFilter.texelSpacingMultiplier = 5
        //像素
        blurFilter.blurRadiusInPixels = 5
        camera.addTarget(filter)
        camera.addTarget(blurFilter)
        // 3.创建GPUImageView,用于显示实时画面
        let width = view.bounds.size.width-30*2
        let height = width/3*4
        let showView = GPUImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        showView.center = view.center
        view.insertSubview(showView, at: 0)
        filter.addTarget(showView)
        // 4.开始捕捉画面
        camera.startCapture()
    }
    
    @IBAction func takePhoto() {
        camera.capturePhotoAsImageProcessedUp(toFilter: filter, withCompletionHandler: { (image, error) in
            guard let image = image else {
                self.imageView.image = nil
                self.camera.startCapture()
                return }
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            self.imageView.image = image
            self.camera.stopCapture()
        })
    }
}
