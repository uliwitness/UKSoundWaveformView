//
//  UKSoundWaveformViewAppDelegate.h
//  UKSoundWaveformView
//
//  Created by Uli Kusterer on 20.09.09.
//  Copyright 2009 The Void Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UKSoundWaveformView.h"


@interface UKSoundWaveformViewAppDelegate : NSObject <NSApplicationDelegate>
{
    NSWindow			*		window;
	UKSoundWaveformView	*		waveformView;
}

@property (assign) IBOutlet NSWindow			*	window;
@property (assign) IBOutlet UKSoundWaveformView	*	waveformView;

@end
