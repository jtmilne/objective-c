//
//  PNMessageTest.m
//  pubnub
//
//  Created by Valentin Tuller on 2/20/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNMessage.h"
#import "PNChannel.h"
#import "PNError.h"
#import "PNError+Protected.h"
#import "PNJSONSerialization.h"

@interface PNMessage (test)

+ (PNMessage *)messageWithObject:(id)object forChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage error:(PNError **)error;
+ (PNMessage *)messageFromServiceResponse:(id)messageBody onChannel:(PNChannel *)channel atDate:(PNDate *)messagePostDate;
- (id)initWithObject:(id)object forChannel:(PNChannel *)channel compressed:(BOOL)shouldCompressMessage;
@property (nonatomic, assign, getter = shouldCompressMessage) BOOL compressMessage;

@end

@interface PNMessageTest : SenTestCase

@end

@implementation PNMessageTest

-(void)tearDown {
	[super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)testMessageWithObject {
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	PNError *error = nil;
	PNMessage *message = [PNMessage messageWithObject:@"object" forChannel: channel compressed: YES error: &error];

	STAssertTrue( message != nil, @"");
	STAssertTrue( error == nil, @"");
	STAssertTrue( message.channel == channel, @"");
	STAssertTrue( [message.message isEqualToString: [PNJSONSerialization stringFromJSONObject: @"object"]], @"");
	STAssertTrue( message.compressMessage == YES, @"");

	message = [PNMessage messageWithObject:@"object" forChannel: nil compressed: YES error: &error];
	STAssertTrue( message == nil, @"");
	STAssertTrue( error.code == kPNMessageHasNoChannelError, @"");

	message = [PNMessage messageWithObject: nil forChannel: channel compressed: YES error: &error];
	STAssertTrue( message == nil, @"");
	STAssertTrue( error.code == kPNMessageHasNoContentError, @"");
}

-(void)testMessageFromServiceResponse {
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	NSDictionary *body = @{@"timetoken": @(123), @"message": @"message"};
	PNDate *postDate = [PNDate dateWithToken: @(200)];
	PNMessage *message = [PNMessage messageFromServiceResponse: body onChannel: channel atDate: postDate];

	STAssertTrue( message != nil, @"");
	STAssertTrue( [[message.receiveDate timeToken] intValue] == 123, @"");
	STAssertTrue( [message.message isEqualToString: @"message"] == YES, @"");
	STAssertTrue( message.channel == channel, @"");

	message = [PNMessage messageFromServiceResponse: @{@"message": @"message"} onChannel: channel atDate: postDate];
	STAssertTrue( [[message.receiveDate timeToken] intValue] == 200, @"");
	STAssertTrue( [message.message isEqualToDictionary:@{@"message": @"message"}] == YES, @"");
	STAssertTrue( message.channel == channel, @"");
}

-(void)testInitWithObject {
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	PNMessage *message = [[PNMessage alloc] initWithObject: @"message" forChannel: channel compressed: YES];
	STAssertTrue( message != nil, @"");
	STAssertTrue( message.channel == channel, @"");
	STAssertTrue( [message.message isEqualToString: [PNJSONSerialization stringFromJSONObject: @"message"]], @"");
	STAssertTrue( message.compressMessage == YES, @"");
}

@end



