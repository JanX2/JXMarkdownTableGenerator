//
//  JXMarkdownTableGenerator.m
//  CSV Converter
//
//  Created by Jan on 15.04.13.
//
//  Copyright 2013 Jan Weiß. Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//

#import "JXMarkdownTableGenerator.h"

@implementation JXMarkdownTableGenerator

+ (instancetype)markdownTableGenerator;
{
	id result = [[[self class] alloc] init];
	
	return JX_AUTORELEASE(result);
}

#if (JX_HAS_ARC == 0)
- (void)dealloc
{
	[super dealloc];
}
#endif


- (void)escapeStringForMarkdownTable:(NSMutableString *)theString
{
	[theString replaceOccurrencesOfString:@"|" withString:@"&#124;" options:NSLiteralSearch range:NSMakeRange(0, theString.length)];

	[theString replaceOccurrencesOfString:@"\n" withString:@"<br />" options:NSLiteralSearch range:NSMakeRange(0, theString.length)];
}


- (NSString *)stringForTableMatrix:(NSArray *)tableMatrix
				  tableHeaderIndex:(NSUInteger)tableHeaderIndex;
{
	NSArray *preambleArray = nil;
	NSArray *rowColArray = nil;
	
	if (tableHeaderIndex == NSNotFound) {
		rowColArray = tableMatrix;
	} else {
		preambleArray = [tableMatrix subarrayWithRange:NSMakeRange(0, tableHeaderIndex)];

		NSUInteger rowCount = tableMatrix.count - tableHeaderIndex;
		rowColArray = [tableMatrix subarrayWithRange:NSMakeRange(tableHeaderIndex, rowCount)];
	}
	
    NSMutableArray *tableMatrixFirstRow = tableMatrix[0];
	NSUInteger columnCount = tableMatrixFirstRow.count;
	NSMutableArray *escapedRows = [NSMutableArray arrayWithCapacity:rowColArray.count];
	
	NSUInteger *columnWidths = calloc(columnCount, sizeof(NSUInteger));
	
	// Escape each cell’s content.
	for (NSMutableArray *columns in rowColArray) {
		NSMutableArray *rowArray = [NSMutableArray arrayWithCapacity:columnCount];
		
		int i = 0;
		for (NSString *cellString in columns) {
			NSMutableString *tmpString = [NSMutableString stringWithString:cellString];
			
			[self escapeStringForMarkdownTable:tmpString];
			
			// We could use composed character sequences or grapheme clusters here, but we are lazy.
			NSUInteger escapeStringLength = tmpString.length;
			if (escapeStringLength > columnWidths[i]) {
				columnWidths[i] = escapeStringLength;
			}
			
			[rowArray addObject:tmpString];
			i++;
		}
		
		[escapedRows addObject:rowArray];
	}
	
	NSMutableArray *dividerRowArray = [NSMutableArray arrayWithCapacity:columnCount];
	int columnCountInt = (int)columnCount;
	for (int i = 0; i < columnCountInt; i++) {
		NSString *columnDivider = [@"" stringByPaddingToLength:columnWidths[i]
													withString:@"-"
											   startingAtIndex:0];
		[dividerRowArray addObject:columnDivider];
	}
	
	if (tableHeaderIndex == NSNotFound) {
		[escapedRows insertObject:dividerRowArray atIndex:0];

		NSMutableArray *emptyHeaderRowArray = [NSMutableArray arrayWithCapacity:columnCount];
		for (NSUInteger colIndex = 0; colIndex < columnCount; colIndex++) {
			[emptyHeaderRowArray addObject:@""];
		}
		[escapedRows insertObject:emptyHeaderRowArray atIndex:0];
	} else {
		[escapedRows insertObject:dividerRowArray atIndex:(tableHeaderIndex + 1)];
	}
	
	// Assemble rows and append to outString.
    NSMutableString *outString = [[NSMutableString alloc] init];

	if (preambleArray != nil) {
		[outString appendString:[preambleArray componentsJoinedByString:@"  \n"]]; // We force single lines instead of paragraphs.
		[outString appendString:@"\n"];
	}
	
	for (NSArray *rowArray in escapedRows) {
		[outString appendString:@"|"];

		int i = 0;
		for (NSString *escapedString in rowArray) {
			NSString *paddedString = [escapedString stringByPaddingToLength:columnWidths[i]
																 withString:@" "
															startingAtIndex:0];
			[outString appendString:paddedString];
			[outString appendString:@"|"];
			i++;
		}
		
		[outString appendString:@"\n"];
	}
	
	free(columnWidths);

    return JX_AUTORELEASE(outString);
}

- (NSData *)dataForTableMatrix:(NSArray *)csvArray
			  tableHeaderIndex:(NSUInteger)tableHeaderIndex;
{
	NSString *outString = [self stringForTableMatrix:csvArray
									tableHeaderIndex:tableHeaderIndex];
    
	NSData *outData = [outString dataUsingEncoding:NSUTF8StringEncoding];
	
    return outData;
}

@end
