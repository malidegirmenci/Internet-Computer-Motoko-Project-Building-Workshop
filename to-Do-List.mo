import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Iter "mo:base/Iter";

// Actor is the base unit of computation in Motoko, can have state, methods
actor ToDo {
    // A mutable HashMap to store tasks. Text keys (task IDs) mapped to Task values
    let Tasks = HashMap.HashMap<Text, Task>(0, Text.equal, Text.hash);

    // Custom type definition for a Task. Task contains topic, description, completion status
    public type Task = {
        topic: Text;
        description: Text;
        completed: Bool;
    };

    // **Create**
    // Public function to add a new task with given ID, topic, description
    public func add_task (id: Text, new_topic: Text, new_description: Text) : async Bool {
        // Check for empty input values. Empty values are not allowed for topic, description, and id
        if (id != "" and new_topic != "" and new_description != "") {
            Tasks.put(id, {topic = new_topic; description = new_description; completed = false});
            return true; // Task added successfully
        } else {
            return false; // Task not added due to empty input
        }
    };

    // **Read**
    // Public query function to get all the tasks in the HashMap
    public query func get_tasks() : async [Task] {
        return Iter.toArray(Tasks.vals()); // Convert Iterator to an Array for return
    };

    // **Update**
    // Public function to mark a task as complete based on its id. 
    // 'ignore' to discard the optional result since we don't care about errors here.
    public func complete_task(id: Text) : async () {
        ignore do ? { 
            let task_topic = Tasks.get(id)!.topic; // Extract the topic. The '!' asserts it's not null
            let task_description = Tasks.get(id)!.description; // Extract the description

            // Update the task with the same topic, description, but completed is now true
            Tasks.put(id, {topic = task_topic; description = task_description; completed = true});
        };
    };
 
    // **Delete**
    // Public function to delete a task based on its id.
    public func delete_task(id: Text) : async () {
        Tasks.delete(id); // Remove task from HashMap
    }
};
