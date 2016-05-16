Red/System [
	Title:   "libonion binding"
	Author:  "JankoM"
	License: "BSD-3 - https://github.com/red/red/blob/master/BSD-3-License.txt"
]

#define size_t! integer!
#define uv_loop_t!   [pointer! [byte!]] ;handle!

O_ONE: 1
O_ONE_LOOP: 3
O_THREADED: 4
O_DETACH_LISTEN: 8
O_SYSTEMD: 16


OCS_NOT_PROCESSED: 0
OCS_NEED_MORE_DATA: 1
OCS_PROCESSED: 2
OCS_CLOSE_CONNECTION: -2
OCS_KEEP_ALIVE: 3
OCS_WEBSOCKET: 4
OCS_REQUEST_READY: 5 ; ///< Internal. After parsing the request it is ready to handle.
OCS_INTERNAL_ERROR: -500
OCS_NOT_IMPLEMENTED: -501
OCS_FORBIDDEN: -502
OCS_YIELD: -3

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
			callback [ function! [ p [pointer! [ integer! ]] req [ pointer! [ integer! ]] res [ pointer! [ integer! ] ] return: [ integer! ] ] ]
			return: [ integer! ]
		]

		;//onion_websocket *		onion_websocket_t::onion_websocket_new (onion_request *req, onion_response *res)
		;// ex: onion_websocket *ws=onion_websocket_new(req, res)

		onion-websocket-new: "onion_websocket_new" [ ""
			req [ pointer! [ integer! ] ]
			res [ pointer! [ integer! ] ]
			return:  [ pointer! [ integer! ]]	 
		]


		; //onion_websocket_t::onion_websocket_write (onion_websocket *ws, const char *buffer, size_t _len)

		onion-websocket-write: "onion_websocket_write" [ ""
			ws [ pointer! [ integer! ] ]
			text [ c-string! ]
			len [ integer! ]
			return: [ integer! ]
		]


		;// void 	onion_websocket_t::onion_websocket_set_callback (onion_websocket *ws, onion_websocket_callback_t cb)	
		;// ex: onion_websocket_set_callback(ws, websocket_example_cont);

		onion-websocket-set-callback: "onion_websocket_set_callback" [ ""
			ws [ pointer! [ integer! ] ]
			callback [ function! [ data [pointer! [ integer! ]] ws [ pointer! [ integer! ]] len [integer! ] return: [ integer! ] ] ]
		]


		;//onion_websocket_read(ws, tmp, data_ready_len);
		
		onion-websocket-read: "onion_websocket_read" [ ""
			ws [ pointer! [ integer! ] ]
			tmp [ c-string!  ]
			len [ integer! ]
			return:  [ integer! ]	 
		]

		;// https://styloop.com/pakjce/onion/code/v0.7/examples/websockets/websockets.c - example

		onion-request-get-queryd: "onion_request_get_queryd" [ ""
			req [ pointer! [ integer! ] ]
			key [ c-string! ]
			def [ c-string! ]
			return:  [ c-string! ]	 
		]
	]
]

main: does [ 

    print "Now starting.\n"

    loop1: declare pointer! [ integer! ]
    loop1: onion-new O_THREADED 

    urls: declare pointer! [ integer! ]
    urls: onion-root-url loop1

    onion-url-add-static urls "test" "Static test." 200
    onion-url-add urls "" :hello-red

    onion-url-add urls "ws" :websocket-example

    onion-listen loop1

    print "Now quitting.\n"
    onion-free loop1
]

hello-red: func [[cdecl] p [pointer! [ integer! ]] req [ pointer! [ integer! ]] res [ pointer! [ integer! ]] return: [ integer! ] ] [ 
	onion-response-write-0 res "Hello world from *Red*!"
	cc: onion-request-get-queryd req "aaa" "zzz"
	onion-response-write-0 res cc
	return OCS_PROCESSED
]

websocket-example: func [ [cdecl] data [pointer! [ integer! ]] req [ pointer! [ integer! ]] res [ pointer! [ integer! ]] return: [ integer! ] ] [
	
    ws: declare pointer! [ integer! ]
	ws: onion-websocket-new req res

	either ws = null [
		onion-response-write-0 res 
		"<html><body><h1>Easy echo</h1><pre id='chat'></pre><script>init = function(){ msg=document.getElementById('msg'); msg.focus();  ws=new WebSocket('ws://'+window.location.host+'/ws'); ws.onmessage=function(ev){  document.getElementById('chat').textContent+=ev.data+'\ '; };}"
		onion-response-write-0 res 
		"; window.addEventListener('load', init, false);</script> <input type='text' id='msg' onchange='javascript:ws.send(msg.value); msg.select(); msg.focus();'/> </body></html>"
		return OCS_PROCESSED
	] [
		
		onion-websocket-write ws "Hello!" 6
		onion-websocket-set-callback ws :websocket-example-cont
		
		return OCS_WEBSOCKET
	]
]


websocket-example-cont: func [ [cdecl] data [pointer! [ integer! ]] ws [ pointer! [ integer! ]] data-ready-len [ integer! ] return: [ integer! ]] [
	tmp2: "                                                                                                                                        " 
	;if (data_ready_len>sizeof(tmp))
	;data_ready_len=sizeof(tmp)-1;

	len: 0
	len: onion-websocket-read ws tmp2 data-ready-len
	if (len = 0) [ 
		;ONION_ERROR("Error reading data: %d: %s (%d)", errno, strerror(errno), data_ready_len);
		; wait(1)
		return OCS_NEED_MORE_DATA
		
	]

	tmpend: tmp2 + len
	;//tmp[len]=0;

	print ">>>"
	print tmp2
	
	onion-websocket-write ws tmp2 len
	
	;ONION_INFO("Read from websocket: %d: %s", len, tmp);
	
	return OCS_NEED_MORE_DATA
]

main