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
	BOOL					mAdjustsToWidth;
	NSColor*				mBackgroundColor;
	NSColor*				mWaveformColor;
	NSGradient*				mBackgroundGradient;
	NSGradient*				mWaveformGradient;
	CGFloat					mCornerRadius;
	CGFloat					mVerticalPadding;
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
		ivars->mAdjustsToWidth = NO;
		ivars->mBackgroundColor = [[NSColor whiteColor] retain];
		ivars->mWaveformColor = [[NSColor blackColor] retain];
		ivars->mBackgroundGradient = nil;
		ivars->mWaveformGradient = nil;
		ivars->mCornerRadius = 0.0;
		ivars->mVerticalPadding = 0.0;
    }
    return self;
}


-(void)	dealloc
{
	if( ivars )
	{
		DESTROY(ivars->mAudioData);
		DESTROY(ivars->mBackgroundColor);
		DESTROY(ivars->mWaveformColor);
		DESTROY(ivars->mBackgroundGradient);
		DESTROY(ivars->mWaveformGradient);
		
		free( ivars );
		ivars = NULL;
	}
	
	[super dealloc];
}


- (void)drawRect: (NSRect)rectToRedraw
{
	NSRect	theBox = [self bounds];
	theBox.origin.x = rectToRedraw.origin.x;
	theBox.size.width = rectToRedraw.size.width;
	
	NSBezierPath *bezierPath = [NSBezierPath bezierPathWithRoundedRect: theBox 
															   xRadius: ivars->mCornerRadius 
															   yRadius: ivars->mCornerRadius];
	
	if( ivars->mBackgroundGradient ) 
	{
		[ivars->mBackgroundGradient	drawInBezierPath: bezierPath angle: 90.0];
	}
	else
	{
		[ivars->mBackgroundColor set];
		[bezierPath fill];
	}
	
	[self setUpClippingPathWithWaveformInDirtyRect: rectToRedraw];
	
	if( ivars->mWaveformGradient ) 
	{
		[ivars->mWaveformGradient  drawInBezierPath: bezierPath angle: 90.0];
	}
	else
	{
		[ivars->mWaveformColor set];
		[bezierPath fill];
	}
	
	CGContextRef	ctx = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextRestoreGState( ctx );
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


-(void)	setAdjustsToWidth:	(BOOL)adjustsToWidth
{
	ivars->mAdjustsToWidth = adjustsToWidth;
}


-(BOOL)	adjustsToWidth
{
	return ivars->mAdjustsToWidth;
}


-(void)	setBackgroundColor: (NSColor *)color
{
	NSColor *currentColor = ivars->mBackgroundColor;
	if( currentColor != color) 
	{
		ivars->mBackgroundColor = [color retain];
		[currentColor release];
	}
}


-(NSColor *)	backgroundColor
{
	return ivars->mBackgroundColor;
}


-(void)	setWaveformColor: (NSColor *)color
{
	NSColor *currentColor = ivars->mWaveformColor;
	if( currentColor != color) 
	{
		ivars->mWaveformColor = [color retain];
		[currentColor release];
	}
	
}


-(NSColor *)	waveformColor
{
	return ivars->mWaveformColor;
}


-(void)	setBackgroundGradient: (NSGradient *)gradient
{
	NSGradient *currentGradient = ivars->mBackgroundGradient;
	if( currentGradient != gradient) 
	{
		ivars->mBackgroundGradient = [gradient retain];
		[currentGradient release];
	}
}


-(NSGradient *)	backgroundGradient
{
	return ivars->mBackgroundGradient;
}


-(void)	setWaveformGradient: (NSGradient *)gradient
{
	NSGradient *currentGradient = ivars->mWaveformGradient;
	if( currentGradient != gradient) 
	{
		ivars->mWaveformGradient = [gradient retain];
		[currentGradient release];
	}
	
}


-(NSGradient *)	waveformGradient
{
	return ivars->mWaveformGradient;
}


-(void)	setCornerRadius: (CGFloat)cornerRadius
{
	ivars->mCornerRadius = cornerRadius;
}


-(CGFloat)	cornerRadius
{
	return ivars->mCornerRadius;
}


-(void)	setVerticalPadding: (CGFloat)padding
{
	ivars->mVerticalPadding = padding;
}


-(CGFloat)	verticalPadding
{
	return ivars->mVerticalPadding;
}


-(void) setUpClippingPathWithWaveformInDirtyRect: (NSRect)rectToRedraw
{
	NSRect			theBounds = [self bounds];
	int				pixelsWide = rectToRedraw.size.width,
	pixelsHigh = theBounds.size.height - (ivars->mVerticalPadding * 2);
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
		
		CGFloat samplesPerPixel;
		if ( ivars->mAdjustsToWidth )
		{
			samplesPerPixel = floorf([ivars->mAudioData frameCount] / [self bounds].size.width);
		} 
		else 
		{
			samplesPerPixel = ivars->mSamplesPerPixel;
		}
		
		if( accumulatedSampleCount >= samplesPerPixel )
		{
			//int		avgLineHeight = (accumulatedSamples / accumulatedSampleCount) * pixelsHigh;
			int		maxLineHeight = maxSample * pixelsHigh;
			if( maxLineHeight > pixelsHigh )
				maxLineHeight = pixelsHigh;
			if( maxLineHeight < 1 )
				maxLineHeight = 1;
			int		offset = ((pixelsHigh -maxLineHeight) / 2);
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
	
	CGRect		box = CGRectMake( rectToRedraw.origin.x, theBounds.origin.y + ivars->mVerticalPadding, pixelsWide, pixelsHigh );	
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
