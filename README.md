# NextCloud favourite share

A command-line application that copies a user's favourite files to a folder.

This is intended to be used for automatically sharing favourites via a group
folder.

## Usage

The application is in `bin/main.dart`.

	Available options:
	--host                                The NextCloud host to connect to
					      (defaults to "http://localhost:8081")
	--username                            The username to connect with
					      (defaults to "admin")
	--password                            The password to use
					      (defaults to "admin")
	--source-dir=</files/admin/>          WebDAV path of the directory to scan for favourites
	--target-dir=</files/admin/shared>    WebDAV path of the directory to copy favorites to
