import ballerina/io;
import ballerina/grpc;

import ballerina/lang.'float as floats;

onlineShoppingClient ep = check new ("http://localhost:9090");

public function main() returns error? {
    while true {
        displayMainMenu();
        string choice = io:readln("What would you like to do? Enter the number: ");
        io:println("*******************************************************************");

        match choice {
            "1" => { check browseProducts(); }
            "2" => { check manageCart(); }
            "3" => { check accountOperations(); }
            "4" => { check inventoryManagement(); }
            "5" => {
                io:println("Thank you for using our E-commerce Platform. Have a great day!");
                return;
            }
            _ => {
                io:println("Oops! That's not a valid option. Let's try again.");
            }
        }
        io:println("\nHit Enter to return to the main menu...");
        _ = io:readln();
    }
}

function displayMainMenu() {
    io:println("****************************************************************");
    io:println("   Welcome to Our E-commerce Platform   ");
    io:println("****************************************************************");
    io:println("1. Browse Products");
    io:println("2. Manage Your Cart");
    io:println("3. Account Operations");
    io:println("4. Inventory Management (Admin Only)");
    io:println("5. Exit");
    io:println("***************************************************************");
}

function browseProducts() returns error? {
    io:println("--- Product Catalog ---");
    stream<Product, error?> productStream = check ep->listAvailableProducts();
    check productStream.forEach(function(Product p) {
        io:println(`${p.name} (SKU: ${p.sku}) - $${p.price}`);
    });
    
    string sku = io:readln("Enter the SKU of the product you'd like to know more about (or press Enter to go back): ");
    if sku != "" {
        ProductResponse|error response = ep->searchProduct(sku);
        if response is ProductResponse {
            io:println("Product details: ", response);
        } else {
            io:println("Error searching for product: ", response.message());
        }
    }
}

function manageCart() returns error? {
    io:println("--- Cart Management ---");
    string action = io:readln("Do you want to (A)dd to cart or (C)heckout? ");
    if action.toUpperAscii() == "A" {
        string userId = io:readln("Please enter your user ID: ");
        string sku = io:readln("What's the SKU of the product you want to add? ");

        Cart cart = { user_id: userId, sku: sku };
        CartResponse|error response = ep->addToCart(cart);
        if response is CartResponse {
            io:println("Great choice! Item added to your cart: ", response);
        } else {
            io:println("Error adding item to cart: ", response.message());
        }
    } else if action.toUpperAscii() == "C" {
        string userId = io:readln("Please enter your user ID to complete the checkout: ");
        placeOrderRequest request = { user_id: userId };
        OrderResponse|error response = ep->placeOrder(request);
        if response is OrderResponse {
            io:println("Fantastic! Your order has been placed: ", response);
        } else {
            io:println("Error placing order: ", response.message());
        }
    } else {
        io:println("Action not recognized. Returning to main menu.");
    }
}

function accountOperations() returns error? {
    io:println("--- Account Operations ---");
    string id = io:readln("Let's set up your account. What user ID would you like? ");
    string name = io:readln("Great! Now, what's your full name? ");
    string role = io:readln("Are you a (C)ustomer or (A)dmin? ");
    role = (role.toUpperAscii() == "A") ? "admin" : "customer";

    User user = { id: id, name: name, role: role };
    CreateUsersStreamingClient streamingClient = check ep->createUsers();
    check streamingClient->sendUser(user);
    check streamingClient->complete();

    // Handle the optional response
    UserCreationResponse|grpc:Error? optionalResponse = streamingClient->receiveUserCreationResponse();
    
    if optionalResponse is UserCreationResponse {
        io:println("Wonderful! Your account has been created.");
        io:println("Created users: ", optionalResponse.users);
    } else if optionalResponse is grpc:Error {
        io:println("Error creating account: ", optionalResponse.message());
    } else {
        io:println("No response received from the server. Please try again later.");
    }
}


function inventoryManagement() returns error? {
    io:println("--- Inventory Management ---");
    string action = io:readln("Would you like to (A)dd, (U)pdate, or (R)emove a product? ");
    
    if action.toUpperAscii() == "A" {
        check addNewProduct();
    } else if action.toUpperAscii() == "U" {
        check updateExistingProduct();
    } else if action.toUpperAscii() == "R" {
        check removeExistingProduct();
    } else {
        io:println("Action not recognized. Returning to main menu.");
    }
}

function addNewProduct() returns error? {
    io:println("Adding a new product to our catalog:");
    Product product = {
        name: io:readln("What's the name of the new product? "),
        description: io:readln("Please provide a brief description: "),
        price: check getValidPrice("What's the price? $"),
        sku: io:readln("Assign a unique SKU: "),
        status: getProductStatus()
    };

    ProductResponse|error response = ep->addProduct(product);
    if response is ProductResponse {
        io:println("Excellent! New product added to our catalog: ", response);
    } else {
        io:println("Error adding product: ", response.message());
    }
}

function updateExistingProduct() returns error? {
    string sku = io:readln("What's the SKU of the product you want to update? ");
    io:println("Let's update the product information:");
    Product product = {
        sku: sku,
        name: io:readln("New product name (press Enter to keep current): "),
        description: io:readln("New description (press Enter to keep current): "),
        price: check getValidPrice("New price (press Enter to keep current): $"),
        status: getProductStatus()
    };

    ProductResponse|error response = ep->updateProduct(product);
    if response is ProductResponse {
        io:println("Perfect! Product information updated: ", response);
    } else {
        io:println("Error updating product: ", response.message());
    }
}

function removeExistingProduct() returns error? {
    string sku = io:readln("What's the SKU of the product you want to remove from the catalog? ");
    ProductResponse|error response = ep->removeProduct(sku);
    if response is ProductResponse {
        io:println("Alright, the product has been removed from our catalog: ", response);
    } else {
        io:println("Error removing product: ", response.message());
    }
}

function getValidPrice(string prompt) returns float|error {
    while true {
        string input = io:readln(prompt);
        if input == "" {
            return 0.0;  // Assuming 0.0 means "keep current price"
        }
        float|error price = floats:fromString(input);
        if price is float {
            return price;
        }
        io:println("Invalid price. Please enter a valid number.");
    }
}

function getProductStatus() returns string {
    while true {
        string status = io:readln("Is it (A)vailable or (O)ut of stock? ");
        if status.toUpperAscii() == "A" {
            return "Available";
        } else if status.toUpperAscii() == "O" {
            return "Out of Stock";
        }
        io:println("Invalid input. Please enter 'A' for Available or 'O' for Out of Stock.");
    }
}
