IOS7QRCodeDemo
==============

A small demo that reads a qr code off the camera and displays to the screen the contents. No 3rd party code, just code straight from IOS7 AVFoundation framework

This demo app uses the new stuff (10/2013) in the AV Foundation that is now available in IOS7. 

iOS 7 brings improvements to the AV Foundation, such as:
• Barcode reading support
• Speech synthesis
• Improved zoom functionality

This demo calls up a screen with a start and stop button toggle the camera on and off. When stop is pressed, the contents of the QR Code is then displayed on a UILabel on the screen. This app is not pretty, nor was it meant to be. This is just a concept demo.

Granted, I got my information from some tutorials I purchased through Ray Wenderlich. If you don't know who Ray Wenderlich is, I suggest that you get from the rock you have been living under. Do yourself a favor and throw $50 his way purchase a .zip file with sample code and a .pdf that explains the tutorials.

Anyway, in that zip file, there is a tutorial available that will teach you how to use the camera, read a qr code, and then take the contents of the camera and have the speech synthesizer read it back to you (as best as it could). Thats all fine and dandy but I just needed the QR code contents so I can call a webservice. So, this demo is some of tutorial code, redefined to grab the data and show it to you. Watch the NSLogs as you run this thing.

Enjoy.