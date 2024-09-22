# DISTRIBUTED SYSTEMS AND APPLICATIONS ASSIGNMENT 01 2024

Course Code: DSA612S

STUDENT NAMES :

THOMAS ROBERT 220108129,JONAS TOBIAS 21601730, HAMUKOTO V 220104697,PANDULENI PAULUS 218062885, MWAETAKO STEFANUS 220119805, SHONGOLO JAKULA FG 215010728, ASHIPALA JOEL 215070054

This assignment covers two tasks:

Programme Management System using RESTful APIs.
Online Shopping System using gRPC. Both tasks require server and client-side implementation using the Ballerina language.

QUESTION 1

Programme Management System (RESTful API)

Create a RESTful API to manage programme workflows at the Programme Development Unit. Each programme contains multiple courses and has attributes such as: • Programme Code (unique identifier) • NQF Level, Faculty, Department, Title, Registration Date • List of Courses (each with a name, code, and NQF level) API Functionalities:

Add a new programme.
List all programmes.
Update a programme by code.
Get programme details by code.
Delete a programme by code.
List programmes due for review.
List programmes by faculty.


QUESTION 2

Online Shopping System (gRPC)

Develop a gRPC-based system for customers and admins. Key operations include:

add_product: Admin adds a product (name, description, price, SKU, etc.).
create_users: Stream multiple users to the server.
update_product: Admin updates product details.
remove_product: Admin removes a product and returns the updated list.
list_available_products: Customers list available products.
search_product: Customers search for a product by SKU.
add_to_cart: Customers add products to their cart.
place_order: Customers place an order.
