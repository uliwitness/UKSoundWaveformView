//
//  UKSoundWaveformView.m
//  UKSoundWaveformView
//
//  Created by Uli Kusterer on 20.09.09.
//  Copyright 2009 The Void Software. All rights reserved.
//

#import "UKSoundWaveformView.h"
#import "UKAudioBufferList.h"
#import "UKHelperMacros.h"


struct UKSoundWaveformViewIVars
{
	UKAudioBufferList*		mAudioData;
	CGFloat					mSamplesPerPixel;
};


void	UKSetUpMaskFromChannel( NSRect inBox, NSRect rectToRedraw );


@interface UKSoundWaveformView ()

-(void) setUpClippingPathWithWaveformInDirtyRect: (NSRect)rectToRedraw;

@end



@implementation UKSoundWaveformView

-(id)	initWithFrame: (NSRect)frame
{
    self = [super initWithFrame: frame];
    if( self )
	{
		ivars = calloc( 1, sizeof(struct UKSoundWaveformViewIVars) );
        ivars->mSamplesPerPixel = 100;
    }
    return self;
}


-(void)	dealloc
{
	if( ivars )
	{
		DESTROY(ivars->mAudioData);
		
		free( ivars );
		ivars = NULL;
	}
	
	[super dealloc];
}


- (void)drawRect: (NSRect)rectToRedraw
{
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect: rectToRedraw];
	
	[self setUpClippingPathWithWaveformInDirtyRect: rectToRedraw];
	
	#if 0
	[[NSColor blackColor] set];
	[NSBezierPath fillRect: rectToRedraw];
	#else
	NSGradient*		theGradient = [[[NSGradient alloc] initWithColors:
										[NSArray arrayWithObjects:
											[NSColor blackColor],
											[NSColor darkGrayColor],
											[NSColor blackColor],
										nil]] autorelease];
	NSRect		theBox = [self bounds];
	theBox.origin.x = rectToRedraw.origin.x;
	theBox.size.width = rectToRedraw.size.width;
	[theGradient drawInRect: theBox angle: 90];
	#endif
	
	CGContextRef		ctx = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextRestoreGState( ctx );
	
	// Draw it:
//	[[NSColor blackColor] set];
//	[thePath fill];
}

-(void)		setAudioData: (UKAudioBufferList*)theData
{
	if( ivars->mAudioData != theData )
	{
		[ivars->mAudioData release];
		ivars->mAudioData = [theData retain];
		
		[self setNeedsDisplay: YES];
	}
}


-(UKAudioBufferList*)	audioData
{
	return ivars->mAudioData;
}


-(NSSize)	bestSize
{
	NSSize		theSize = [self bounds].size;
	
	theSize.width = ceilf([ivars->mAudioData frameCount] / ivars->mSamplesPerPixel);
	
	return theSize;
}


-(void) setUpClippingPathWithWaveformInDirtyRect: (NSRect)rectToRedraw
{
	NSRect			theBounds = [self bounds];
	int				pixelsWide = rectToRedraw.size.width,
					pixelsHigh = theBounds.size.height;
	NSMutableData*	maskData = [NSMutableData dataWithLength: pixelsWide * pixelsHigh * sizeof(float)];
	float*			currPixel = (float*) [maskData mutableBytes];
	NSInteger		currFrameIdx = 0;
    NSInteger		numFrames = [ivars->mAudioData frameCount];
	float			maxSample = 0;
	NSInteger		accumulatedSampleCount = 0;
	int				currX = 0;
	int				accumulatedSamples = 0;
	
	currFrameIdx = (rectToRedraw.origin.x -theBounds.origin.x) * ivars->mSamplesPerPixel;
	
	for( ; currFrameIdx < numFrames; currFrameIdx++ )
	{
		accumulatedSampleCount ++;
		float	currSample = fabsf( [ivars->mAudioData frameAtIndex: currFrameIdx] );
		if( currSample > maxSample )
			maxSample = currSample;
		accumulatedSamples += currSample;
		if( accumulatedSampleCount >= ivars->mSamplesPerPixel )
		{
			//int		avgLineHeight = (accumulatedSamples / accumulatedSampleCount) * pixelsHigh;
			int		maxLineHeight = maxSample * pixelsHigh;
			if( maxLineHeight > pixelsHigh )
				maxLineHeight = pixelsHigh;
			if( maxLineHeight < 1 )
				maxLineHeight = 1;
			int		offset = (pixelsHigh -maxLineHeight) / 2;
			for( int currY = offset; currY < (maxLineHeight +offset); currY++ )
				currPixel[(currY * pixelsWide) +currX] = 1.0;
			accumulatedSampleCount = 0;
			accumulatedSamples = 0;
			maxSample = 0;
			currX++;
		}
		
		if( currX >= pixelsWide )
			break;
	}

	// Create a mask from our pixel map:
	CGContextRef		ctx = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSaveGState( ctx );
	CGColorSpaceRef		colorSpace = CGColorSpaceCreateDeviceGray();
	CGDataProviderRef	dataProvider = CGDataProviderCreateWithCFData( (CFDataRef) maskData );
	
	CGRect		box = CGRectMake( rectToRedraw.origin.x, theBounds.origin.y, pixelsWide, pixelsHigh );	
	CGImageRef	maskImage = CGImageCreate( pixelsWide, pixelsHigh, sizeof(float) * 8, sizeof(float) * 8,
													pixelsWide * sizeof(float), colorSpace,
													kCGBitmapFloatComponents | kCGBitmapByteOrder32Host,
													dataProvider, NULL, true,
													kCGRenderingIntentDefault );
	CGContextClipToMask( ctx, box, maskImage );
	
	CGDataProviderRelease( dataProvider );
	CGColorSpaceRelease( colorSpace );
	CGImageRelease( maskImage );
}

@end
