//
//  XTWaterfallView.h
//  MacHPSDR
//  Copyright (c) 2010 - Jeremy C. McDermond (NH6Z)

// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

// $Id$

#import <Cocoa/Cocoa.h>
#include <QuartzCore/CoreAnimation.h>

@class XTPanadapterDataMUX;
@class XTPanAdapterView;
@class TransceiverController;
@class XTWaterfallLayer;

#define SPECTRUM_BUFFER_SIZE 4096
#define WATERFALL_SIZE 4096

@interface XTWaterfallView : NSView {
			
	IBOutlet XTPanadapterDataMUX *dataMux;
	IBOutlet TransceiverController *transceiverController;
			
	BOOL dragging;
	
	float hzPerUnit;
	float zoomFactor;
		
	BOOL flowsUp;
	
	XTWaterfallLayer *waterfallLayer;
	CAScrollLayer *rootLayer;
}

@property BOOL flowsUp;
@property float zoomFactor;

-(void)doDefaultsNotification:(NSNotification *)notification;

@end
