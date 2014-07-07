//
//  BLFractalTextureView.m
//  FractalTerrainTextureGen
//
//  Created by admin on 04/07/14.
//  Copyright (c) 2014 Alexander.Sviridov. All rights reserved.
//

static CGFloat const kBLFractalTextureView_R = 2.;

typedef struct
{
	CGFloat red, green, blue;
} BLFractalTextureView_Color;

#import "BLFractalTextureView.h"

@implementation BLFractalTextureView
{
	BOOL _isDrawing;
	int gridSize;
	CGFloat *grid;
	CGFloat gridmaxHeight;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		_isDrawing = NO;
		gridSize = 2;
		grid = calloc(4, sizeof(CGFloat));
		grid[0] = grid[1] = grid[2] = grid[3] = 0;

		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
			for ( int iteration = 0; iteration < 12; ++iteration )
			{
				[self generateWithR:1. / ( pow( iteration , 2 )  + 4)];
				dispatch_async(dispatch_get_main_queue(), ^{
					[self setNeedsDisplay];
				});
			}
		});
    }
    return self;
}

- (BLFractalTextureView_Color)colorForHeight:(CGFloat)height
{
	BLFractalTextureView_Color resultColor;
	static CGFloat colors[] = {
		//Red, Green, Blue,  Height
		0.152, 0.422, 0.595, -1.2,
		0.260, 0.498, 0.892, -0.01,
		0.825, 0.925, 0.271, 0,
		0.555, 0.866, 0.365, 0.01,
		0.333, 0.655, 0.147, 0.5,
		0.384, 0.362, 0.275, 0.6,
		0.320, 0.280, 0.240, 0.8,
		0.935, 0.935, 0.935, 0.9,
		1.000, 1.000, 1.000, 1,
		};
	if ( height <= colors[3] )
	{
		resultColor.red   = colors[0];
		resultColor.green = colors[1];
		resultColor.blue  = colors[2];
		return resultColor;
	}
	int lastIndex = sizeof(colors)/sizeof(CGFloat) - 1;
	if ( height >= colors[lastIndex ] )
	{
		resultColor.red   = lastIndex - 1;
		resultColor.green = lastIndex - 2;
		resultColor.blue  = lastIndex - 3;
		return resultColor;
	}
	int count = sizeof(colors)/sizeof(CGFloat) / 4;
	for ( int colorHeightIndicatorIndex = 1; colorHeightIndicatorIndex < count; ++colorHeightIndicatorIndex) {
		CGFloat colorHeightIndicator = colors[ colorHeightIndicatorIndex * 4 + 3 ];
//		NSNumber *colorHeightIndicator = colorHeightIndicators[colorHeightIndicatorIndex];
		if ( height < colorHeightIndicator )
		{
			CGFloat delta = (colorHeightIndicator - height ) / fabsf(colors[ (colorHeightIndicatorIndex -1)* 4 + 3] - colorHeightIndicator);
			//			NSAssert(delta >= 0, @"");
			//			NSAssert(delta <= 1, @"");
			CGFloat newRed   = colors[ (colorHeightIndicatorIndex - 1 ) * 4 + 0] * delta + colors[ (colorHeightIndicatorIndex ) * 4 + 0] * ( 1 - delta);
			CGFloat newGreen = colors[ (colorHeightIndicatorIndex - 1 ) * 4 + 1] * delta + colors[ (colorHeightIndicatorIndex ) * 4 + 1] * ( 1 - delta);
			CGFloat newBlue  = colors[ (colorHeightIndicatorIndex - 1 ) * 4 + 2] * delta + colors[ (colorHeightIndicatorIndex ) * 4 + 2] * ( 1 - delta);
//			newBlue = 0;
//			NSLog(@"R:%.02f G:%.02f B:%.02f", newRed, newGreen, newBlue );
//			newBlue = arc4random() / INT32_MAX;
//			newRed = arc4random() / INT32_MAX;
//			newGreen = arc4random() / INT32_MAX;
			resultColor.red   = newRed;// * delta + colors[ (colorHeightIndicatorIndex ) * 4 + 0] * ( 1 - delta);
			resultColor.green = newGreen;// * delta + colors[ (colorHeightIndicatorIndex ) * 4 + 1] * ( 1 - delta);
			resultColor.blue  = newBlue;// * delta + colors[ (colorHeightIndicatorIndex ) * 4 + 2] * ( 1 - delta);
			return resultColor;
		}
	}
	return resultColor;
}

