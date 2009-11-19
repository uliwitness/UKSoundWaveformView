//
//  UKSoundWaveformViewAppDelegate.m
//  UKSoundWaveformView
//
//  Created by Uli Kusterer on 20.09.09.
//  Copyright 2009 The Void Software. All rights reserved.
//

#import "UKSoundWaveformViewAppDelegate.h"
#import "UKExtAudioFile.h"
#import "UKHelperMacros.h"

@implementation UKSoundWaveformViewAppDelegate

@synthesize window, waveformView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSString*		thePath = [@"~/testsound.aiff" stringByExpandingTildeInPath];
	NSURL*			theURL = [NSURL fileURLWithPath: thePath];
	UKExtAudioFile*	audioFile = [[[UKExtAudioFile alloc] initWithContentsOfURL: theURL] autorelease];
	
	long long			numFrames = [audioFile frameCount];
	UKAudioBufferList*	buf = [audioFile framesFromIndex: 0 numItems: numFrames];
	//NSLog( @"%@", buf );
	
	[waveformView setAudioData: buf];
	NSRect		newBox = [waveformView frame];
	newBox.size.width = [waveformView bestSize].width;
	[waveformView setFrame: newBox];
	
	//NSLog( @"%@", PROPERTY(frame) );
}

@end
