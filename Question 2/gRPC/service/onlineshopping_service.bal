import ballerina/grpc;

listener grpc:Listener ep = new (9090);

type UserEntry record {|
    readonly string id;
    User user;
|};

type CartEntry record {|
    readonly string user_id;
    Cart cart;
|};

type ProductEntry record {|
    readonly string sku;
    Product product;
|};

table<UserEntry> key(id) users_table = table [];
table<CartEntry> key(user_id) carts_table = table [];
table<ProductEntry> key(sku) products_table = table [];

@grpc:Descriptor {value: ONLINE_SHOPPING_DESC}
service "onlineShopping" on ep {
    function createUsers(stream<User, grpc:Error?> clientStream) returns UserCreationResponse|error {
        User[] createdUsers = [];
        check clientStream.forEach(function(User user) {
            users_table.add({id: user.id, user: user});
            createdUsers.push(user);
        });
        return {users: createdUsers};
    }

    function listAvailableProducts() returns stream<Product, error?>|error {
        return stream from var entry in products_table.toArray()
                      where entry.product.status == "Available"
                      select entry.product;
    }

    function searchProduct(string sku) returns ProductResponse|error {
        ProductEntry? entry = products_table[sku];
        if entry is ProductEntry {
            return {message: "Product located in inventory", product: entry.product};
        }
        return error("Product not found in inventory");
    }

    function addProduct(Product product) returns ProductResponse|error {
        products_table.add({sku: product.sku, product: product});
        return {message: "New product successfully added to inventory", product: product};
    }

    function updateProduct(Product product) returns ProductResponse|error {
        products_table.put({sku: product.sku, product: product});
        return {message: "Product details updated in inventory", product: product};
    }

    function removeProduct(string sku) returns ProductResponse|error {
        ProductEntry? entry = products_table.remove(sku);
        if entry is ProductEntry {
            return {message: "Product successfully removed from inventory", product: entry.product};
        }
        return error("Unable to remove product: not found in inventory");
    }

    function addToCart(Cart cart) returns CartResponse|error {
        carts_table.add({user_id: cart.user_id, cart: cart});
        return {user_id: cart.user_id, message: "Items added to cart successfully"};
    }

    function placeOrder(placeOrderRequest request) returns OrderResponse|error {        
        // Implement order processing logic here
        return {user_id: request.user_id, message: "Order placed successfully"};
    }
}