//
//  NSMutableData+Extensions.h
//  EWBluetooth
//
//  Created by keli on 2021/6/10.
//  Copyright © 2021 keli. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableData (Extensions)
- (void)appendByte:(uint8_t)byte;
@end

NS_ASSUME_NONNULL_END
