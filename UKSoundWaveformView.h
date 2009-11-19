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

@end
