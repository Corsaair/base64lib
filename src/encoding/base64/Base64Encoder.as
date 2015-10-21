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
   adapted from mx.utils.Base64Encoder
   https://github.com/apache/flex-sdk/blob/master/frameworks/projects/framework/src/mx/utils/Base64Encoder.as

   - moved package to "encoding.base64"
   - renamed soem vars
   - removed Flex deps like:
     [ResourceBundle], IResourceManager, etc.
*/

package encoding.base64
{
    import flash.utils.ByteArray;

    /**
     * A utility class to encode a String or ByteArray as a Base64 encoded String.
     * 
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @playerversion AVM 0.4
     * @langversion 3.0
     */
    public class Base64Encoder
    {
        
        private static const ESCAPE_CHAR_CODE:Number = 61; // The '=' char
        
        /*
            'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
            'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
            'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
            'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
            'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
            'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
            'w', 'x', 'y', 'z', '0', '1', '2', '3',
            '4', '5', '6', '7', '8', '9', '+', '/'
        */
        private static const ALPHABET_CHAR_CODES:Array =
        [
            65,   66,  67,  68,  69,  70,  71,  72,
            73,   74,  75,  76,  77,  78,  79,  80,
            81,   82,  83,  84,  85,  86,  87,  88,
            89,   90,  97,  98,  99, 100, 101, 102,
            103, 104, 105, 106, 107, 108, 109, 110,
            111, 112, 113, 114, 115, 116, 117, 118,
            119, 120, 121, 122,  48,  49,  50,  51,
            52,   53,  54,  55,  56,  57,  43,  47
        ];
        
        /**
         * Constant definition for the string "UTF-8". 
         */
        public static const CHARSET_UTF8:String = "UTF-8";
        
        /**
         * This value represents a safe number of characters (i.e. arguments) that
         * can be passed to String.fromCharCode.apply() without exceeding the AVM+
         * stack limit.
         * 
         * @private
         */
        public static const MAX_BUFFER_SIZE:uint = 32767;
        
        /**
         * The character codepoint to be inserted into the encoded output to
         * denote a new line if <code>insertNewLines</code> is true.
         * 
         * The default is <code>10</code> to represent the line feed <code>\n</code>.
         */
        public static var newLine:uint = 10;
        
        
        private var _buffers:Array;
        private var _count:uint;
        private var _line:uint;
        private var _work:Array;
        
        /**
         * A Boolean flag to control whether the sequence of characters specified
         * for <code>Base64Encoder.newLine</code> are inserted every 76 characters
         * to wrap the encoded output.
         * 
         * The default is true.
         */
        public var insertNewLines:Boolean = true;
        
        public function Base64Encoder()
        {
            super();
            _ctor();
        }
        
        private function _ctor():void
        {
            _buffers = [];
            _buffers.push([]);
            _count   = 0;
            _line    = 0;
            _work    = [ 0, 0, 0 ];
        }
        
        private function _drain():String
        {
            var result:String = "";
            var i:uint;
            var buffer:Array;
            
            for( i = 0; i < _buffers.length; i++ )
            {
                buffer = _buffers[i] as Array;
                result += String.fromCharCode.apply( null, buffer );
            }
    
            _buffers = [];
            _buffers.push([]);
    
            return result;
        }
        
        private function _flush():String
        {
            if( _count > 0 )
            {
                _encodeBlock();
            }
    
            var result:String = _drain();
            reset();
            return result;
        }
        
        private function _encodeBlock():void
        {
            var currentBuffer:Array = _buffers[_buffers.length - 1] as Array;
            if( currentBuffer.length >= MAX_BUFFER_SIZE )
            {
                currentBuffer = [];
                _buffers.push(currentBuffer);
            }
    
            currentBuffer.push( ALPHABET_CHAR_CODES[ (_work[0] & 0xFF) >> 2] );
            currentBuffer.push( ALPHABET_CHAR_CODES[ ((_work[0] & 0x03) << 4) | ((_work[1] & 0xF0) >> 4) ] );
    
            if( _count > 1 )
            {
                currentBuffer.push( ALPHABET_CHAR_CODES[ ((_work[1] & 0x0F) << 2) | ((_work[2] & 0xC0) >> 6) ] );
            }
            else
            {
                currentBuffer.push(ESCAPE_CHAR_CODE);
            }
    
            if( _count > 2 )
            {
                currentBuffer.push( ALPHABET_CHAR_CODES[ _work[2] & 0x3F ] );
            }
            else
            {
                currentBuffer.push( ESCAPE_CHAR_CODE );
            }
    
            if( insertNewLines )
            {
                if( (_line += 4) == 76 )
                {
                    currentBuffer.push( newLine );
                    _line = 0;
                }
            }
        }
        
        
        /**
         * Clears all buffers and resets the encoder to its initial state.
         */ 
        public function reset():void
        {
            _ctor();
        }
        
        /**
         * Encodes a ByteArray in Base64 and adds the result to an internal buffer.
         * Subsequent calls to this method add on to the internal buffer. After all
         * data have been encoded, call <code>toString()</code> to obtain a
         * Base64 encoded String.
         * 
         * @param data The ByteArray to encode.
         * @param offset The index from which to start encoding.
         * @param length The number of bytes to encode from the offset.
         */
        public function encodeBytes( data:ByteArray, offset:uint = 0, length:uint = 0 ):void
        {
            if( length == 0 )
            {
                length = data.length;
            }
    
            var oldPosition:uint = data.position;
            data.position = offset;
            var currentIndex:uint = offset;
    
            var endIndex:uint = offset + length;
            if( endIndex > data.length )
            {
                endIndex = data.length;
            }
    
            while( currentIndex < endIndex )
            {
                _work[_count] = data[ currentIndex ];
                _count++;
    
                if( _count == _work.length || endIndex - currentIndex == 1 )
                {
                    _encodeBlock();
                    _count   = 0;
                    _work[0] = 0;
                    _work[1] = 0;
                    _work[2] = 0;
                }
                currentIndex++;
            }
    
            data.position = oldPosition;
        }
        
        /**
         * Encodes the UTF-8 bytes of a String in Base64 and adds the result to an
         * internal buffer. The UTF-8 information does not contain a length prefix. 
         * Subsequent calls to this method add on to the internal buffer. After all
         * data have been encoded, call <code>toString()</code> to obtain a Base64
         * encoded String.
         * 
         * @param data The String to encode.
         */
        public function encodeUTFBytes( data:String ):void
        {
            var bytes:ByteArray = new ByteArray();
                bytes.writeUTFBytes( data );
                bytes.position = 0;
            encodeBytes( bytes );
        }
        
        /**
         * Encodes the characters of a String in Base64 and adds the result to
         * an internal buffer. Strings must be in ASCII format. 
         * 
         * <p>Subsequent calls to this method add on to the
         * internal buffer. After all data have been encoded, call
         * <code>toString()</code> to obtain a Base64 encoded String.</p>
         * 
         * @param data The String to encode.
         * @param offset The character position from which to start encoding.
         * @param length The number of characters to encode from the offset.
         */
        public function encode( data:String, offset:uint = 0, length:uint = 0 ):void
        {
            if( length == 0 )
            {
                length = data.length;
            }
    
            var currentIndex:uint = offset;
    
            var endIndex:uint = offset + length;
            if( endIndex > data.length )
            {
                endIndex = data.length;
            }
    
            while( currentIndex < endIndex )
            {
                _work[_count] = data.charCodeAt( currentIndex );
                _count++;
    
                if( _count == _work.length || endIndex - currentIndex == 1 )
                {
                    _encodeBlock();
                    _count   = 0;
                    _work[0] = 0;
                    _work[1] = 0;
                    _work[2] = 0;
                }
                currentIndex++;
            }
        }
        
        /**
         * Returns the current buffer as a Base64 encoded String. Note that
         * calling this method also clears the buffer and resets the 
         * encoder to its initial state.
         * 
         * @return The Base64 encoded String.
         */
        public function toString():String
        {
            return _flush();
        }
        
        
    }
}