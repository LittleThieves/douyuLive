//
//  RealTimeFiltersViewController.swift
//  douyuLive
//
//  Created by it on 2020/6/10.
//  Copyright © 2020 房趣科技. All rights reserved.
//

import UIKit
import GPUImage

/**
 实时滤镜控制器
 */
class RealTimeFiltersViewController: UIViewController {
    
    fileprivate lazy var camera : GPUImageVideoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.vga640x480.rawValue, cameraPosition: .back)
    fileprivate lazy var filter = GPUImageBrightnessFilter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 1.添加滤镜
        camera.outputImageOrientation = .portrait
        camera.addTarget(filter)
        camera.delegate = self
        // 2.添加一个用于实时显示画面的GPUImageView
        let showView = GPUImageView(frame: view.bounds)
        view.addSubview(showView)
        filter.addTarget(showView)
        // 3.开始采集画面
        camera.startCapture()
    }

}

extension RealTimeFiltersViewController : GPUImageVideoCameraDelegate {
    func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        print("采集到画面")
    }
}
