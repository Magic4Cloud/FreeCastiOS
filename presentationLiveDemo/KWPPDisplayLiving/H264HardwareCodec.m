//
//  H264HardwareCodec.m
//  VideoDemo
//
//  Created by rakwireless on 16/7/29.
//  Copyright © 2016年 rak. All rights reserved.
//

#import "H264HardwareCodec.h"
#import <UIKit/UIKit.h>

@implementation H264HardwareCodec
{
    uint8_t *_sps;
    uint8_t *_pps;
    
    BOOL _isTakePicture;
    BOOL _isSaveTakePictureImage;
    NSString *_saveTakePicturePath;
    
    unsigned int _spsSize;
    unsigned int _ppsSize;
    
    int64_t mCurrentVideoSeconds;
    VTDecompressionSessionRef _decompressionSession;
    CMVideoFormatDescriptionRef _decompressionFormatDesc;
}

-(id)init
{
    if(self = [super init]){
        _isTakePicture = false;
    }
    
    return self;
}

-(BOOL)takePicture:(NSString *)fileName
{
    _isTakePicture = true;
    _isSaveTakePictureImage = false;
    _saveTakePicturePath = fileName;
    
    while(_isSaveTakePictureImage == false){
        //Just waiting "_isSaveTakePictureImage" become true.
    }
    
    _isTakePicture = false;
    return true;;
}

-(CVPixelBufferRef)deCompressedCMSampleBufferWithData:(Byte *)data andLength:(int) dataLen andOffset:(int)offset;
{
    NALUnit nalUnit;
    CVPixelBufferRef pixelBufferRef = NULL;
    
    if(data == NULL || dataLen == 0){
        return NULL;
    }
    
    while([self nalunitWithData:data andDataLen:dataLen andOffset:offset toNALUnit:&nalUnit])
    {
        if(nalUnit.data == NULL || nalUnit.size == 0){
            return NULL;
        }
        
        pixelBufferRef = NULL;
        [self infalteStartCodeWithNalunitData:&nalUnit];
        //NSLog(@"NALUint Type: %d.", nalUnit.type);
        
        switch (nalUnit.type) {
            case NALUTypeIFrame://IFrame
                if(_sps && _pps)
                {
                    if([self initH264Decoder]){
                        pixelBufferRef = [self decompressWithNalUint:nalUnit];
                        //NSLog(@"NALUint I Frame size:%d", nalUnit.size);
                        
                        free(_sps);
                        free(_pps);
                        _pps = NULL;
                        _sps = NULL;
                        //free(nalUnit.data);
                        return pixelBufferRef;
                    }
                }
                break;
            case NALUTypeSPS://SPS
                _spsSize = nalUnit.size - 4;
                if(_spsSize <= 0){
                    return NULL;
                }
                
                _sps = (uint8_t*)malloc(_spsSize);
                memcpy(_sps, nalUnit.data + 4, _spsSize);
                NSLog(@"NALUint SPS size:%d", nalUnit.size - 4);
                break;
            case NALUTypePPS://PPS
                _ppsSize = nalUnit.size - 4;
                if(_ppsSize <= 0){
                    return NULL;
                }
                
                _pps = (uint8_t*)malloc(_ppsSize);
                memcpy(_pps, nalUnit.data + 4, _ppsSize);
                NSLog(@"NALUint PPS size:%d", nalUnit.size - 4);
                break;
            case NALUTypeBPFrame://B/P Frame
                if([self initH264Decoder])
                {
                pixelBufferRef = [self decompressWithNalUint:nalUnit];
                //free(nalUnit.data);
                NSLog(@"NALUint B/P Frame size:%d", nalUnit.size);
                return pixelBufferRef;
                }
            default:
                break;
        }
        
        offset += nalUnit.size;
        if(offset >= dataLen){
            return NULL;
        }
    }
    
    //NSLog(@"The AVFrame data size:%d", offset);
    return NULL;
}

-(void)infalteStartCodeWithNalunitData:(NALUnit *)dataUnit
{
    //Inflate start code with data length
    unsigned char* data  = dataUnit->data;
    unsigned int dataLen = dataUnit->size - 4;
    
    data[0] = (unsigned char)(dataLen >> 24);
    data[1] = (unsigned char)(dataLen >> 16);
    data[2] = (unsigned char)(dataLen >> 8);
    data[3] = (unsigned char)(dataLen & 0xff);
}

-(int)nalunitWithData:(Byte *)data andDataLen:(int)dataLen andOffset:(int)offset toNALUnit:(NALUnit *)unit
{
    unit->size = 0;
    unit->data = NULL;
    
    int addUpLen = offset;
    while(addUpLen < dataLen)
    {
        if(data[addUpLen++] == 0x00 &&
           data[addUpLen++] == 0x00 &&
           data[addUpLen++] == 0x00 &&
           data[addUpLen++] == 0x01){//H264 start code
            
            int pos = addUpLen;
            while(pos < dataLen){//Find next NALU
                if(data[pos++] == 0x00 &&
                   data[pos++] == 0x00 &&
                   data[pos++] == 0x00 &&
                   data[pos++] == 0x01){
                    
                    break;
                }
            }
            
            unit->type = data[addUpLen] & 0x1f;
            if(pos == dataLen){
                unit->size = pos - addUpLen + 4;
            }else{
                unit->size = pos - addUpLen;
            }
            
            unit->data = (unsigned char*)&data[addUpLen - 4];
            return 1;
        }
    }
    return -1;
}

