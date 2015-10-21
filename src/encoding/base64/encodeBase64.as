package encoding.base64
{
    
    /**
     * Encode a UTF-8 string with MIME base64.
     * 
     * @param str The string to encode.
     * @param insertNewLines Boolean flag to add a newline every 76 characters
     *                       to wrap the encoded output.
     * @return Returns a base64 encoded String
     * 
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @playerversion AVM 0.4
     * @langversion 3.0
     */
    public function encodeBase64( str:String, insertNewLines:Boolean = true ):String
    {
        var encoder:Base64Encoder = new Base64Encoder();
            encoder.insertNewLines = insertNewLines;
            encoder.encodeUTFBytes( str );
        
        return encoder.toString();
    }
}