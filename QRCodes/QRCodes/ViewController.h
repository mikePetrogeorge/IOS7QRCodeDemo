//
//  ViewController.h
//  QRCodes
//
//  Created by Mike Petrogeorge on 10/25/13.
//  Copyright (c) 2013 Mike Petrogeorge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Barcode.h"

@interface ViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureDevice *videoDevice;
@property (strong, nonatomic) AVCaptureDeviceInput *videoInput;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) NSMutableDictionary *barcodes;
@property (strong, nonatomic) NSArray *keys;
@property (strong, nonatomic) AVCaptureMetadataOutput *metadataOutput;
@property BOOL running;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UILabel *lblContents;
- (IBAction)doStop:(id)sender;
- (IBAction)doStart:(id)sender;

@end
