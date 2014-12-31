//
//  AppDelegate.m
//  LightSensor
//
//  Created by Andrew Luo on 12/30/14.
//  Copyright (c) 2014 Andrew Luo. All rights reserved.
//

#import "AppDelegate.h"
#include <IOKit/graphics/IOGraphicsLib.h>


@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate
const int kMaxDisplays = 16;
const CFStringRef kDisplayBrightness = CFSTR(kIODisplayBrightnessKey);


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [self.serialPort close];
}

- (IBAction)startCommand:(id)sender {
    ORSSerialPort *port = [ORSSerialPort serialPortWithPath:@"/dev/cu.usbmodem1411"];
    self.serialPort = port;
    [self.serialText setNeedsDisplay:YES];
    [self.serialPort setDelegate:self];
    [self.serialPort open];
}

- (IBAction)stopCommand:(id)sender {
    [self.serialPort close];
}

// Sets the brightness of the screen to the new brightness, float input range between 0.0 and 1.0
// almost completely from: http://mattdanger.net/2008/12/adjust-mac-os-x-display-brightness-from-the-terminal/
- (void) set_brightness:(float) new_brightness {
    CGDirectDisplayID display[kMaxDisplays];
    CGDisplayCount numDisplays;
    CGDisplayErr err;
    err = CGGetActiveDisplayList(kMaxDisplays, display, &numDisplays);
    
    if (err != CGDisplayNoErr)
        printf("cannot get list of displays (error %d)\n",err);
    for (CGDisplayCount i = 0; i < numDisplays; ++i) {
        
        
        CGDirectDisplayID dspy = display[i];
        CFDictionaryRef originalMode = CGDisplayCurrentMode(dspy);
        if (originalMode == NULL)
            continue;
        io_service_t service = CGDisplayIOServicePort(dspy);
        
        float brightness;
        err= IODisplayGetFloatParameter(service, kNilOptions, kDisplayBrightness,
                                        &brightness);
        if (err != kIOReturnSuccess) {
            fprintf(stderr,
                    "failed to get brightness of display 0x%x (error %d)",
                    (unsigned int)dspy, err);
            continue;
        }
        
        err = IODisplaySetFloatParameter(service, kNilOptions, kDisplayBrightness,
                                         new_brightness);
        if (err != kIOReturnSuccess) {
            fprintf(stderr,
                    "Failed to set brightness of display 0x%x (error %d)",
                    (unsigned int)dspy, err);
            continue;
        }
        
        if(brightness > 0.0){
        }else{
        }
    }
}

//Delegate function for ORSSerialPort, called whenever data is received in the serial port
//Reads the light sensor value and adjusts the screen brightness accordingly
- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if([string length] == 0) return;
    [self.serialText.textStorage.mutableString appendString:string];
    float screenBrightness = 1000.0;
    unichar last = [string characterAtIndex:[string length] - 1];
    if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:last]) {
        NSRange rangeToSearch = NSMakeRange(0, [self.serialText.textStorage.mutableString length] - 1);
        NSRange rangeOfSecondToLastNewline = [self.serialText.textStorage.mutableString rangeOfString:@"\n" options:NSBackwardsSearch range:rangeToSearch];
        NSString *lastPathComponent = nil;
        if (rangeOfSecondToLastNewline.location != NSNotFound) {
            lastPathComponent = [self.serialText.textStorage.mutableString substringFromIndex:rangeOfSecondToLastNewline.location + 1];
            screenBrightness = screenBrightness - lastPathComponent.floatValue;
        }
    }
    screenBrightness = screenBrightness/1000.0;
    [self set_brightness:screenBrightness];
    [self.serialText scrollRangeToVisible:NSMakeRange([[self.serialText string] length], 0)];
    [self.serialText setNeedsDisplay:YES];
}

- (void)serialPortWasRemovedFromSystem:(ORSSerialPort *)serialPort;
{
    self.serialPort = nil;
}


@end
