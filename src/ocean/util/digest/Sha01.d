/*******************************************************************************

        This module implements common parts of the SHA-0 and SHA-1 algoritms

        Copyright:
            Copyright (c) 2006 Tango contributors.
            Some parts copyright (c) 2009-2016 Sociomantic Labs GmbH.
            All rights reserved.

        License:
            Tango Dual License: 3-Clause BSD License / Academic Free License v3.0.
            See LICENSE_TANGO.txt for details.

        Version: Initial release: Feb 2006

        Authors: Regan Heath, Oskar Linde

*******************************************************************************/

module ocean.util.digest.Sha01;

import ocean.transition;

import ocean.core.ByteSwap;

import ocean.util.digest.MerkleDamgard;

version(UnitTest) import ocean.core.Test;

/*******************************************************************************

*******************************************************************************/

package abstract class Sha01 : MerkleDamgard
{
        protected uint[5]        context;
        private const ubyte      padChar = 0x80;
        package const uint       mask = 0x0000000F;

        /***********************************************************************

                The digest size of Sha-0 and Sha-1 is 20 bytes

        ***********************************************************************/

        final override uint digestSize() { return 20; }

        /***********************************************************************

                Initialize the cipher

                Remarks:
                Returns the cipher state to it's initial value

        ***********************************************************************/

        final protected override void reset()
        {
                super.reset();
                context[] = initial[];
        }

        /***********************************************************************

                Obtain the digest

                Returns:
                the digest

                Remarks:
                Returns a digest of the current cipher state, this may be the
                final digest, or a digest of the state between calls to update()

        ***********************************************************************/

        final protected override void createDigest(ubyte[] buf)
        {
                version (LittleEndian)
                         ByteSwap.swap32 (context.ptr, context.length * uint.sizeof);

                buf[] = cast(ubyte[]) context;
        }


        /***********************************************************************

            To be implemented

        ***********************************************************************/

        override
        protected abstract void transform(ubyte[] data);

        /***********************************************************************

                 block size

                Returns:
                the block size

                Remarks:
                Specifies the size (in bytes) of the block of data to pass to
                each call to transform(). For SHA0 the blockSize is 64.

        ***********************************************************************/

        final protected override uint blockSize() { return 64; }

        /***********************************************************************

                Length padding size

                Returns:
                the length padding size

                Remarks:
                Specifies the size (in bytes) of the padding which uses the
                length of the data which has been ciphered, this padding is
                carried out by the padLength method. For SHA0 the addSize is 0.

        ***********************************************************************/

        final protected override uint addSize() {return 8;}

        /***********************************************************************

                Pads the cipher data

                Params:
                data = a slice of the cipher buffer to fill with padding

                Remarks:
                Fills the passed buffer slice with the appropriate padding for
                the final call to transform(). This padding will fill the cipher
                buffer up to blockSize()-addSize().

        ***********************************************************************/

        final protected override void padMessage(ubyte[] data)
        {
                data[0] = padChar;
                data[1..$] = 0;
        }

        /***********************************************************************

                Performs the length padding

                Params:
                data   = the slice of the cipher buffer to fill with padding
                length = the length of the data which has been ciphered

                Remarks:
                Fills the passed buffer slice with addSize() bytes of padding
                based on the length in bytes of the input data which has been
                ciphered.

        ***********************************************************************/

        final protected override void padLength(ubyte[] data, size_t length)
        {
                length <<= 3;
                for(ptrdiff_t j = data.length-1; j >= 0; j--)
                        data[$-j-1] = cast(ubyte) (length >> j*data.length);
        }


        /***********************************************************************

        ***********************************************************************/

        protected static uint f(uint t, uint B, uint C, uint D)
        {
                if (t < 20) return (B & C) | ((~B) & D);
                else if (t < 40) return B ^ C ^ D;
                else if (t < 60) return (B & C) | (B & D) | (C & D);
                else return B ^ C ^ D;
        }

        /***********************************************************************

        ***********************************************************************/

        protected static Const!(uint[]) K =
        [
                0x5A827999,
                0x6ED9EBA1,
                0x8F1BBCDC,
                0xCA62C1D6
        ];

        /***********************************************************************

        ***********************************************************************/

        private static Const!(uint[5]) initial =
        [
                0x67452301,
                0xEFCDAB89,
                0x98BADCFE,
                0x10325476,
                0xC3D2E1F0
        ];
}
