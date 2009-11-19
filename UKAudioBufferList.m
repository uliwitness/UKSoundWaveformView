//
//  UKAudioBufferList.m
//  UKSoundWaveformView
//
//  Created by Uli Kusterer on 07.10.09.
//  Copyright 2009 The Void Software. All rights reserved.
//

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#import "UKAudioBufferList.h"
#import "UKHelperMacros.h"
#import <AudioToolbox/AudioToolbox.h>


// -----------------------------------------------------------------------------
//	Instance vars:
// -----------------------------------------------------------------------------

struct UKAudioBufferListIVars
{
	AudioBufferList				mBufList;
	AudioStreamBasicDescription	mAudioFormat;
	NSInteger					mUsedFrameCount;
	char						mRawData[1];		// Variable-size array at end of struct where we put the data.
};


@implementation UKAudioBufferList

-(id)	initWithCapacity: (NSUInteger)numFrames audioFormat: (void*)streamDesc
{
	if(( self = [super init] ))
	{
		NSInteger		dataByteSize = (*(AudioStreamBasicDescription*)streamDesc).mBytesPerFrame * numFrames;
		ivars = calloc( 1, sizeof(struct UKAudioBufferListIVars) -1 +dataByteSize );
		ivars->mAudioFormat = *(AudioStreamBasicDescription*)streamDesc;
		ivars->mBufList.mNumberBuffers = 1;
		ivars->mBufList.mBuffers[0].mDataByteSize = dataByteSize;
		ivars->mBufList.mBuffers[0].mData = ivars->mRawData;	// Point to the chunk of data we appended to this struct.
	}
	
	return self;
}


-(void)	dealloc
{
	if( ivars )
	{
		free( ivars );	// mBuffers[0].mData points into the ivars buffer, so we only have to release one chunk of memory.
		ivars = NULL;
	}
	
	[super dealloc];
}


-(NSInteger)	frameCount
{
	return ivars->mUsedFrameCount;
}


-(void)			setFrameCount: (NSInteger)fc
{
	ivars->mUsedFrameCount = fc;
}


-(void*)	bufferList
{
	return &ivars->mBufList;
}


-(float)	frameAtIndex: (NSInteger)idx
{
	NSAssert( ivars->mBufList.mNumberBuffers <= 1, @"UKAudioBufferList -frameAtIndex: Can't work with this buffer count." );
	NSAssert( idx < ivars->mUsedFrameCount, @"UKAudioBufferList -frameAtIndex: Frame index out of range." );
	
	// TODO: Make this work with other audio formats than PCM mono floats:
	float*		samples = (float*)ivars->mBufList.mBuffers[0].mData;
	
	return samples[idx];
}


-(NSString*)	description
{
	NSMutableString*	str = [NSMutableString stringWithFormat: @"%@ {\n", [self class]];
	
	NSAssert( ivars->mBufList.mNumberBuffers <= 1, @"UKAudioBufferList -description: outdated, can't work with this buffer count." );
	
	float*		samples = (float*)ivars->mBufList.mBuffers[0].mData;
	for( long long x = 0; x < ivars->mUsedFrameCount; x++ )
	{
		[str appendFormat: @"%f", samples[x]];
		if( x != ivars->mUsedFrameCount )
			[str appendFormat: @",%c", (((x+1) % 4 == 0) ? '\n' : ' ')];
	}
	
	[str appendString: @"\n}"];
	
	return str;
}

@end
