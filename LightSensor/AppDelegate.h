//
//  AppDelegate.h
//  LightSensor
//
//  Created by Andrew Luo on 12/30/14.
//  Copyright (c) 2014 Andrew Luo. All rights reserved.
//

#import "ORSSerialPort.h"
#import <Cocoa/Cocoa.h>

@class ORSSerialPortManager;


@interface AppDelegate : NSObject <NSApplicationDelegate, ORSSerialPortDelegate>
@property (nonatomic, strong) ORSSerialPort *serialPort;
@property (unsafe_unretained) IBOutlet NSTextView *serialText;

- (IBAction)startCommand:(id)sender;
- (IBAction)stopCommand:(id)sender;
- (void) set_brightness:(float)new_brightness;


@end

