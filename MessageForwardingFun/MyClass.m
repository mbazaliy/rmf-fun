//
//  MyClass.m
//  MessageForwardingFun
//
//  Created by Max Bazaliy on 07.08.13.
//  Copyright (c) 2013 R&R Music. All rights reserved.
//

#import "MyClass.h"
#import <objc/runtime.h>

@interface MyClass ()
@property (nonatomic, strong) NSMutableDictionary *store;
@end

@implementation MyClass
@dynamic string, date;

- (id)init
{
	if ((self = [super init])) {
		_store = [NSMutableDictionary new];
	}
	return self;
}

+ (BOOL)resolveInstanceMethod:(SEL)selector
{
	NSString *selectorString = NSStringFromSelector(selector);
	if ([selectorString hasPrefix:@"set"]) {
		class_addMethod(self, selector, (IMP)dictionarySetter, "v@:@");
	} else {
		class_addMethod(self, selector, (IMP)dictionaryGetter, "@@:");
	}
	return YES;
}

id dictionaryGetter(id self, SEL _cmd)
{
	MyClass *typedSelf = (MyClass *)self;
	NSMutableDictionary *backingStore = typedSelf.store;

	NSString *key = NSStringFromSelector(_cmd);

	return [backingStore objectForKey:key];
}

void dictionarySetter(id self, SEL _cmd, id value)
{
	MyClass *typedSelf = (MyClass *)self;
	NSMutableDictionary *backingStore = typedSelf.store;

    NSString *selectorString = NSStringFromSelector(_cmd);
	NSMutableString *key = [selectorString mutableCopy];

	[key deleteCharactersInRange:NSMakeRange(key.length - 1, 1)];

	[key deleteCharactersInRange:NSMakeRange(0, 3)];

	NSString *lowercaseFirstChar = [[key substringToIndex:1] lowercaseString];
	[key replaceCharactersInRange:NSMakeRange(0, 1) withString:lowercaseFirstChar];

	if (value) {
		[backingStore setObject:value forKey:key];
	} else {
		[backingStore removeObjectForKey:key];
	}
}

@end
