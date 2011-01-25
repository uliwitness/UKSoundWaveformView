//
//  UKSoundWaveformView.h
//  UKSoundWaveformView
//
//  Created by Uli Kusterer on 20.09.09.
//  Copyright 2009 The Void Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class UKAudioBufferList;


@interface UKSoundWaveformView : NSView
{
	struct UKSoundWaveformViewIVars*	ivars;
}

-(void)					setAudioData: (UKAudioBufferList*)theData;
-(UKAudioBufferList*)	audioData;

-(NSSize)				bestSize;

-(void)					setAdjustsToWidth:(BOOL)adjustsToWidth;
-(BOOL)					adjustsToWidth;

-(void)					setBackgroundColor:(NSColor *)color;
-(NSColor *)			backgroundColor;

-(void)					setWaveformColor:(NSColor *)color;
-(NSColor *)			waveformColor;

-(void)					setBackgroundGradient:(NSGradient *)gradient;
-(NSGradient *)			backgroundGradient;

-(void)					setWaveformGradient:(NSGradient *)gradient;
-(NSGradient *)			waveformGradient;

-(void)					setCornerRadius:(CGFloat)cornerRadius;
-(CGFloat)				cornerRadius;

-(void)					setVerticalPadding:(CGFloat)padding;
-(CGFloat)				verticalPadding;

@end
