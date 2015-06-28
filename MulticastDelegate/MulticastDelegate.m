//
//  MulticastDelegate.m
//  MulticastDelegate
//
//  Created by Alexander Tkachenko on 7/15/13.
//  Copyright (c) 2013 Alexander Tkachenko. All rights reserved.
//

#import "MulticastDelegate.h"

@implementation MulticastDelegate {
    // the array of observing delegates
    NSHashTable* _delegates;
}


- (id)init {
    if (self = [super init]) {
        _delegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}


- (void)add:(id)delegate {
    [_delegates addObject:delegate];
}


- (void)remove:(id)delegate {
    [_delegates removeObject:delegate];
}

- (void)removeAll {
    [_delegates removeAllObjects];
}


- (NSHashTable *)delegates {
    return _delegates;
}


- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    
    // if any of the delegates respond to this selector, return YES
    for(id delegate in _delegates) {
        if ([delegate respondsToSelector:aSelector]) {
            return YES;
        }
    }
    return NO;
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    // can this class create the signature?
    NSMethodSignature* signature = [super methodSignatureForSelector:aSelector];
    
    // if not, try our delegates
    if (!signature) {
        for(id delegate in _delegates) {
            if ([delegate respondsToSelector:aSelector]) {
                return [delegate methodSignatureForSelector:aSelector];
            }
        }
    }
    return signature;
}


- (void)forwardInvocation:(NSInvocation *)anInvocation {
    // forward the invocation to every delegate
    for(id delegate in _delegates) {
        if ([delegate respondsToSelector:[anInvocation selector]]) {
            [anInvocation invokeWithTarget:delegate];
        }
    }
}

@end
