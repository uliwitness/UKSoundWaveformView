//
//  UKExtAudioFile.h
//  UKSoundWaveformView
//
//  Created by Uli Kusterer on 07.10.09.
//  Copyright 2009 The Void Software. All rights reserved.
//

/*
	A thin wrapper around ExtAudioFile. Opens a file at a URL, and lets you
	extract audio samples from it.
*/

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>


// -----------------------------------------------------------------------------
//	Forwards:
// -----------------------------------------------------------------------------

@class UKAudioBufferList;


// -----------------------------------------------------------------------------
//	UKExtAudioFile:
// -----------------------------------------------------------------------------

@interface UKExtAudioFile : NSObject
{
	struct UKExtAudioFileIVars*	ivars;
}

-(id)	initWithContentsOfURL: (NSURL*)fileURL;

-(UKAudioBufferList*)	framesFromIndex: (long long)firstIdx numItems: (NSInteger)count;
-(long long)			frameCount;	// total # of frames in file.

@end