- (UIColor *)uicolorForHeight:(CGFloat)height
{
//	NSAssert(height >= -1, @"");
//	NSAssert(height <= 1, @"");
	NSArray *colors = @[
						[UIColor colorWithRed:0.152 green:0.422 blue:0.595 alpha:1.000],
						[UIColor colorWithRed:0.260 green:0.498 blue:0.892 alpha:1.000],
						[UIColor colorWithRed:0.825 green:0.925 blue:0.271 alpha:1.000],
						[UIColor colorWithRed:0.555 green:0.866 blue:0.365 alpha:1.000],
						[UIColor colorWithRed:0.333 green:0.655 blue:0.147 alpha:1.000],
						[UIColor colorWithRed:0.384 green:0.362 blue:0.275 alpha:1.000],
						[UIColor colorWithRed:0.320 green:0.280 blue:0.240 alpha:1.000],
						[UIColor colorWithWhite:0.935 alpha:1.000],
						[UIColor colorWithWhite:1.000 alpha:1.000] ];
	NSArray *colorHeightIndicators = @[ @(-1.2), @( -0.01), @0, @(0.01), @( 0.5), @(0.6), @( 0.8), @(.9), @(1)];

	if ( height <= [[colorHeightIndicators firstObject] floatValue] )
	{
		return [colors firstObject];
	}
	if ( height >= [[colorHeightIndicators lastObject] floatValue] )
	{
		return [colors lastObject];
	}
	for ( int colorHeightIndicatorIndex = 1; colorHeightIndicatorIndex < colorHeightIndicators.count; ++colorHeightIndicatorIndex) {
		NSNumber *colorHeightIndicator = colorHeightIndicators[colorHeightIndicatorIndex];
		if ( height < colorHeightIndicator.floatValue )
		{
			CGFloat delta = (colorHeightIndicator.floatValue - height ) / fabsf([colorHeightIndicators[ colorHeightIndicatorIndex - 1] floatValue] - colorHeightIndicator.floatValue);
//			NSAssert(delta >= 0, @"");
//			NSAssert(delta <= 1, @"");
			return [BLFractalTextureView colorFromColor:colors[colorHeightIndicatorIndex - 1] toColor:colors[colorHeightIndicatorIndex] withProgress:1- delta];
		}
	}
	
	return [UIColor whiteColor];
}

- (void)printGrid:(CGFloat *)inputgrid withSize:(int)size withLabel:(NSString *)labelString
{
	NSMutableString *printoutString = [[NSMutableString alloc] initWithFormat:@"%@ GridWithSize:%d\n", labelString, size ];
	for ( int iy = 0; iy < size; ++iy) {
		for ( int ix = 0; ix < size; ++ix) {
			[printoutString appendFormat:@"%.02f\t", inputgrid[ iy * size + ix]];
		}
		[printoutString appendString:@"\n"];
	}
	NSLog(@"%@",printoutString);
}


