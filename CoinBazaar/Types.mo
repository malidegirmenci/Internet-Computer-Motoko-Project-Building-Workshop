module {
    // Type definition for an Internet Computer (IC) actor interface
    public type IC = actor {
        // Function to make HTTP requests on the IC
        http_request : shared (
            { 
                url : Text;            // URL to send the request to
                headers : [(Text, Text)]; // List of (header name, header value) pairs
                body : ?Blob;         // Optional request body (as a byte array)
                method : { #get }     // HTTP method (currently only #get is supported)
            }
        ) -> async {
            body : Blob              // Response body (as a byte array)
        }; 
    };

    // Enumeration of various cryptocurrency options
    public type CoinList = {
        #BTC;  // Bitcoin
        #ETH;  // Ethereum
        #ICP;  // Internet Computer Protocol
        #SOL;  // Solana
        #BNB;  // Binance Coin
        #USDT; // Tether (stablecoin pegged to the US dollar)
        #TRY;  // Turkish Lira
    };

    // Type definition for the arguments passed to an HTTP request
    public type HttpRequestArgs = {
        url : Text;            // Target URL
        headers : [(Text, Text)]; // List of headers
        body : ?Blob;         // Optional request body
        method : { #get }     // HTTP method (limited to #get)
    };

    // Type definition for the payload returned by an HTTP response
    public type HttpResponsePayload = {
        body : Blob              // Response body 
    };
}
