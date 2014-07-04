//
//  BLFractalTextureView.m
//  FractalTerrainTextureGen
//
//  Created by admin on 04/07/14.
//  Copyright (c) 2014 Alexander.Sviridov. All rights reserved.
//

static CGFloat const kBLFractalTextureView_R = 2.;

#import "BLFractalTextureView.h"

@implementation BLFractalTextureView
{
	BOOL _isDrawing;
	int gridSize;
	CGFloat *grid;
	CGFloat gridmaxHeight;

	int iteration;
	
	void (^landGenBlock)();
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//		[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
		_isDrawing = NO;
		gridSize = 2;
		grid = calloc(4, sizeof(CGFloat));
		grid[0] = grid[1] = grid[2] = grid[3] = 0;
		iteration = 0;
		for ( int i = 0; i < 4; ++i )
		{
			NSLog(@"%lf", pow(2, i));
		}
		
		landGenBlock = [^{
			NSLog(@"genblock");
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
				if ( iteration < 10 )
				{
					[self generateWithR:1. / ( pow( iteration , 2 )  + 4)];
					++iteration;
					dispatch_async(dispatch_get_main_queue(), ^{
						[self setNeedsDisplay];
						landGenBlock();
					});
//					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//					});
				}
				else {
					NSLog(@"over");
				}
			});
		} copy];
		landGenBlock();
//		for ( char i = 0; i < 8; ++i )
//		{
//			[self generateWithR:kBLFractalTextureView_R/ (i + 1)];
//		}
    }
    return self;
}

- (UIColor *)colorForHeight:(CGFloat)height
{
//	NSAssert(height >= -1, @"");
//	NSAssert(height <= 1, @"");
	NSArray *colors = @[
						[UIColor colorWithRed:0.158 green:0.130 blue:0.571 alpha:1.000],
						[UIColor colorWithRed:0.416 green:0.923 blue:0.999 alpha:1.000],
						[UIColor colorWithRed:0.913 green:1.000 blue:0.281 alpha:1.000],
						[UIColor colorWithRed:0.555 green:0.866 blue:0.365 alpha:1.000],
						[UIColor colorWithRed:0.333 green:0.655 blue:0.147 alpha:1.000],
						[UIColor colorWithRed:0.320 green:0.280 blue:0.240 alpha:1.000],
						[UIColor colorWithWhite:1.000 alpha:1.000] ];
	NSArray *colorHeightIndicators = @[ @(-1.2), @( -0.01), @0, @(0.01), @( 0.4), @( 0.7), @(1)];

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
//	if ( _isDrawing )
//	{
//		NSLog(@"%s is drawing, skeep", __PRETTY_FUNCTION__ );
//		return;
//	}
//	
	int newSize = gridSize * 2 - 1;
	CGFloat *newGrid = calloc( pow(newSize, 2), sizeof(CGFloat));
	//copy oldNodes
	for ( int iy = 0; iy < gridSize; ++iy) {
		for ( int ix = 0; ix < gridSize; ++ix) {
			newGrid[ iy * newSize * 2 + ix * 2 ] = grid[ iy * gridSize + ix];
		}
	}
//	[self printGrid:newGrid withSize:gridSize * 2 - 1  withLabel:@"newGrid Coping"];
	//randCenters
	for ( int iy = 0; iy < gridSize - 1; ++iy) {
		for ( int ix = 0; ix < gridSize - 1; ++ix) {
//			CGFloat maxValue = MAX( MAX( grid[ (iy + 1) * gridSize + ix], grid[ ( iy + 1) * gridSize + ix + 1]) , MAX(grid[ iy * gridSize + ix], grid[ iy * gridSize + ix + 1]));
			CGFloat midValue = (grid[ (iy + 1) * gridSize + ix] + grid[ ( iy + 1) * gridSize + ix + 1] +
								grid[ iy * gridSize + ix] + grid[ iy * gridSize + ix + 1]) / 4.;
			CGFloat randDeltaValue = ( (arc4random()%200) / 100. ) - 1 ;
			randDeltaValue = randDeltaValue * rougntValue;
			newGrid[ (2 * iy + 1 ) * newSize + ix * 2 + 1 ] = midValue + randDeltaValue;
		}
	}
//	[self printGrid:newGrid withSize:gridSize * 2 - 1 withLabel:@"newGrid randSenters"];
	
//	for ( int iy = 1; iy < newSize - 1; ++iy ) {
//		for ( int ix = (iy % 2) ? 2 : 1; ix < newSize - 1 ; ix += 2) {
//			
//			CGFloat midValue = ( newGrid[ (iy - 1) * newSize + ix -1 ] + newGrid[ (iy + 1) * newSize + ix - 1] +
//						newGrid[ (iy - 1) * newSize + ix + 1] + newGrid[ (iy + 1) * newSize + ix + 1]) / 4.;
//			
//			CGFloat randDeltaValue = ( arc4random()%200 / 200. );
//			randDeltaValue = randDeltaValue * rougntValue;
//			newGrid[ iy * newSize + ix] = midValue + randDeltaValue;
////			[self printGrid:newGrid withSize:gridSize * 2 - 1 withLabel:@"newGrid randSenters"];
//		}
//	}
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
//			[self printGrid:newGrid withSize:gridSize * 2 - 1 withLabel:@"newGrid randSenters"];
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
				CGContextSetFillColor(c, CGColorGetComponents( [self colorForHeight:componentHeight].CGColor ));
//				CGContextSetFillColor(c, CGColorGetComponents( [UIColor colorWithRed:componentHeight green:componentHeight blue:componentHeight alpha:1].CGColor ));
				CGContextFillRect(c, pointRect);
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
	
//	[fromColor getHue:&fromRed saturation:&fromGreen brightness:&fromBlue alpha:&fromAlpha];
//	[toColor getHue:&toRed saturation:&toGreen brightness:&toBlue alpha:&toAlpha];
	
	toRed = fromRed * ( 1 - progress) + toRed * progress;
	toGreen = fromGreen * ( 1 - progress) + toGreen * progress;
	toBlue = fromBlue * ( 1 - progress) + toBlue * progress;
	toAlpha = fromAlpha * ( 1 - progress) + toAlpha * progress;
	//	return [UIColor colorWithHue:toRed saturation:toGreen brightness:toBlue alpha:toAlpha];
	
	return [UIColor colorWithRed:toRed green:toGreen blue:toBlue alpha:toAlpha];
}

@end