- (void)generateWithR:(CGFloat)rougntValue
{
	NSLog(@"%s value=%f", __PRETTY_FUNCTION__, rougntValue );

	int newSize = gridSize * 2 - 1;
	CGFloat *newGrid = calloc( pow(newSize, 2), sizeof(CGFloat));
	//copy oldNodes
	for ( int iy = 0; iy < gridSize; ++iy) {
		for ( int ix = 0; ix < gridSize; ++ix) {
			newGrid[ iy * newSize * 2 + ix * 2 ] = grid[ iy * gridSize + ix];
		}
	}
	//randCenters
	for ( int iy = 0; iy < gridSize - 1; ++iy) {
		for ( int ix = 0; ix < gridSize - 1; ++ix) {
			CGFloat midValue = (grid[ (iy + 1) * gridSize + ix] + grid[ ( iy + 1) * gridSize + ix + 1] +
								grid[ iy * gridSize + ix] + grid[ iy * gridSize + ix + 1]) / 4.;
			CGFloat randDeltaValue = ( (arc4random()%200) / 100. ) - 1 ;
			randDeltaValue = randDeltaValue * rougntValue;
			newGrid[ (2 * iy + 1 ) * newSize + ix * 2 + 1 ] = midValue + randDeltaValue;
		}
	}

	for ( int iy = 0; iy < newSize; ++iy ) {
		for ( int ix = (iy % 2) ? 0 : 1; ix < newSize ; ix += 2) {
			CGFloat sum = 0;
			CGFloat operands = 0;
			if ( ix > 0 )
			{
				sum += newGrid[ iy * newSize + ix - 1];
				operands += 1;
			}
			if ( ix < newSize - 1)
			{
				sum += newGrid[ iy * newSize + ix + 1];
				operands += 1;
			}
			if ( iy > 0 )
			{
				sum += newGrid[ (iy - 1) * newSize + ix ];
				operands += 1;
			}
			if ( iy < newSize - 1)
			{
				sum += newGrid[ (iy + 1) * newSize + ix ];
				operands += 1;
			}
			
			CGFloat midValue = sum / operands;
			
			CGFloat randDeltaValue = ( arc4random()%200 / 100. ) - 1;
			randDeltaValue = randDeltaValue * rougntValue;
			newGrid[ iy * newSize + ix] = midValue + randDeltaValue;
		}
	}
	@synchronized( self )
	{
		gridmaxHeight = 0.1;
		for ( int i = 0; i < pow(newSize, 2); ++ i)
		{
			gridmaxHeight = MAX(gridmaxHeight, newGrid[i]);
		}
		gridSize = newSize;
		free(grid);
		grid = newGrid;
	}
}

///*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	@synchronized( self )
	{
	CGContextRef c = UIGraphicsGetCurrentContext();
	CGRect bounds = self.bounds;
	CGContextClearRect(c, bounds);
	CGContextSetFillColor(c, CGColorGetComponents( [UIColor colorWithWhite:1.000 alpha:1.000].CGColor ));
	CGContextFillRect(c, bounds);
	CGSize pointsize = CGSizeMake( CGRectGetWidth(bounds) / gridSize, CGRectGetHeight(bounds) / gridSize );
	CGRect pointRect = (CGRect){ .origin = CGPointZero, .size = pointsize };
	pointRect.size.width += 1;
	pointRect.size.height += 1;
	NSLog(@"start drawing [maxHeight:%.02f]", gridmaxHeight );
		
		for ( int iy = 0; iy < gridSize; ++iy )
		{
			for ( int ix = 0; ix < gridSize; ++ix )
			{
				pointRect.origin = CGPointMake(ix * pointsize.width, iy * pointsize.height);
				CGFloat componentHeight = grid[ iy * gridSize + ix ] / gridmaxHeight;
				CGFloat *colorComponents = calloc(4, sizeof(CGFloat));
				colorComponents[3] = 1;
				BLFractalTextureView_Color resultColor = [self colorForHeight:componentHeight];
				colorComponents[0] = resultColor.red;
				colorComponents[1] = resultColor.green;
				colorComponents[2] = resultColor.blue;
				CGContextSetFillColor(c, colorComponents );
				
				//grayscale display
//				CGContextSetFillColor(c, CGColorGetComponents( [UIColor colorWithRed:componentHeight green:componentHeight blue:componentHeight alpha:1].CGColor ));
				CGContextFillRect(c, pointRect);
				free(colorComponents);
			}
		}
	}
	NSLog(@"end Drawing");
}
//*/

+ (UIColor *)colorFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor withProgress:(CGFloat)progress
{
	CGFloat fromRed, fromGreen, fromBlue, fromAlpha;
	CGFloat toRed, toGreen, toBlue, toAlpha;
	[fromColor getRed:&fromRed green:&fromGreen blue:&fromBlue alpha:&fromAlpha];
	[toColor getRed:&toRed green:&toGreen blue:&toBlue alpha:&toAlpha];
		
	toRed = fromRed * ( 1 - progress) + toRed * progress;
	toGreen = fromGreen * ( 1 - progress) + toGreen * progress;
	toBlue = fromBlue * ( 1 - progress) + toBlue * progress;
	toAlpha = fromAlpha * ( 1 - progress) + toAlpha * progress;
	
	return [UIColor colorWithRed:toRed green:toGreen blue:toBlue alpha:toAlpha];
}

@end
