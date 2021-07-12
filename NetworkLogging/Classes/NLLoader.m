//
//  NLLoader.m
//  NetworkLogging
//
//  Created by Pavel Volkhin on 13.02.2020.
//

#import "NLLoader.h"

@implementation NLLoader

+ (void)load
{
    SEL implementNetworkLoggingSelector = NSSelectorFromString(@"implementNetworkLogging");
    if ([NSURLSessionConfiguration respondsToSelector:implementNetworkLoggingSelector])
    {
        [NSURLSessionConfiguration performSelector:implementNetworkLoggingSelector];
    }
}

@end
