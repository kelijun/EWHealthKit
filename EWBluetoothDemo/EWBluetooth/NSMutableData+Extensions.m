//
//  NSMutableData+Extensions.m
//  BLE
//
//  Created by keli on 2021/6/10.
//  Copyright © 2021 keli. All rights reserved.
//

#import "NSMutableData+Extensions.h"

@implementation NSMutableData (Extensions)

- (void)appendByte:(uint8_t)byte {
    [self appendBytes:(void *)(&byte) length:1];
}
@end
