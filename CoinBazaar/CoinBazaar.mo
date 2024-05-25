import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import Nat32 "mo:base/Nat32";
import Text "mo:base/Text";
import Trie "mo:base/Trie";
import Option "mo:base/Option";
import Types "Types";

actor {
  // Declare an Internet Computer interface for making HTTP requests
  let ic : Types.IC = actor ("aaaaa-aa");

  // Define a type alias for item IDs in the shopping cart and wallet
  type Id = Nat32;

  // Define a record type to represent items in a shopping cart
  type Coins_cart = {
    purchase_type: Types.CoinList; // Type of cryptocurrency being purchased
    addCoin: Types.CoinList; // Cryptocurrency being used to make the purchase
    purchase_amount: Nat32; // Amount of the purchase cryptocurrency
  };

  private stable var next : Id = 0; // Next available ID for a cart item
  private stable var cart : Trie.Trie<Id, Coins_cart> = Trie.empty(); // Shopping cart
  private stable var temp: Trie.Trie<Id, Coins_cart> = Trie.empty(); // Temporary storage for cart before moving to wallet
  private stable var wallet: Trie.Trie<Id, Coins_cart> = Trie.empty(); // Transaction history (like a wallet)

  // Function to fetch cryptocurrency exchange rate data from CryptoCompare API
  public func get_coin_compare(coin_value_1: Types.CoinList, coin_value_2: Types.CoinList ) : async Text {
    var coin_1 = "ICP";
    var coin_2 = "USDT";
    switch(coin_value_1) {
      case(#BTC) { coin_1 := "BTC" };
      case(#ETH) { coin_1 := "ETH"};
      case(#ICP) { coin_1 := "ICP"};
      case(#SOL) { coin_1 := "SOL"};
      case(#BNB) { coin_1 := "BNB"};
      case(#USDT) { coin_1 := "USDT"};
      case(#TRY) { coin_1 := "TRY"};
    };

    switch(coin_value_2) {
      case(#BTC) { coin_2 := "BTC" };
      case(#ETH) { coin_2 := "ETH"};
      case(#ICP) { coin_2 := "ICP"};
      case(#SOL) { coin_2 := "SOL"};
      case(#BNB) { coin_2 := "BNB"};
      case(#USDT) { coin_2 := "USDT"};
      case(#TRY) { coin_2 := "TRY"};
    };

    let host : Text = "min-api.cryptocompare.com";
    let url = "https://" # host # "/data/price?fsym=" # coin_1 # "&tsyms=" # coin_2 # "";

    let request_headers = [
        ("Host", host),
        ("User-Agent", "exchange_rate_canister")
    ];

    let http_request : Types.HttpRequestArgs = {
        url = url;
        headers = request_headers;
        body = null;
        method = #get;
    };

    Cycles.add<system>(20_949_972_000);

    let http_response : Types.HttpResponsePayload = await ic.http_request(http_request);
    let response_body: Blob = http_response.body;
    let decoded_text: Text = switch (Text.decodeUtf8(response_body)) {
        case (null) { "No value returned" };
        case (?y) { y };
    };
    decoded_text
  };

  // Function to add an item to the shopping cart
  public func add_cart(coin_cart: Coins_cart) : async Id {
    let id = next;
    next += 1;
    cart := Trie.replace(
      cart,
      key(id),
      Nat32.equal,
      ?coin_cart,
    ).0;
    return id;
  };

  // Function to read an item from the shopping cart by ID
  public query func read(id : Id) : async ? Coins_cart {
    let result = Trie.find(cart, key(id), Nat32.equal);
    return result;
  };

  // Function to delete an item from the shopping cart by ID
  public func deleteCart(id: Id) : async Bool{
    let result = Trie.find(cart, key(id), Nat32.equal);
    let exists = Option.isSome(result); 
    if (exists) {
      cart := Trie.replace(
        cart,
        key(id),
        Nat32.equal,
        null
      ).0;
    };

    exists
  };

  // Function to update an item in the shopping cart
  public func updateCart(id: Id, new_product: Coins_cart) : async Bool {
    let result = Trie.find(cart, key(id), Nat32.equal);
    let exists = Option.isSome(result);
    if(exists) {
      cart := Trie.replace(
        cart,
        key(id),
        Nat32.equal,
        ?new_product
      ).0;   
    };
    exists
  };

  // Function to move items from the cart to the wallet (representing a purchase)
  public func order() : async (){
    temp := Trie.clone(cart);
    wallet := Trie.merge(wallet, temp, Nat32.equal);
  };

  // Function to read an item from the wallet (transaction history) by ID
  public query func read_wallet(id : Id) : async ? Coins_cart {
    let result = Trie.find(wallet, key(id), Nat32.equal);
    return result;
  };

  // Function to clear the shopping cart
  public func clear_cart() : async (){
    cart := Trie.empty();
  };

   // Private helper function to create a key for the Trie data structure
  private func key(x : Id) : Trie.Key<Id> {
    return { hash = x; key = x };
  };

}
