//
//  H264HardwareCodec.h
//  VideoDemo
//
//  Created by rakwireless on 16/7/29.
//  Copyright © 2016年 rak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import <Foundation/Foundation.h>

typedef struct _NALUnit{
    unsigned int type;
    unsigned int size;
    unsigned char *data;
}NALUnit;

typedef enum{
    NALUTypeBPFrame = 0x01,
    NALUTypeIFrame = 0x05,
    NALUTypeSPS = 0x07,
    NALUTypePPS = 0x08
}NALUType;

@interface H264HardwareCodec : NSObject
- (id)init;
- (BOOL)takePicture:(NSString *)fileName;

-(CVPixelBufferRef)deCompressedCMSampleBufferWithData:(Byte *)frameData andLength:(int) dataLen andOffset:(int)offset;
@end
