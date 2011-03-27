//
//  SystemAudioThread.m
//  MacHPSDR
//
//  Copyright (c) 2010 - Jeremy C. McDermond (NH6Z)

// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

// $Id$

#import "SystemAudioThread.h"
#import "XTAudioUnitGraph.h"
#import "XTAudioUnit.h"
#import "XTAudioUnitNode.h"
#import "XTAudioComponent.h"
#import "XTOutputAudioUnit.h"

#include <mach/semaphore.h>

@implementation SystemAudioThread

@synthesize running;

-(id)initWithBuffer:(OzyRingBuffer *) _buffer{
	self = [super init];
	if(self) {
		buffer = _buffer;
		running = NO;
	}
	
	return self;
}

-(void)main {	
	[self setupAudio];

	[NSThread setThreadPriority:1.0];
		
	//  You need a dummy port added to the run loop so that the thread doesn't freak out
	[[NSRunLoop currentRunLoop] addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
	
	running = YES;
	while(running == YES)
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];

}

-(void)setupAudio {	
	OSStatus error;
	
	NSLog(@"Creating Audio Units\n");
	XTOutputAudioUnit *defaultOutputUnit = [XTOutputAudioUnit defaultOutputAudioUnit];
	
	NSLog(@"Setting the render callback\n");
	AURenderCallbackStruct renderCallback;
	renderCallback.inputProc = audioUnitCallback;
	renderCallback.inputProcRefCon = self;
	
	error = [defaultOutputUnit setCallback:&renderCallback];
	if(error != noErr) {
		NSLog(@"%@:%s Error setting callback: %s\n", [self class], (char *) _cmd, GetMacOSStatusErrorString(error));
	}	
	
	AudioStreamBasicDescription format;
	format.mSampleRate = 192000.0;
	format.mFormatID = kAudioFormatLinearPCM;
	format.mFormatFlags = kAudioFormatFlagIsFloat | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;
	format.mBytesPerPacket = 8;
	format.mBytesPerFrame = 8;
	format.mFramesPerPacket = 1;
	format.mChannelsPerFrame = 2;
	format.mBitsPerChannel = 32;

	NSLog(@"Setting input format\n");
	error = [defaultOutputUnit setInputFormat:&format];
	if(error != noErr) {
		NSLog(@"%@:%s Error setting callback: %s\n", [self class], (char *) _cmd, GetMacOSStatusErrorString(error));
	}	
	
	NSLog(@"Setting up slice size\n");
	[defaultOutputUnit setMaxFramesPerSlice:8192];
	
	NSLog(@"Initializing the audio unit\n");
	[defaultOutputUnit initialize];
	NSLog(@"Starting the audio unit\n");
	[defaultOutputUnit start];	
	[buffer clear];
		
}

-(void)fillAUBuffer: (AudioBuffer *) auBuffer {
	
	NSData *audioBuffer = [buffer waitForSize: auBuffer->mDataByteSize];
	if(audioBuffer == NULL) {
		NSLog(@"[SystemAudioThread fillBuffer]: Couldn't get a fresh buffer.\n");
		return;
	}
	
	memcpy(auBuffer->mData, [audioBuffer bytes], [audioBuffer length]);
	
	return;
}

-(void) auProperties {
	//  Pop up windows for all the Audio Units
	for(XTAudioUnitNode *currentNode in [audioGraph nodes]) {
		[[currentNode unit] cocoaWindow];
	}	
}

@end

OSStatus audioUnitCallback (void *userData, AudioUnitRenderActionFlags *actionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData) {
	SystemAudioThread *self = (SystemAudioThread *) userData;
		
	int i;
	for(i = 0; i < ioData->mNumberBuffers; ++i) {
		[self fillAUBuffer: &(ioData->mBuffers[i])];
	}
	
	return kIOReturnSuccess;
}