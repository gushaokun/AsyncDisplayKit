//
//  ASBackgroundLayoutSpec.mm
//  AsyncDisplayKit
//
//  Copyright (c) 2014-present, Facebook, Inc.  All rights reserved.
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree. An additional grant
//  of patent rights can be found in the PATENTS file in the same directory.
//

#import "ASBackgroundLayoutSpec.h"
#import "ASLayoutSpec+Subclasses.h"

#import "ASAssert.h"
#import "ASLayout.h"

static NSUInteger const kForegroundChildIndex = 0;
static NSUInteger const kBackgroundChildIndex = 1;

@implementation ASBackgroundLayoutSpec

#pragma mark - Class

+ (instancetype)backgroundLayoutSpecWithChild:(id<ASLayoutable>)child background:(id<ASLayoutable>)background;
{
  return [[self alloc] initWithChild:child background:background];
}

#pragma mark - Lifecycle

- (instancetype)initWithChild:(id<ASLayoutable>)child background:(id<ASLayoutable>)background
{
  if (!(self = [super init])) {
    return nil;
  }
  
  ASDisplayNodeAssertNotNil(child, @"Child cannot be nil");
  [self setChild:child atIndex:kForegroundChildIndex];
  self.background = background;
  return self;
}

#pragma mark - ASLayoutSpec

/**
 * First layout the contents, then fit the background image.
 */
- (ASLayout *)calculateLayoutThatFits:(ASSizeRange)constrainedSize
                     restrictedToSize:(ASLayoutableSize)size
                 relativeToParentSize:(CGSize)parentSize
{
  ASLayout *contentsLayout = [[super childAtIndex:kForegroundChildIndex] layoutThatFits:constrainedSize parentSize:parentSize];

  NSMutableArray *sublayouts = [NSMutableArray arrayWithCapacity:2];
  if (self.background) {
    // Size background to exactly the same size.
    ASLayout *backgroundLayout = [self.background layoutThatFits:ASSizeRangeMake(contentsLayout.size)
                                                      parentSize:parentSize];
    backgroundLayout.position = CGPointZero;
    [sublayouts addObject:backgroundLayout];
  }
  contentsLayout.position = CGPointZero;
  [sublayouts addObject:contentsLayout];

  return [ASLayout layoutWithLayoutable:self size:contentsLayout.size sublayouts:sublayouts];
}

#pragma mark - Background

- (void)setBackground:(id<ASLayoutable>)background
{
  [super setChild:background atIndex:kBackgroundChildIndex];
}

- (id<ASLayoutable>)background
{
  return [super childAtIndex:kBackgroundChildIndex];
}

@end
