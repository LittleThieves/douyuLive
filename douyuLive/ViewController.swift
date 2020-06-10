//
//  ViewController.swift
//  douyuLive
//
//  Created by it on 2020/6/10.
//  Copyright © 2020 房趣科技. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var videoConnect : AVCaptureConnection?
    
    var videoInput : AVCaptureDeviceInput?
    
    var movieOutput : AVCaptureMovieFileOutput?
    // 1.创建捕捉会话
    lazy var session : AVCaptureSession = AVCaptureSession()
    
    /**
    停止采集
    */
    @IBAction func stopSession(_ sender: UIButton) {
        movieOutput?.stopRecording()
        session.stopRunning()
    }
    
    /**
     切换摄像头
     */
    @IBAction func changeVidoe(_ sender: UIButton) {
        
        // 0.执行动画
        let rotaionAnim = CATransition()
        rotaionAnim.type = CATransitionType(rawValue: "oglFlip")
        rotaionAnim.subtype = CATransitionSubtype(rawValue: "fromLeft")
        rotaionAnim.duration = 0.5
        view.layer.add(rotaionAnim, forKey: nil)
        // 1.校验videoInput是否有值
        guard let videoInput = self.videoInput else { return }

        // 2.获取当前镜头
        let position : AVCaptureDevice.Position = videoInput.device.position == .front ? .back : .front

        // 3.创建新的input
        guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else { return }
        guard let newVideoInput = try? AVCaptureDeviceInput(device: newDevice) else { return }

//        print("切换前----------",session.inputs)
        // 4.移除旧输入，添加新输入
        session.beginConfiguration()
        session.removeInput(videoInput)
//        print("切换中----------",session.inputs)
        if session.canAddInput(newVideoInput) {
            session.addInput(newVideoInput)
        }
        session.commitConfiguration()
//        print("切换后----------",session.inputs)
        // 5.保存新输入
        self.videoInput = newVideoInput
        
    }
    
}

extension ViewController {
    
    /**
     保存数据
     */
    @IBAction func saveData(_ sender: UIButton) {
    
        // 1.设置视频输入输出
        setupVideoSource(session: session)
        // 2.设置音频输入输出
        setupAudioSource(session: session)
        // 3.添加预览图层
        setupPreviewLayer(session: session)
        // 4.开始扫描
        session.startRunning()
        // 5.写入文件
//        setupMovieOutput()
    }
    
    /**
     给会话设置视频源（输入源&输出源）
     */
    func setupVideoSource(session: AVCaptureSession) {
        
        // 1.创建输入
        // 1.1.获取所有的设备（包括前置&后置摄像头）
        // 1.2.取出获取前置摄像头
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("获取摄像头失败")
            return }

        // 1.3.通过前置摄像头创建输入设备
        if let _ = self.videoInput {}else {
            self.videoInput = try? AVCaptureDeviceInput(device: device)
        }
        // 3.将输入&输出添加到会话中
        // 3.1.添加输入源
        if session.canAddInput(videoInput!) {
            session.addInput(videoInput!)
        }
        
        // 2.创建输出源
        // 2.1.创建视频输出源
        let videoOutput = AVCaptureVideoDataOutput()

        // 2.2.设置代理,以及代理方法的执行队列（在代理方法中拿到采集到的数据）
        let queue = DispatchQueue.global()
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        
        // 3.2.添加输出源
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }

        // 4.给connect赋值
        videoConnect = videoOutput.connection(with: .video)
    }
    
    /**
     给会话设置音频源（输入源&输出源）
     */
    func setupAudioSource(session : AVCaptureSession) {
        // 1.创建输入
        guard let device = AVCaptureDevice.default(for: .audio) else { return }
        guard let audioInput = try? AVCaptureDeviceInput(device: device) else { return }
        // 2.创建输出源
        let audioOutput = AVCaptureAudioDataOutput()
        let queue = DispatchQueue.global()
        audioOutput.setSampleBufferDelegate(self, queue: queue)

        // 3.将输入&输出添加到会话中
        if session.canAddInput(audioInput) {
            session.addInput(audioInput)
        }
        if session.canAddOutput(audioOutput) {
            session.addOutput(audioOutput)
        }
    }
    
    /**
     添加预览图层
     */
    func setupPreviewLayer(session : AVCaptureSession) {
        // 1.创建预览图层
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        // 2.设置图层的属性
        previewLayer.frame = view.bounds

        // 3.将图层添加到view中
        view.layer.insertSublayer(previewLayer, at: 0)
    }

    func setupMovieOutput() {
        // 1.创建movie的输出
        let output = AVCaptureMovieFileOutput()
        self.movieOutput = output
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return }
        let filePath = path + "/abc.mp4"
        let url = URL(fileURLWithPath: filePath)
        output.startRecording(to: url, recordingDelegate: self)
    }
}

extension ViewController : AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    //获取采集到的音视频回调
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        if connection == videoConnect {
            print("视频数据")
        } else {
            print("音频数据")
        }
    }
    
}

extension ViewController : AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print("开始录制")
    }
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        print("结束录制")
    }
}
