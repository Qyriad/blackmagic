/*
 * This file is part of the Black Magic Debug project.
 *
 * Copyright (C) 2012-2022  1BitSquared
 * Written by Mikaela Szekely <mikaela.szekely@qyriad.me>,
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * This file overrides certain libgcc builtins in order to further optimize code size.
 */

/*#include "general.h"*/

#include <stdint.h>
#include <stddef.h>


// libgcc's builtin 64-bit division uses a binary long division algorithm, which on arm-none-eabi-gcc 12.1.0 -Os
// ends up in thumb/v7/nofp/libgcc.a as 248 (0x48) bytes of machine code.
// This function is *much* slower -- exponential time in the best case -- but compiles to only 42 bytes (0x2a).
// I'm note sure how, but somehow despite this function only being 206 bytes smaller than libgcc's algorithm,
// this ends up saving a whopping 636 bytes in the final binary.
uint64_t __udivmoddi4(uint64_t numerator, uint64_t denominator, uint64_t *remainder)
{
	// We'll use the simplest possible algorithm: repeated subtraction.
	// This algorithm is *best case* exponential time, but currently the only case where we even need to do
	// 64-bit division is when semihosting for microsecond precision in gettimeofday().
	uint64_t quotient = 0;
	uint64_t rem = numerator;

	while (rem >= denominator) {
		quotient += 1;
		rem = rem - denominator;
	}

	if (remainder != NULL)
		*remainder = rem;

	return quotient;
}
