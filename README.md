# Command Line Blogging Application

The *blog.sh* file can be run using *bash*. At first, it will check if *sqlite3* (which is the database used for this application) is installed or not. If it is not installed, the application will install it automatically using the following command

    sudo apt install sqlite3

It will then check if the database named **blogdata.db** exists or not. If it doesn't exist, it will create the database and two tables named **post** and **category** using below commands:

    sqlite3 blogdata.db "CREATE TABLE category 
			(cat_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
			 cat_name VARCHAR(30) NOT NULL);"

    sqlite3 blogdata.db "CREATE TABLE post 
			(post_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
			 title VARCHAR(100) NOT NULL, 
			 content VARCHAR(1000) NOT NULL, 
			 cat_id VARCHAR(30), 
			 FOREIGN KEY(cat_id) REFERENCES category(cat_id) 
			 ON DELETE SET NULL ON UPDATE CASCADE);"

The user can then use following list of commands to interact with the application through terminal:

1. `bash blog.sh` will return the name of the application
2. `bash blog.sh --help` will list help text and commands available
3. `bash blog.sh post add "title" "content"` will add a new blog post with the specified title and content
4. `bash blog.sh post detail <post_id>` will display the details of the post with given ID
5. `bash blog.sh post list` will list all blog posts
6. `bash blog.sh post list --category <cat_id>` will list all blog posts with given category ID
7. `bash blog.sh post update <post_id> --title "new title"` will update the title of the post with given ID with specified title
8. `bash blog.sh post update <post_id> --content "new content"` will update the content of the post with given ID with specified content
9. `bash blog.sh post remove <post_id>` will remove the post with given ID
10. `bash blog.sh post search "keyword"` will list all blog posts where “keyword” is found in the title and/or content
11. `bash blog.sh category add "category-name"` will create a new category
12. `bash blog.sh category list` will list all current categories
13. `bash blog.sh category remove <cat_id>` will remove the category with given ID
14. `bash blog.sh category assign <post_id> <cat_id>` will assign the specified category to a post
15. `bash blog.sh post add "title" "content" --category <cat_id>` will add a new blog post with the specified title, content and assign a category to it. If the category doesn’t exist, it will first be created.
