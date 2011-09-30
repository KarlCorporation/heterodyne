//
//  XTPanAdapterView.h
//  MacHPSDR
//
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
#import <QuartzCore/CoreAnimation.h>

@class XTMainWindowController;
@class XTWorkerThread;
@class XTPanadapterLayer;
@class XTPanadapterDataMUX;
@class XTWaterfallView;

@interface XTPanadapterLayer : CAOpenGLLayer {
	XTPanadapterDataMUX *dataMUX;
    
    GLuint vertexBuffer;
	
	float highLevel, lowLevel;
    
}

@property XTPanadapterDataMUX *dataMUX;
@property float highLevel;
@property float lowLevel;

@end

@interface XTPanAdapterView : NSView {
	
	XTWorkerThread *updateThread;
	
	float subPosition;
	float hzPerUnit;
    float dbPerUnit;
		
	CALayer *rootLayer;
	CALayer *tickLayer;
	CALayer *frequencyLayer;
	XTPanadapterLayer *waveLayer;
	
	NSBezierPath *path;
	
	NSRect filterRect, leftFilterBoundaryRect, rightFilterBoundaryRect;
	NSRect subFilterRect, subFilterHotRect, leftSubFilterBoundaryRect, rightSubFilterBoundaryRect;
	
	BOOL dragging;
	BOOL startedRight;
	BOOL startedLeft;
	BOOL startedSubLeft;
	BOOL startedSubRight;
	BOOL startedSub;
		
	float lowLevel, highLevel;
	
	IBOutlet XTPanadapterDataMUX *dataMux;
}

@property float lowLevel;
@property float highLevel;
@property IBOutlet XTMainWindowController *windowController;

-(void)doNotification: (NSNotification *) notification;

-(void) observeValueForKeyPath: (NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context: (void *) context;
@end
