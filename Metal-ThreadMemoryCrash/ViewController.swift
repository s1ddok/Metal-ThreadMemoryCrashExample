//
//  ViewController.swift
//  Metal-ThreadMemoryCrash
//
//  Created by Andrey Volodin on 06.09.17.
//  Copyright © 2017 s1ddok. All rights reserved.
//

import UIKit

public final class Metal {
    
    public static let device: MTLDevice! = {
        return MTLCreateSystemDefaultDevice()
    }()
    
    public static var isAvailable: Bool {
        return Metal.device != nil
    }
    
}

public struct Uniforms {
    public var a: UInt32
    public var hue: Float
}

class ViewController: UIViewController {
    public var commandQueue: MTLCommandQueue!
    public var kernelPipelineState: MTLComputePipelineState!
    
    private lazy var uniformBuffer: MTLBuffer = {
        Metal.device.makeBuffer(length: MemoryLayout<Uniforms>.size, options: .storageModeShared)!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let metalDevice = Metal.device else {
            fatalError("Metal is supported on the current device")
        }
        
        commandQueue  = metalDevice.makeCommandQueue()
        
        guard let shaderLibrary = metalDevice.makeDefaultLibrary() else {
            fatalError("Couldn't retrieve default shader library")
        }
        
        let functionName = "foo"
        guard let pixelSortKernel = shaderLibrary.makeFunction(name: functionName) else {
            fatalError("There is no such function \(functionName)")
        }
        
        guard let computeState = try? metalDevice.makeComputePipelineState(function: pixelSortKernel) else {
            fatalError("Couldn't create compute pipeline state for \(functionName)")
        }
        
        self.kernelPipelineState = computeState
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            fatalError("Could not create command buffer")
        }
        // Dispatch kernel function
        guard let computeCommandEncoder = commandBuffer.makeComputeCommandEncoder() else {
            fatalError("Could not create compute command encoder")
        }
        
        computeCommandEncoder.setComputePipelineState(kernelPipelineState)
        computeCommandEncoder.setBuffer(uniformBuffer, offset: 0, index: 0)
        
        computeCommandEncoder.dispatchThreadgroups(MTLSize(width: 128, height: 1, depth: 1),
                                                   threadsPerThreadgroup: MTLSize(width: kernelPipelineState.threadExecutionWidth, height: 1, depth: 1))
        computeCommandEncoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }



}

