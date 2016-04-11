//
//  DefinitionIF.h
//  KJBLE
//
//  Created by chadongsu on 2016/04/11.
//  Copyright (c) 2016年 chadongsu. All rights reserved.
//

#ifndef KJBLE_DefinitionIF_h
#define KJBLE_DefinitionIF_h

typedef NS_OPTIONS(NSInteger, ColorType) {
	TypeNone	= 0,
	TypeRed		= 1 << 0,
	TypeGreen	= 1 << 1,
	TypeYello	= 1 << 2,
};

#endif
