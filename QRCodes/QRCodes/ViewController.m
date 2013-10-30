//
//  ViewController.m
//  QRCodes
//
//  Created by Mike Petrogeorge on 10/25/13.
//  Copyright (c) 2013 Mike Petrogeorge. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setupCaptureSession];
	_previewLayer.frame = _previewView.bounds;
    [_previewView.layer addSublayer:_previewLayer];
    
    // turn on and off the camera if this app goes into the background/foreground.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    // gonna store the contents here.
    // if you decide to scan more than one code, they will end up here.
    _barcodes = [[NSMutableDictionary alloc] init];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopRunning];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"gotta go.. running out of memory");
    [self stopRunning];
}
#pragma mark camera methods

- (void)setupCaptureSession
{
    // If the session has already been created, then exit early as there’s no need to set things up again.
    if (_captureSession)
        return;
    /* Initialize the video device by obtaining the type of the default video media device. This returns the most relevant device available. In practice, this generally references the device’s rear camera. If there’s no camera available, this method will return nil and exit. */
    
    _videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!_videoDevice)
    {
        NSLog(@"No video camera on this device!");
        return;
    }
    
    // Initialize the capture session so you’re prepared to receive input.
    _captureSession = [[AVCaptureSession alloc] init];
    
    //Create the capture input from the device obtained in 2nd comment.
    _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_videoDevice error:nil];
    
    //Query the session with canAddInput: to determine if it will accept an input. If so, call addInput: to add the input to the session.
    
    if ([_captureSession canAddInput:_videoInput]) { [_captureSession addInput:_videoInput];
    }
    
    /*Finally, create and initialize a preview layer and indicate which capture session to preview. Set the gravity to "resize aspect fill" so that frames will scale to fit the layer, clipping them if required to maintain the aspect ratio. */
    
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    
    _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    dispatch_queue_t metadataQueue = dispatch_queue_create("org.petrogeorge.qrCodeData.metadata", 0);
    [_metadataOutput setMetadataObjectsDelegate:self queue:metadataQueue];
    if ([_captureSession canAddOutput:_metadataOutput]) { [_captureSession addOutput:_metadataOutput];
    }
    
}
- (void)startRunning
{
    if (_running)
        return;
    [_captureSession startRunning];
    _metadataOutput.metadataObjectTypes = _metadataOutput.availableMetadataObjectTypes;
    _running = YES;
}

- (void)stopRunning {
    if (!_running) return;
    [_captureSession stopRunning];
    _running = NO;
}

#pragma delegate methods

#pragma mark delegate methods
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSMutableSet *foundBarcodes = [[NSMutableSet alloc] init];
    
    [metadataObjects enumerateObjectsUsingBlock:^(AVMetadataObject *obj, NSUInteger idx, BOOL *stop)
     {
         
         [metadataObjects enumerateObjectsUsingBlock:^(AVMetadataObject *obj, NSUInteger idx, BOOL *stop) {
             NSLog(@"Metadata: %@", obj);
             if ([obj isKindOfClass:[AVMetadataMachineReadableCodeObject class]])
             {
                 AVMetadataMachineReadableCodeObject *code = (AVMetadataMachineReadableCodeObject*)[_previewLayer transformedMetadataObjectForMetadataObject:obj];
                 Barcode *barcode = [self processMetadataObject:code];
                 [foundBarcodes addObject:barcode];
             }
         }];
         
         dispatch_sync(dispatch_get_main_queue(), ^{
             // Remove all old layers
             NSArray *allSublayers = [_previewView.layer.sublayers copy];
             [allSublayers enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
                 if (layer != _previewLayer) {
                     [layer removeFromSuperlayer];
                 }
             }];
             
             // Add new layers
             [foundBarcodes enumerateObjectsUsingBlock:^(Barcode *barcode, BOOL *stop) {
                 CAShapeLayer *boundingBoxLayer = [CAShapeLayer new];
                 boundingBoxLayer.path = barcode.boundingBoxPath.CGPath;
                 boundingBoxLayer.lineWidth = 2.0f;
                 boundingBoxLayer.strokeColor = [UIColor greenColor].CGColor;
                 boundingBoxLayer.fillColor = [UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:0.5f].CGColor;
                 [_previewView.layer addSublayer:boundingBoxLayer];
                 
                 CAShapeLayer *cornersPathLayer = [CAShapeLayer new];
                 cornersPathLayer.path = barcode.cornersPath.CGPath;
                 cornersPathLayer.lineWidth = 2.0f;
                 cornersPathLayer.strokeColor = [UIColor blueColor].CGColor;
                 cornersPathLayer.fillColor = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.5f].CGColor;
                 [_previewView.layer addSublayer:cornersPathLayer];
             }];
             
             
        });
         
     }];
    
    _keys=[_barcodes allKeys];
    if(_keys != nil && [_keys count] > 0)
        NSLog(@" Key 0 %@",_keys[0]);
    else
        NSLog(@"nothing yet");
}

- (Barcode*)processMetadataObject:(AVMetadataMachineReadableCodeObject*)code {
    
    // 1  Query the dictionary of Barcode objects to see if a Barcode with the same contents is already cached.
    Barcode *barcode = _barcodes[code.stringValue];
    
    
    
    // 2 If not, create a new Barcode object and add it to the dictionary.
    if (!barcode) {
        barcode = [Barcode new];
        _barcodes[code.stringValue] = barcode;
    }
    
    // 3 Store the barcode’s metadata in the cached Barcode object for later.
    barcode.metadataObject = code;
    
    // Create the path joining code's corners
    
    // 4 Instantiate cornersPath to store the path joining the four corners of the code.
    CGMutablePathRef cornersPath = CGPathCreateMutable();
    
    // 5 Convert the first corner coordinate to CGPoint instances using some CoreGraphics calls.
    CGPoint point;
    CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)code.corners[0], &point);
    
    // 6 Begin the path at the corner defined in Step 5.
    CGPathMoveToPoint(cornersPath, nil, point.x, point.y);
    
    // 7 Loop through the other three corners, creating the path as you go.
    for (int i = 1; i < code.corners.count; i++) {
        CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)code.corners[i], &point);
        CGPathAddLineToPoint(cornersPath, nil, point.x, point.y);
    }
    
    // 8 Close the path by joining the fourth point to the first point.
    CGPathCloseSubpath(cornersPath);
    
    // 9  Create a UIBezierPath object from cornersPath and store it in the Barcode object
    
    barcode.cornersPath = [UIBezierPath bezierPathWithCGPath:cornersPath];
    CGPathRelease(cornersPath);
    
    // Create the path for the code's bounding box
    
    // 10 Create the bounding box path using bezierPathWithRect:.
    barcode.boundingBoxPath = [UIBezierPath bezierPathWithRect:code.bounds];
    
    // 11  Finally, return the Barcode object.
    return barcode;
}

#pragma mark notification center methods

- (void)applicationWillEnterForeground:(NSNotification*)note
{
    [self startRunning];
}

- (void)applicationDidEnterBackground:(NSNotification*)note
{
    [self stopRunning];
}


#pragma mark action methods
- (IBAction)doStop:(id)sender
{
    [self stopRunning];
    NSString *value = _keys[0];
    _lblContents.text = [[NSString alloc] initWithFormat:@"> %@",value];
}

- (IBAction)doStart:(id)sender
{
    [self startRunning];
}

@end
