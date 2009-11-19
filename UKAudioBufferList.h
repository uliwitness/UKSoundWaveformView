//
//  UKAudioBufferList.h
//  UKSoundWaveformView
//
//  Created by Uli Kusterer on 07.10.09.
//  Copyright 2009 The Void Software. All rights reserved.
//

/*
	Object to hold and read a bunch of audio samples read from a UKExtAudioFile.
	This is a thin wrapper around an AudioBufferList.
*/

#import <Cocoa/Cocoa.h>


@interface UKAudioBufferList : NSObject
{
	struct UKAudioBufferListIVars*	ivars;
}

-(id)			initWithCapacity: (NSUInteger)numFrames audioFormat: (void*)streamDesc;	// streamDesc is an AudioStreamBasicDescription*

-(void*)		bufferList;	// AudioBufferList* containing one buffer for initial filling. After that, this object is immutable!
					// If you change this, be sure to call setFrameCount: to make it match.

-(void)			setFrameCount: (NSInteger)fc;	// MUST BE <= capacity! Only for initial filling. After that, this object is immutable!
-(NSInteger)	frameCount;	// # of frames in this buffer list instance.

-(float)		frameAtIndex: (NSInteger)idx;	// Read one frame's level.

@end
