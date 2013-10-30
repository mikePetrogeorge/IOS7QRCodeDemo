//
//  Barcode.h
//  QRCodes
//
//  Created by Mike Petrogeorge on 10/25/13.
//  Copyright (c) 2013 Mike Petrogeorge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface Barcode : NSObject

@property (nonatomic, strong) AVMetadataMachineReadableCodeObject *metadataObject;
@property (nonatomic, strong) UIBezierPath *cornersPath;
@property (nonatomic, strong) UIBezierPath *boundingBoxPath;

@end
