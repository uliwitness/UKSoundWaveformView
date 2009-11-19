//
//  UKExtAudioFile.m
//  UKSoundWaveformView
//
//  Created by Uli Kusterer on 07.10.09.
//  Copyright 2009 The Void Software. All rights reserved.
//

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#import "UKExtAudioFile.h"
#import "UKHelperMacros.h"
#import "UKAudioBufferList.h"
#import <AudioToolbox/AudioToolbox.h>


// -----------------------------------------------------------------------------
//	Instance vars:
// -----------------------------------------------------------------------------

struct UKExtAudioFileIVars
{
	ExtAudioFileRef				mAudioFileRef;		// Reference to the audio file object while we have it opened.
	NSURL*						mFileURL;			// URL of our file.
	AudioStreamBasicDescription	mReadingFormat;		// Format in which we get data from the audio file.
};

@implementation UKExtAudioFile

-(id)	initWithContentsOfURL: (NSURL*)fileURL
{
	if(( self = [super init] ))
	{
		ivars = calloc( 1, sizeof(struct UKExtAudioFileIVars) );
		
		ivars->mFileURL = [fileURL retain];
		
		OSStatus err = ExtAudioFileOpenURL( (CFURLRef)ivars->mFileURL, &ivars->mAudioFileRef );
		if( err != noErr )
		{
			[self release];
			return nil;
		}

		AudioStreamBasicDescription	desiredFormat = { 44100.0, kAudioFormatLinearPCM,
													kAudioFormatFlagsNativeFloatPacked,
													sizeof(float), 1, sizeof(float),
													1, sizeof(float) * 8 };
		ivars->mReadingFormat = desiredFormat;
		if( ExtAudioFileSetProperty( ivars->mAudioFileRef, kExtAudioFileProperty_ClientDataFormat, 
										sizeof(ivars->mReadingFormat), &ivars->mReadingFormat ) != noErr )
		{
			[self release];
			return nil;
		}
	}
	
	return self;
}


-(void)	dealloc
{
	if( ivars )
	{
		if( ivars->mAudioFileRef != NULL )
			ExtAudioFileDispose( ivars->mAudioFileRef );
		
		DESTROY(ivars->mFileURL);
		
		free( ivars );
		ivars = NULL;
	}
	
	[super dealloc];
}


-(UKAudioBufferList*)	framesFromIndex: (long long)firstIdx numItems: (NSInteger)count
{
	if( ExtAudioFileSeek( ivars->mAudioFileRef, firstIdx ) != noErr )
		return nil;
	
	UInt32				numFramesRead = count;
	UKAudioBufferList*	bufList = [[UKAudioBufferList alloc] initWithCapacity: numFramesRead audioFormat: &ivars->mReadingFormat];
	if( ExtAudioFileRead( ivars->mAudioFileRef, &numFramesRead, [bufList bufferList] ) != noErr )
	{
		[bufList release];
		return nil;
	}
	
	[bufList setFrameCount: numFramesRead];	// Make sure buffer list knows how much was actually read.
	
	return [bufList autorelease];
}


-(long long)	frameCount
{
	SInt64		frameCount = 0;
	
	UInt32		propSize = sizeof(SInt64);
	if( ExtAudioFileGetProperty( ivars->mAudioFileRef, kExtAudioFileProperty_FileLengthFrames, &propSize, &frameCount ) != noErr )
		frameCount = -1;
	
	return frameCount;
}


@end
