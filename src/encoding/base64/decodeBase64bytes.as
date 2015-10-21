package encoding.base64
{
    import flash.utils.ByteArray;
    
    /**
     * Decode a string encoded with MIME base64 to a ByteArray.
     * 
     * @param str the ASCII encode string to decode.
     * @return Returns a serie of bytes.
     * 
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @playerversion AVM 0.4
     * @langversion 3.0
     */
    public function decodeBase64bytes( str:String ):ByteArray
    {
        var decoder:Base64Decoder = new Base64Decoder();
            decoder.decode( str );
        
        return decoder.toByteArray();
    }
}