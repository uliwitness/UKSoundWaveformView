//
//  UKSoundWaveform.m
//  UKSoundWaveformView
//
//  Created by Uli Kusterer on 20.09.09.
//  Copyright 2009 The Void Software. All rights reserved.
//

#import "UKSoundWaveform.h"


#define _ThrowExceptionIfErr(context,err)	do { if( err != noErr ) [NSException raise: @"UKSoundWaveformException" format: @"Error: " context " with code %d.", (err)]; } while(0)


@implementation UKSoundWaveform

-(id)	initWithContentsOfFile: (NSString*)resourcePath
{
	if(( self = [super init] ))
	{
		Float64				kGraphSampleRate = 44100.0; // Our internal sample rate
		OSStatus			err = noErr;
		FSRef				theRef;

		@try
		{
			NSURL *fileURL = [NSURL fileURLWithPath: resourcePath];
			if(!CFURLGetFSRef((CFURLRef)fileURL, &theRef))
				@throw [NSException exceptionWithName:@"Exception" reason:@"CFURLGetFSRef == false" userInfo:nil];

			err = ExtAudioFileOpen(&theRef, &xafref);
			_ThrowExceptionIfErr(@"ExtAudioFileOpen", err);

			UInt32 propSize;

			AudioStreamBasicDescription clientFormat;
			propSize = sizeof(clientFormat);

			err = ExtAudioFileGetProperty(xafref, kExtAudioFileProperty_FileDataFormat, &propSize, &clientFormat);
			_ThrowExceptionIfErr(@"kExtAudioFileProperty_FileDataFormat", err);

			// If you need to alloc a buffer, you'll need to alloc filelength*channels*rateRatio bytes
			//double rateRatio = kGraphSampleRate / clientFormat.mSampleRate;
			data = malloc( rateRatio * 2 *  );

			// read as 44.1kHz 2Ch audio in  this example
			clientFormat.mSampleRate = kGraphSampleRate;
			clientFormat.SetCanonical(2, true);

			propSize = sizeof(clientFormat);
			err = ExtAudioFileSetProperty(xafref, kExtAudioFileProperty_ClientDataFormat, propSize, &clientFormat);
			_ThrowExceptionIfErr(@"kExtAudioFileProperty_ClientDataFormat", err);

			UInt32 numPackets = kSegmentSize; // Frames to read (might be filelength (in frames) to read the whole file)
			UInt32 samples = numPackets << 1; // 2 channels (samples) per frame

			AudioBufferList bufList;
			bufList.mNumberBuffers = 1;
			bufList.mBuffers[0].mNumberChannels = 2; // Always 2 channels in this example
			bufList.mBuffers[0].mData = data; // data is a pointer (float*) to our sample buffer
			bufList.mBuffers[0].mDataByteSize = samples * sizeof(Float32);

			UInt32 loadedPackets = numPackets;
			err = ExtAudioFileRead(xafref, &loadedPackets, &bufList);
			if (err) 
			{
				_ThrowExceptionIfErr(@"ExtAudioFileRead", err);
			}

			ExtAudioFileDispose(xafref);
		}
		@catch(NSException* exception)
		{
			if(data)
				free(data);
			data = nil;

			if(xafref)
				ExtAudioFileDispose(xafref);

			NSLog(@"loadSegment: Caught %@: %@", [exception name], [exception reason]);
		}
	}
	
	return self;
}

@end
