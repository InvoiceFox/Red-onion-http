Red/System [
	   Title:   "libonion binding"
	   Author:  "JankoM"
	   License: "BSD-3 - https://github.com/red/red/blob/master/BSD-3-License.txt"
]

#define size_t! integer!
#define uv_loop_t!   [pointer! [byte!]] ;handle!

#import [
	"/home/jimny/Work/Red/Red-onion-http/libonion.so" cdecl [

		   onion-new: "onion_new" [ ""
		   	  flags   [ integer! ]
		   	  return:  [ pointer! [ integer! ]]	 
		   ]

		   onion-root-url: "onion_root_url" [ "" 
		   		  onion [ pointer! [ integer! ] ]
				  return: [ pointer! [ integer! ] ]
				  ]

		   onion-url-add-static: "onion_url_add_static" [ ""
		   		  onion [ pointer! [ integer! ] ]
		   	  path   [ c-string! ]
		   	  response  [ c-string! ]
		   	  status   [ integer! ]
		]		  

		   onion-handler-directory: "onion_handler_directory" [ ""
		   	  patha   [ c-string! ]
		   	  return:  [ pointer! [ integer! ]]	 
		   ]

		   onion-set-root-handler: "onion_set_root_handler" [ ""
		   			   onion [ pointer! [ integer! ] ]
					   onion_handler [ pointer! [ integer! ] ]
					   ]
		   onion-listen: "onion_listen" [ ""
		   		 onion [ pointer! [ integer! ] ]
		   ]
		   onion-free: "onion_listen" [ ""
		   		 onion [ pointer! [ integer! ] ]
		   ]

		   onion-response-write-0: "onion_response_write0" [ "" 
			response [ pointer! [ integer! ] ]
			text [ c-string! ]
		]
		onion-url-add: "onion_url_add" [ ""
		       urls [ pointer! [ integer! ]]
		       path [ c-string! ]
		       callback [ function! [ p [pointer! [ integer! ]] req [ pointer! [ integer! ]] res [ pointer! [ integer! ]] ] ]

		]
	]
]

main: does [ 

    print "Now starting.\n"

    loop1: declare pointer! [ integer! ]
    loop1: onion-new 0 

    urls: declare pointer! [ integer! ]
    urls: onion-root-url loop1

    onion-url-add-static urls "test" "Static test." 200
    onion-url-add urls "" :hello-red

    onion-listen loop1

    print "Now quitting.\n"
    onion-free loop1
]

hello-red: func [[cdecl] p [pointer! [ integer! ]] req [ pointer! [ integer! ]] res [ pointer! [ integer! ]] ] [ 
	   onion-response-write-0 res "Hello world from *Red*!"
]

main