import Map "mo:base/HashMap";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Principal "mo:base/Principal";

actor SocialMedia {
    // Define a Post data structure
    type Post = {
        author: Principal;   // Who wrote the post
        content: Text;       // The text of the post
        timestamp: Time.Time; // When the post was created
    };

    // Helper function to hash a Nat (natural number) to use as a key in the map
    func natHash(n: Nat): Hash.Hash {
        Text.hash(Nat.toText(n)); // Convert to text first for consistent hashing
    };

    // Storage for posts, using Nats as unique IDs
    var posts = Map.HashMap<Nat, Post>(0, Nat.equal, natHash); 
    var nextId: Nat = 0;  // Keeps track of the next available ID

    // Public query to get all posts as an array
    public query func getPosts(): async [(Nat, Post)] {
        Iter.toArray(posts.entries()); // Convert map entries to array for return
    };

    // Public shared function to add a new post (only the caller can add)
    public shared (msg) func addPost(content: Text): async Text {
        let id = nextId;
        posts.put(id, { author = msg.caller; content = content; timestamp = Time.now() });
        nextId += 1;  // Increment for next post
        return "The post was successfully added. Post ID: " # Nat.toText(id);
    };

    // Public query to view a specific post by ID
    public query func viewPost(id: Nat): async ?Post {
        posts.get(id); // Returns the Post if found, otherwise null
    };

    // Admin function to clear all posts (consider adding authorization)
    public func clearPosts(): async () {
        for (key in posts.keys()) {  // Iterate over keys
            ignore posts.remove(key); // Remove each post
        };
    };


    // Public shared function to edit an existing post (only the author can edit)
    public shared (msg) func editPost(id: Nat, newContent: Text): async Bool {
        switch (posts.get(id)) {
            case (?post) { // Post found
                if (post.author == msg.caller) { // Check if caller is the author
                    posts.put(id, { author = msg.caller; content = newContent; timestamp = post.timestamp });
                    return true; // Edit successful
                } else {
                    return false; // Not authorized to edit
                };
            };
            case null { // Post not found
                return false; 
            };
        };
    };
};