-(BOOL)initH264Decoder
{
    if(_decompressionSession){
        return true;
    }
    
    const uint8_t * const parameterSetPointers[2] = {_sps, _pps};
    const size_t parameterSetSizes[2] = {_spsSize, _ppsSize};
    OSStatus status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault,
                                                                          2,//parameter count
                                                                          parameterSetPointers,
                                                                          parameterSetSizes,
                                                                          4,//NAL start code size
                                                                          &(_decompressionFormatDesc));
    if(status == noErr){
        const void *keys[] = { kCVPixelBufferPixelFormatTypeKey};
        
        //kCVPixelFormatType_420YpCbCr8Planar is YUV420, kCVPixelFormatType_420YpCbCr8BiPlanarFullRange is NV12
        uint32_t biPlanarType = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
        const void *values[] = {CFNumberCreate(NULL, kCFNumberSInt32Type, &biPlanarType)};
        CFDictionaryRef attributes = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
        
        //Create decompression session
        VTDecompressionOutputCallbackRecord outputCallBaclRecord;
        outputCallBaclRecord.decompressionOutputRefCon = NULL;
        outputCallBaclRecord.decompressionOutputCallback = decompressionOutputCallbackRecord;
        status = VTDecompressionSessionCreate(kCFAllocatorDefault,
                                              _decompressionFormatDesc,
                                              NULL, attributes,
                                              &outputCallBaclRecord,
                                              &_decompressionSession);
        CFRelease(attributes);
        if(status != noErr){
            return false;
        }
    }else{
        NSLog(@"Error code %d:Creates a format description for a video media stream described by H.264 parameter set NAL units.", (int)status);
        return false;
    }
    
    return true;
}

//Callback function:Return data when finished, the data includes decompress data、status and so on.
static void decompressionOutputCallbackRecord(void * CM_NULLABLE decompressionOutputRefCon,
                                              void * CM_NULLABLE sourceFrameRefCon,
                                              OSStatus status,
                                              VTDecodeInfoFlags infoFlags,
                                              CM_NULLABLE CVImageBufferRef imageBuffer,
                                              CMTime presentationTimeStamp,
                                              CMTime presentationDuration ){
    CVPixelBufferRef *outputPixelBuffer = (CVPixelBufferRef *)sourceFrameRefCon;
    *outputPixelBuffer = CVPixelBufferRetain(imageBuffer);
}

-(CVPixelBufferRef)decompressWithNalUint:(NALUnit)dataUnit
{
    CMBlockBufferRef blockBufferRef = NULL;
    CVPixelBufferRef outputPixelBufferRef = NULL;
    CMSampleBufferRef sampleBufferRef = NULL;
    
    //1.Fetch video data and generate CMBlockBuffer
    OSStatus status = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault,
                                                         dataUnit.data,
                                                         dataUnit.size,
                                                         kCFAllocatorNull,
                                                         NULL,
                                                         0,
                                                         dataUnit.size,
                                                         0,
                                                         &blockBufferRef);
    //2.Create CMSampleBuffer
    if(status == kCMBlockBufferNoErr){
        const size_t sampleSizes[] = {dataUnit.size};
        OSStatus createStatus = CMSampleBufferCreateReady(kCFAllocatorDefault,
                                                          blockBufferRef,
                                                          _decompressionFormatDesc,
                                                          1,
                                                          0,
                                                          NULL,
                                                          1,
                                                          sampleSizes,
                                                          &sampleBufferRef);
        
        //3.Create CVPixelBuffer
        if(createStatus == kCMBlockBufferNoErr && sampleBufferRef){
            VTDecodeFrameFlags frameFlags = 0;
            VTDecodeInfoFlags infoFlags = 0;
            
            OSStatus decodeStatus = VTDecompressionSessionDecodeFrame(_decompressionSession,
                                                                      sampleBufferRef,
                                                                      frameFlags,
                                                                      &outputPixelBufferRef,
                                                                      &infoFlags);
            
            if(decodeStatus != noErr){
                CFRelease(sampleBufferRef);
                CFRelease(blockBufferRef);
                outputPixelBufferRef = nil;
            }


            if(_isTakePicture){
                if(!_isSaveTakePictureImage){
                    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:outputPixelBufferRef];
                    CIContext *ciContext = [CIContext contextWithOptions:nil];
                    CGImageRef videoImage = [ciContext
                                             createCGImage:ciImage
                                             fromRect:CGRectMake(0, 0,
                                                                 CVPixelBufferGetWidth(outputPixelBufferRef),
                                                                 CVPixelBufferGetHeight(outputPixelBufferRef))];
                    
                    UIImage *uiImage = [UIImage imageWithCGImage:videoImage];
                    _isSaveTakePictureImage = [UIImageJPEGRepresentation(uiImage, 1.0) writeToFile:_saveTakePicturePath atomically:YES];
                    CGImageRelease(videoImage);
                }
            }
//            if (sampleBufferRef) {
//                CFRelease(sampleBufferRef);
//            }
            
        }
    }
//    if (blockBufferRef) {
//        CFRelease(blockBufferRef);
//
//    }
    return outputPixelBufferRef;
}

-(void)dealloc
{
    if(_sps){
        free(_sps);
        _sps = NULL;
    }
    
    if(_pps){
        free(_pps);
        _pps = NULL;
    }
    
    if(_decompressionSession){
        CFRelease(_decompressionSession);
        _decompressionSession = NULL;
    }
    
    if(_decompressionFormatDesc){
        CFRelease(_decompressionFormatDesc);
        _decompressionFormatDesc = NULL;
    }
}

@end
