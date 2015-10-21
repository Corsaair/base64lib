package encoding.base64
{
    import flash.utils.ByteArray;
    
    /**
     * Decode a string encoded with MIME base64.
     * 
     * @param str the ASCII encode string to decode.
     * @return Returns a UTF-8 string.
     * 
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @playerversion AVM 0.4
     * @langversion 3.0
     */
    public function decodeBase64( str:String ):String
    {
        var decoder:Base64Decoder = new Base64Decoder();
            decoder.decode( str );
        var bytes:ByteArray = decoder.toByteArray();
            bytes.position = 0;
        
        return bytes.readUTFBytes( bytes.length );
    }
}