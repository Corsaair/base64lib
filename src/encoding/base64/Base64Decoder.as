/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

/* Note:
   adapted from mx.utils.Base64Decoder
   https://github.com/apache/flex-sdk/blob/master/frameworks/projects/framework/src/mx/utils/Base64Decoder.as

   - moved package to "encoding.base64"
   - renamed soem vars
   - removed Flex deps like:
     [ResourceBundle], IResourceManager, etc.
*/

package encoding.base64
{
    import flash.utils.ByteArray;

    /**
     * A utility class to decode a Base64 encoded String to a ByteArray.
     * 
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @playerversion AVM 0.4
     * @langversion 3.0
     */
    public class Base64Decoder
    {
        private static const ESCAPE_CHAR_CODE:Number = 61; // The '=' char
        
        private static const _inverse:Array =
        [
            64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
            64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
            64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 62, 64, 64, 64, 63,
            52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 64, 64, 64, 64, 64, 64,
            64,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
            15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 64, 64, 64, 64, 64,
            64, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
            41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 64, 64, 64, 64, 64,
            64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
            64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
            64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
            64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
            64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
            64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
            64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
            64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64
        ];
        
        private var _count:int;
        private var _data:ByteArray;
        private var _filled:int;
        private var _work:Array;
        
        /**
         * Constructor.
         */
        public function Base64Decoder()
        {
            super();
            _ctor();
        }
        
        /** @private */
        private function _ctor():void
        {
            _count  = 0;
            _filled = 0;
            _work   = [0, 0, 0, 0];
            _data   = new ByteArray();
        }
        
        /** @private */
        private function _drain():ByteArray
        {
            var result:ByteArray = new ByteArray();
    
            var pos:uint = _data.position;    
            _data.position = 0;  // technically, shouldn't need to set this, but carrying over from previous implementation
            result.writeBytes( _data, 0, _data.length );        
            _data.position = pos;
            result.position = 0;
            
            _filled = 0;
            return result;
        }
        
        /** @private */
        private function _flush():ByteArray
        {
            if( _count > 0 )
            {
                var message:String = "A partial block (" + _count + " of 4 bytes) was dropped. Decoded data is probably truncated!";
                throw new Error( message );
            }
            
            return _drain();
        }
        
        /**
         * Clears all buffers and resets the decoder to its initial state.
         */
        public function reset():void
        {
            _ctor();
        }
        
        /**
         * Decodes a Base64 encoded String and adds the result to an internal
         * buffer. Strings must be in ASCII format. 
         * 
         * <p>Subsequent calls to this method add on to the internal
         * buffer. After all data have been encoded, call <code>toByteArray()</code>
         * to obtain a decoded <code>flash.utils.ByteArray</code>.</p>
         * 
         * @param encoded The Base64 encoded String to decode.
         */
        public function decode( encoded:String ):void
        {
            var i:uint;
            var len:uint = encoded.length;
            for( i = 0; i < len; ++i )
            {
                var c:Number = encoded.charCodeAt( i );
    
                if( c == ESCAPE_CHAR_CODE )
                {
                    _work[ _count++ ] = -1;
                }
                else if( _inverse[ c ] != 64 )
                {
                    _work[ _count++ ] = _inverse[ c ];
                }
                else
                {
                    continue;
                }
    
                if( _count == 4 )
                {
                    _count = 0;
                    _data.writeByte( (_work[0] << 2) | ((_work[1] & 0xFF) >> 4) );
                    _filled++;
    
                    if( _work[2] == -1 )
                    {
                        break;
                    }
    
                    _data.writeByte( (_work[1] << 4) | ((_work[2] & 0xFF) >> 2) );
                    _filled++;
    
                    if( _work[3] == -1 )
                    {
                        break;
                    }
    
                    _data.writeByte( (_work[2] << 6) | _work[3] );
                    _filled++;
                }
            }
        }
        
        /**
         * Returns the current buffer as a decoded <code>flash.utils.ByteArray</code>.
         * Note that calling this method also clears the buffer and resets the 
         * decoder to its initial state.
         * 
         * @return The decoded <code>flash.utils.ByteArray</code>.
         */
        public function toByteArray():ByteArray
        {
            var result:ByteArray = _flush();
            reset();
            return result;
        }
        
        
    }
}