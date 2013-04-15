//
//  JXMarkdownTableGenerator.h
//  CSV Converter
//
//  Created by Jan on 15.04.13.
//
//  Copyright 2013 Jan Weiß. Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//

#import <Foundation/Foundation.h>

#import "JXArcCompatibilityMacros.h"

@interface JXMarkdownTableGenerator : NSObject

+ (instancetype)markdownTableGenerator;

// A TableMatrix is an array of arrays.
// Each subarray contains cell objects.
// All subarrays need to contain a single object type:
// NSString.
// Each entry in this topmost array represents a row.
// Each of the strings in a row represent a column of the row.
#if 0
	// Here is an example of such an array:
    NSArray *sampleTableMatrix = @[
	@[@"Header 1", @"Header 2"],
	@[@"cell 1", @"cell 2"],
	@[@"second row", @"second row 2"]
	];
#endif

// Pass “NSNotFound” as the tableHeaderIndex if you don’t have a header row in your tableMatrix!

- (NSString *)stringForTableMatrix:(NSArray *)tableMatrix
				  tableHeaderIndex:(NSUInteger)tableHeaderIndex;

- (NSData *)dataForTableMatrix:(NSArray *)tableMatrix
			  tableHeaderIndex:(NSUInteger)tableHeaderIndex;

@end
