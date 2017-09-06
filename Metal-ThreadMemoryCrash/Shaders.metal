//
//  Shaders.metal
//  Metal-ThreadMemoryCrash
//
//  Created by Andrey Volodin on 06.09.17.
//  Copyright © 2017 s1ddok. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef struct {
    uint  a;
    float hue;
} Uniforms;

typedef struct {
    uint  initialCoord;
    float hue;
} Pixel;

kernel void foo(
              device Uniforms& uniformsBuffer [[buffer(0)]],
              uint pid [[thread_position_in_grid]]) {
    
#define SORT_BUFFER_MAX 1024
    // Something really stupid just so compiler won't reduce this part of code
    thread Pixel* sortBuffer[SORT_BUFFER_MAX];
    
    for (int i = 0; i < SORT_BUFFER_MAX; i++) {
        sortBuffer[i]->hue = (float)pid * uniformsBuffer.hue;
    }
    
    uniformsBuffer.hue = sortBuffer[SORT_BUFFER_MAX / 2]->hue;
}
