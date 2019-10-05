#!/bin/bash

# Install sqlite3 if it is not already installed
if [[ -z $(which sqlite3) ]]
then
	sudo apt install sqlite3
fi

# Create Database "blogdata.db" and two tables "post" and "category"
if [[ ! -e blogdata.db ]]
then
	sqlite3 blogdata.db "CREATE TABLE category (cat_id INTEGER primary key autoincrement not null, cat_name varchar(30) not null);"

	sqlite3 blogdata.db "CREATE TABLE post (post_id INTEGER primary key autoincrement not null, title varchar(100) not null, content varchar(1000) not null, cat_id varchar(30), foreign key(cat_id) references category(cat_id) on delete no action on update no action);"
fi

# regular expression to check if given argument is a positive integer
re='^[1-9][0-9]*$'

if [[ -z $1 ]]
then
	# Simply Display the name of the Application (command: ./blog.sh)
	echo "My Blog Application"
else
	echo -e "\n================================================================================\n"
	case $1 in
	
		"--help")
		
			# Display Help text and list of available commands (command: ./blog.sh --help)
			echo "=========================="
			echo "List Of Available commands"
			echo -e "==========================\n"
			echo -e '\033[1m$ blog.sh post add "title" "content"\033[0m => Add a new blog post with the specified title and content \n'
			echo -e '\033[1m$ blog.sh post detail <post_id>\033[0m => Display details corresponding to post with given <post_id> \n'
			echo -e '\033[1m$ blog.sh post list\033[0m => List all blog posts \n'
			echo -e '\033[1m$ blog.sh post list --category <cat_id>\033[0m => List all blog posts with given <cat_id> \n'
			echo -e '\033[1m$ blog.sh post update <post_id> --title "new title"\033[0m => Update the title for post with given <post_id> \n'
			echo -e '\033[1m$ blog.sh post update <post_id> --content "new content"\033[0m => Update the title for post with given <post_id> \n'
			echo -e '\033[1m$ blog.sh post remove <post_id>\033[0m => Remove post with given <post_id> \n'
			echo -e '\033[1m$ blog.sh post search "keyword"\033[0m => List all blog posts where “keyword” is found in the title and/or content \n'
			echo -e '\033[1m$ blog.sh category add "category-name"\033[0m => Create a new category \n'
			echo -e '\033[1m$ blog.sh category list\033[0m => List all current categories \n'
			echo -e '\033[1m$ blog.sh category remove <cat_id>\033[0m => Remove category with given <cat_id> \n'
			echo -e '\033[1m$ blog.sh category assign <post_id> <cat_id>\033[0m => Assign the specified category to a post \n'
			echo -e '\033[1m$ blog.sh post add "title" "content" --category "cat-name"\033[0m => Add a new blog post with the specified title, content and assign a category to it. If the category doesn’t exist, it will first be created. \n';;
		
		# Options for ./blog.sh post
		"post")
		
			case $2 in
				
				# Add the post in database (command: ./blog.sh post add "title" "content")
				"add")
					
					# If no title is provided for the post
					if [[ -z $3 ]]
					then
						echo -e '"title" cannot be null!! Please provide "title" for the post\n'
					
					# If no content is provided for the post
					elif [[ -z $4 ]]
					then
						echo -e '"content" cannot be null!! Please provide "content" for the post\n'
						
					# Add the post with given title and content in the database
					else
					
						# If --category option is not provided, add post without category
						if [[ -z $5 ]]
						then
							sqlite3 blogdata.db "INSERT INTO post (title, content) VALUES ('$3', '$4');"
							echo -e "Post added successfully!\n"
						
						# If option is not "--category", display error
						elif [[ $5 != "--category" ]]
						then
							echo -e "Invalid option! $5 is not defined\n"
						
						# If empty category name provided, display error
						elif [[ -z $6 ]]
						then
							echo -e "Please provide non-empty content!\n"
							
						else
							category_id=$(sqlite3 blogdata.db "SELECT cat_id FROM category WHERE cat_name='$6';")
							
							# If given category doesn't exist, create it first
							if [[ -z $category_id ]]
							then
								sqlite3 blogdata.db "INSERT INTO category (cat_name) VALUES ('$6');"
								category_id=$(sqlite3 blogdata.db "SELECT cat_id FROM category WHERE cat_name='$6';")
							fi
							
							sqlite3 blogdata.db "INSERT INTO post (title, content, cat_id) VALUES ('$3', '$4', '$category_id');"
							echo -e "Post added successfully!\n"
						fi
						
					fi
					
					;;
				
				# Display the details corresponding to post with given <post_id>
				# Command: ./blog.sh post detail <post_id>
				"detail")
					
					# If <post_id> is not provided
					if [[ -z $3 ]]
					then
						echo -e "Please provide the <post_id> of the post that you want to view!\n"
					
					# If <post_id> is not valid (not a positive integer)
					elif ! [[ $3 =~ $re ]]
					then
						echo -e "Please provide a valid <post_id>!\n"
					
					else
						sqlite3 -column -header blogdata.db "SELECT * FROM post WHERE post_id='$3';"
						echo ""
					fi
					
					;;
				
				# List all the posts in the database (command: ./blog.sh post list)
				"list")
					
					# List all the posts if --category option is not provided
					if [[ -z $3 ]]
					then
						sqlite3 -column -header blogdata.db "SELECT * FROM post;"
						
					elif [[ $3 != "--category" ]]
					then
						echo 'Invalid option! Use "./blog.sh --help" get the list of available commands'
					
					# Display error if invalid <cat_id> (not a postive integer) is provided
					elif ! [[ $4 =~ $re ]]
					then
						echo "Please provide a valid <cat_id>!"
					
					# Display all the posts with given <cat_id>
					else
						sqlite3 -column -header blogdata.db "SELECT * FROM post WHERE cat_id='$4'"
					fi
					
					echo ""
					;;
					
				# Update the title or content of post with given <post_id>
				# Command: ./blog.sh post update <post_id> --title "new title" OR
				# Command: ./blog.sh post update <post_id> --category "new content"
				"update")
				
					# If <post_id> is not provided
					if [[ -z $3 ]]
					then
						echo -e "Please provide the <post_id> of the post that you want to view!\n"
					
					# If <post_id> is not valid (not a positive integer)
					elif ! [[ $3 =~ $re ]]
					then
						echo -e "Please provide a valid <post-id>!\n"
					
					else
						# Update the title or content of the post with given <post_id>
						case $4 in
						
							"--title")
							
								# If no title is provided for the post
								if [[ -z $5 ]]
								then
									echo '"title" cannot be null!! Please provide "title" to update the post'
								
								# Update the title
								else
									sqlite3 blogdata.db "UPDATE post SET title='$5' WHERE post_id='$3';"
									echo "The title of the post with id=$3 has been updated successfully!"
								fi
								;;
								
							"--content")
							
								# If no content is provided for the post
								if [[ -z $5 ]]
								then
									echo '"content" cannot be null!! Please provide "content" to update the post'
								
								# Update the content
								else
									sqlite3 blogdata.db "UPDATE post SET content='$5' WHERE post_id='$3';"
									echo "The content of the post with id=$3 has been updated successfully!"
								fi
								;;
								
							*)
							
								echo 'Invalid option!! Use "./blog.sh --help" to get the list of available commands'
								;;
						
						esac
						
						echo ""
					fi
				
					;;
				
				# Remove post with given id from the database (command: ./blog.sh post remove <post_id>)
				"remove")
					
					# Display error if <post_id> is not provided
					if [[ -z $3 ]]
					then
						echo "Please provide non-null post id"
					else
						sqlite3 blogdata.db "DELETE FROM post WHERE post_id='$3';"
						echo "Post with id=$3 deleted successfully"
					fi
					
					echo "";;
				
				# Search for "keyword" in "title" and "content" column of post (command: ./blog.sh post search "keyword")
				"search")
					
					sqlite3 -column -header blogdata.db "SELECT * FROM post WHERE title LIKE '%$3%' OR content LIKE '%$3%';"
					echo "";;
				
				# If command is not available, display error
				*)
					
					echo -e 'Invalid Command!! Use "./blog.sh --help" to get the list of available commands\n';;
					
			esac
			;;
		
		# Options for ./blog.sh category
		"category")
		
			case $2 in
				
				# Add the category in database
				"add")
					
					# If no name is provided for the category
					if [[ -z $3 ]]
					then
						echo -e '"category name" cannot be null!! Please provide "category name" for the post\n'
					
					# Add the category with given name in the database
					else
						sqlite3 blogdata.db "INSERT INTO category (cat_name) VALUES ('$3');"
						echo -e "Category added successfully!\n"
					fi
					
					;;
				
				# List all the categories in the database
				"list")
					
					sqlite3 -column -header blogdata.db "SELECT * FROM category;"
					echo "";;
					
				# Remove category with given id from the database (command: ./blog.sh post remove <cat_id>)
				"remove")
					
					# Display error if <cat_id> is not provided
					if [[ -z $3 ]]
					then
						echo "Please provide non-null category id"
					else
						sqlite3 blogdata.db "DELETE FROM category WHERE cat_id='$3';"
						echo "Category with id=$3 deleted successfully"
					fi
					
					echo "";;
				
				# Assign catgeory with given <cat_id> to post with given <post_id>
				"assign")
					
					sqlite3 -column -header blogdata.db "UPDATE post SET cat_id=$4 WHERE post_id=$3;"
					echo -e "Post with id=$3 has been assigned category with id=$4\n";;
				
				*)
					
					echo -e 'Invalid Command!! Use "./blog.sh --help" to get the list of available commands\n';;
					
			esac
			;;
			
		*)
			
			echo -e 'Invalid Command!! Use "./blog.sh --help" to get the list of available commands\n';;
		
	esac
	
	echo -e "================================================================================\n"
fi
