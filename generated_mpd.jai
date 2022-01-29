//
// This file was auto-generated using the following command:
//
// jai generate.jai
//



LIBMPDCLIENT_MAJOR_VERSION :: 2;
LIBMPDCLIENT_MINOR_VERSION :: 20;
LIBMPDCLIENT_PATCH_VERSION :: 0;

MPD_SAMPLE_FORMAT :: enum u32 {
    UNDEFINED :: 0;
    FLOAT     :: 224;
    DSD       :: 225;
}

/**
* This structure describes the format of a raw PCM stream.
*/
mpd_audio_format :: struct {
    /**
    * The sample rate in Hz.  A better name for this attribute is
    * "frame rate", because technically, you have two samples per
    * frame in stereo sound.
    *
    * The special value 0 means "unknown or unspecified".
    */
    sample_rate: u32;
    /**
    * The number of significant bits per sample.  Samples are
    * currently always signed.  Supported values are 8, 16, 24,
    * 32 and the special values #MPD_SAMPLE_FORMAT_FLOAT,
    * #MPD_SAMPLE_FORMAT_DSD, #MPD_SAMPLE_FORMAT_UNDEFINED.
    *
    * @since libmpdclient 2.10 added support for #MPD_SAMPLE_FORMAT_FLOAT and
    * #MPD_SAMPLE_FORMAT_DSD.
    */
    bits:        u8;
    /**
    * The number of channels.  Only mono (1) and stereo (2) are
    * fully supported currently.
    *
    * The special value 0 means "unknown or unspecified".
    */
    channels:    u8;
    /** reserved for future use */
    reserved0:   u16;
    /** reserved for future use */
    reserved1:   u32;
}

/**
* \struct mpd_connection
*
* This opaque object represents a connection to a MPD server.  Call
* mpd_connection_new() to create a new instance.  To free an
* instance, call mpd_connection_free().  Example:
*
*     struct mpd_connection *conn = mpd_connection_new(NULL, 0, 0);
*
*     // error handling
*     if (conn == NULL) {
*         fprintf(stderr, "Out of memory\n");
*         return;
*     }
*     if (mpd_connection_get_error(conn) != MPD_ERROR_SUCCESS) {
*         fprintf(stderr, "%s\n", mpd_connection_get_error_message(c));
*         mpd_connection_free(c);
*         return;
*     }
*
*     // we can now use the connection
*     mpd_run_next(conn);
*
*     // close the connection and free memory
*     mpd_connection_free(conn);
*
* Error handling: most functions return a `bool` indicating success
* or failure.  In this case, you may query the nature of the error
* with the functions mpd_connection_get_error(),
* mpd_connection_get_error_message(),
* mpd_connection_get_server_error().
*
* Some errors can be cleared by calling mpd_connection_clear_error(),
* like #MPD_ERROR_SERVER, #MPD_ERROR_ARGUMENT.  Most others are
* fatal, and cannot be recovered, like #MPD_ERROR_CLOSED -
* mpd_connection_clear_error() returns false.
*
* Some functions like mpd_recv_pair() cannot differentiate between
* "end of response" and "error".  If this function returns `NULL`, you
* have to check mpd_connection_get_error().
*
* To integrate this object in a non-blocking event I/O loop, use
* mpd_connection_get_fd() to obtain the underlying socket descriptor.
*/
mpd_connection :: struct {}

/**
* Sends the "albumart" command to MPD.  Call mpd_recv_albumart() to
* read response lines.
*
* @param connection a valid and connected #mpd_connection
* @param uri the URI of the song
* @param offset to read from
* @return true on success
*/
mpd_send_albumart :: (connection: *mpd_connection, uri: *u8, offset: u32) -> bool #foreign libmpdclient;

/**
* Receives the "albumart" response
*
* @param connection a valid and connected #mpd_connection
* @param buffer an already allocated buffer, should be of the same size as the binary
* chunk size (default 8192, can be set with binarylimit command)
* @param buffer_size the size of the allocated buffer
* @return read size on success, -1 on failure
*/
mpd_recv_albumart :: (connection: *mpd_connection, buffer: *void, buffer_size: size_t) -> s32 #foreign libmpdclient;

/**
* Shortcut for mpd_send_albumart(), mpd_recv_albumart() and
* mpd_response_finish().
*
* @param connection a valid and connected #mpd_connection
* @param uri the URI of the song
* @param offset to read from
* @param buffer an already allocated buffer, should be of the same size as the binary
* chunk size (default 8192, can be set with binarylimit command)
* @param buffer_size the size of the allocated buffer
* @return read size on success, -1 on failure
*/
mpd_run_albumart :: (connection: *mpd_connection, uri: *u8, offset: u32, buffer: *void, buffer_size: size_t) -> s32 #foreign libmpdclient;

/**
* Sends the "binarylimit" command to MPD.
*
* @param connection a valid and connected mpd_connection.
* @param limit the binary chunk size limit.
* @return true on success
*
* @since libmpdclient 2.20, MPD 0.22.4
*/
mpd_send_binarylimit :: (connection: *mpd_connection, limit: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_binarylimit() and mpd_response_finish().
*
* @param connection A valid and connected mpd_connection.
* @param limit the binary chunk size limit.
* @return true on success
*
* @since libmpdclient 2.20, MPD 0.22.4
*/
mpd_run_binarylimit :: (connection: *mpd_connection, limit: u32) -> bool #foreign libmpdclient;

/**
* Reads the binary data response from the server.
* The size and binary pair must be already read from the input buffer.
*
* The caller must allocate length bytes of memory for data.
*
* @return true on success
*
* @since libmpdclient 2.17
*/
mpd_recv_binary :: (connection: *mpd_connection, data: *void, length: size_t) -> bool #foreign libmpdclient;

/**
* Reads the next #mpd_pair from the server.  Returns NULL if there
* are no more pairs.
*
* The caller must dispose the pair with either mpd_return_pair() or
* mpd_enqueue_pair().
*/
mpd_recv_pair :: (connection: *mpd_connection) -> *mpd_pair #foreign libmpdclient;

/**
* Same as mpd_recv_pair(), but discards all pairs not matching the
* specified name.
*/
mpd_recv_pair_named :: (connection: *mpd_connection, name: *u8) -> *mpd_pair #foreign libmpdclient;

/**
* Indicates that the pair object is not needed anymore, and can be
* freed.  You must free the previous #mpd_pair object before calling
* mpd_recv_pair() again.
*/
mpd_return_pair :: (connection: *mpd_connection, pair: *mpd_pair) -> void #foreign libmpdclient;

/**
* Unreads a #mpd_pair.  You may unread only the one pair you just got
* from mpd_recv_pair().  Unreading the "NULL" pair is allowed, to
* allow you to call mpd_recv_pair() again at the end of a response.
*/
mpd_enqueue_pair :: (connection: *mpd_connection, pair: *mpd_pair) -> void #foreign libmpdclient;

/**
* @since libmpdclient 2.10 added support for #MPD_TAG_MUSICBRAINZ_RELEASETRACKID.
* @since libmpdclient 2.11 added support for #MPD_TAG_ARTIST_SORT and #MPD_TAG_ALBUM_ARTIST_SORT
* @since libmpdclient 2.17 added support for #MPD_TAG_LABEL,
*                                            #MPD_TAG_MUSICBRAINZ_WORKID,
*                                            #MPD_TAG_GROUPING,
*                                            #MPD_TAG_WORK,
*                                            #MPD_TAG_CONDUCTOR.
*/
mpd_tag_type :: enum s32 {
    UNKNOWN                    :: -1;
    ARTIST                     :: 0;
    ALBUM                      :: 1;
    ALBUM_ARTIST               :: 2;
    TITLE                      :: 3;
    TRACK                      :: 4;
    NAME                       :: 5;
    GENRE                      :: 6;
    DATE                       :: 7;
    COMPOSER                   :: 8;
    PERFORMER                  :: 9;
    COMMENT                    :: 10;
    DISC                       :: 11;
    MUSICBRAINZ_ARTISTID       :: 12;
    MUSICBRAINZ_ALBUMID        :: 13;
    MUSICBRAINZ_ALBUMARTISTID  :: 14;
    MUSICBRAINZ_TRACKID        :: 15;
    MUSICBRAINZ_RELEASETRACKID :: 16;
    ORIGINAL_DATE              :: 17;
    ARTIST_SORT                :: 18;
    ALBUM_ARTIST_SORT          :: 19;
    ALBUM_SORT                 :: 20;
    LABEL                      :: 21;
    MUSICBRAINZ_WORKID         :: 22;
    GROUPING                   :: 23;
    WORK                       :: 24;
    CONDUCTOR                  :: 25;
    COMPOSER_SORT              :: 26;
    ENSEMBLE                   :: 27;
    MOVEMENT                   :: 28;
    MOVEMENTNUMBER             :: 29;
    LOCATION                   :: 30;
    COUNT                      :: 31;
}

/**
* Looks up the name of the specified tag.
*
* @return the name, or NULL if the tag type is not valid
*/
mpd_tag_name :: (type: mpd_tag_type) -> *u8 #foreign libmpdclient;

/**
* Parses a tag name, and returns its #mpd_tag_type value.
*
* @return a #mpd_tag_type value, or MPD_TAG_UNKNOWN if the name was
* not recognized
*/
mpd_tag_name_parse :: (name: *u8) -> mpd_tag_type #foreign libmpdclient;

/**
* Same as mpd_tag_name_parse(), but ignores case.
*
* @return a #mpd_tag_type value, or MPD_TAG_UNKNOWN if the name was
* not recognized
*/
mpd_tag_name_iparse :: (name: *u8) -> mpd_tag_type #foreign libmpdclient;

/**
* Requests a list of supported and allowed commands. Use
* mpd_recv_command_pair() to obtain the list of "command" pairs.
*
* @param connection the connection to MPD
* @return true on success, false on error
*/
mpd_send_allowed_commands :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Requests a list of supported commands which are not allowed for
* this connection.  Use mpd_recv_command_pair() to obtain the list of
* "command" pairs.
*
* @param connection the connection to MPD
* @return true on success, false on error
*/
mpd_send_disallowed_commands :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Requests a list of supported URL handlers in the form "scheme://",
* example: "http://".  Use mpd_recv_url_scheme_pair() to obtain the list
* of "handler" pairs.
*
* @param connection the connection to MPD
* @return true on success, false on error
*/
mpd_send_list_url_schemes :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Requests a list of supported tag types.  Use mpd_recv_tag_type_pair()
* to obtain the list of "tagtype" pairs.
*
* @param connection the connection to MPD
* @return true on success, false on error
*/
mpd_send_list_tag_types :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Remove one or more tags from the list of tag types the client is
* interested in.  These will be omitted from responses to this
* client.
*
* @param connection the connection to MPD
* @param types an array of tag types to disable
* @param n the number of tag types in the array
* @return true on success, false on error
*
* @since libmpdclient 2.12, MPD 0.21
*/
mpd_send_disable_tag_types :: (connection: *mpd_connection, types: *mpd_tag_type, n: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_disable_tag_types() and mpd_response_finish().
*
* @since libmpdclient 2.12, MPD 0.21
*/
mpd_run_disable_tag_types :: (connection: *mpd_connection, types: *mpd_tag_type, n: u32) -> bool #foreign libmpdclient;

/**
* Re-enable one or more tags from the list of tag types for this
* client.  These will no longer be hidden from responses to this
* client.
*
* @param connection the connection to MPD
* @param types an array of tag types to enable
* @param n the number of tag types in the array
* @return true on success, false on error
*
* @since libmpdclient 2.12, MPD 0.21
*/
mpd_send_enable_tag_types :: (connection: *mpd_connection, types: *mpd_tag_type, n: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_enable_tag_types() and mpd_response_finish().
*
* @since libmpdclient 2.12, MPD 0.21
*/
mpd_run_enable_tag_types :: (connection: *mpd_connection, types: *mpd_tag_type, n: u32) -> bool #foreign libmpdclient;

/**
* Clear the list of tag types this client is interested in.  This
* means that MPD will not send any tags to this client.
*
* @param connection the connection to MPD
* @return true on success, false on error
*
* @since libmpdclient 2.12, MPD 0.21
*/
mpd_send_clear_tag_types :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_clear_tag_types() and mpd_response_finish().
*
* @since libmpdclient 2.12, MPD 0.21
*/
mpd_run_clear_tag_types :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Add all tags to the list of tag types this client is interested in.
* This means that MPD will send all tags to this client.
*
* @param connection the connection to MPD
* @return true on success, false on error
*
* @since libmpdclient 2.19, MPD 0.21
*/
mpd_send_all_tag_types :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_all_tag_types() and mpd_response_finish().
*
* @since libmpdclient 2.19, MPD 0.21
*/
mpd_run_all_tag_types :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

mpd_server_error :: enum s32 {
    UNK            :: -1;
    NOT_LIST       :: 1;
    ARG            :: 2;
    PASSWORD       :: 3;
    PERMISSION     :: 4;
    UNKNOWN_CMD    :: 5;
    NO_EXIST       :: 50;
    PLAYLIST_MAX   :: 51;
    SYSTEM         :: 52;
    PLAYLIST_LOAD  :: 53;
    UPDATE_ALREADY :: 54;
    PLAYER_SYNC    :: 55;
    EXIST          :: 56;
}

mpd_error :: enum u32 {
    SUCCESS   :: 0;
    OOM       :: 1;
    ARGUMENT  :: 2;
    STATE     :: 3;
    TIMEOUT   :: 4;
    SYSTEM    :: 5;
    RESOLVER  :: 6;
    MALFORMED :: 7;
    CLOSED    :: 8;
    SERVER    :: 9;
}

mpd_async :: struct {}

/**
* Opens a new connection to a MPD server.  Both the name server
* lookup and the `connect()` call are done synchronously.  After this
* function has returned, you should check if the connection was
* successful with mpd_connection_get_error().
*
* @param host the server's host name, IP address or Unix socket path.
* If the resolver returns more than one IP address for a host name,
* this functions tries all of them until one accepts the connection.
* `NULL` is allowed here, which will connect to the default host
* (using the `MPD_HOST` environment variable if present).
* @param port the TCP port to connect to, 0 for default port (using
* the `MPD_PORT` environment variable if present).  If "host" is a Unix
* socket path, this parameter is ignored.
* @param timeout_ms the timeout in milliseconds, 0 for the default
* timeout (the environment variable `MPD_TIMEOUT` may specify a timeout
* in seconds); you may modify it later with
* mpd_connection_set_timeout()
* @return a mpd_connection object (which may have failed to connect),
* or `NULL` on out-of-memory
*
* @since libmpdclient 2.3 added support for `MPD_HOST`, `MPD_PORT`
* and `MPD_TIMEOUT`.
*/
mpd_connection_new :: (host: *u8, port: u32, timeout_ms: u32) -> *mpd_connection #foreign libmpdclient;

/**
* Creates a #mpd_connection object based on an existing asynchronous
* MPD connection.  You should not continue to use the #mpd_async
* object.  Note that mpd_connection_free() also frees your #mpd_async
* object!
*
* This function does not block at all, which is why you have to pass
* the welcome message to it.
*
* @param async a #mpd_async instance
* @param welcome the first line sent by MPD (the welcome message)
* @return a mpd_connection object, or `NULL` on out-of-memory
*/
mpd_connection_new_async :: (async: *mpd_async, welcome: *u8) -> *mpd_connection #foreign libmpdclient;

/**
* Close the connection and free all memory.
*
* @param connection the connection to MPD
*/
mpd_connection_free :: (connection: *mpd_connection) -> void #foreign libmpdclient;

/**
* \struct mpd_settings
*
* An object which describes configurable connection settings.
*/
mpd_settings :: struct {}
/**
* Returns the settings which were used to connect to the server.  May
* be `NULL` if the settings are not known.
*
* @since libmpdclient 2.4
*/
mpd_connection_get_settings :: (connection: *mpd_connection) -> *mpd_settings #foreign libmpdclient;

/**
* Enables (or disables) TCP keepalives.
*
* Keepalives are enabled using the SO_KEEPALIVE socket option.  They may be
* required for long-idled connections to persist on some networks that
* would otherwise terminate inactive TCP sessions.
*
* The default value is false.
*
* @param connection the connection to MPD
* @param keepalive whether TCP keepalives should be enabled
* @return true on success, false if setsockopt failed
*
* @since libmpdclient 2.10
*/
mpd_connection_set_keepalive :: (connection: *mpd_connection, keepalive: bool) -> bool #foreign libmpdclient;

/**
* Sets the timeout for synchronous operations.  If the MPD server
* does not send a response during this time span, the operation is
* aborted by libmpdclient.
*
* The initial value is the one passed to mpd_connection_new().  If
* you have used mpd_connection_new_async(), then the default value is
* 30 seconds.
*
* @param connection the connection to MPD
* @param timeout_ms the desired timeout in milliseconds; must not be 0
*/
mpd_connection_set_timeout :: (connection: *mpd_connection, timeout_ms: u32) -> void #foreign libmpdclient;

/**
* Returns the file descriptor which should be polled by the caller.
* Do not use the file descriptor for anything except polling!  The
* file descriptor never changes during the lifetime of this
* #mpd_connection object.
*
* To integrate this library in a non-blocking event I/O loop, use
* this function to obtain the underlying socket descriptor and
* register it in the event loop.  As soon as it becomes ready for
* reading, use this library's functions to receive responses from
* MPD.  Example:
*
*     if (!mpd_send_idle(conn))
*         return handle_error();
*     register_socket(mpd_connection_get_fd(conn));
*
* And in the event callback:
*
*     enum mpd_idle events = mpd_recv_idle(conn);
*     // handle the events
*     // .. and then call mpd_send_idle() again to keep listening
*/
mpd_connection_get_fd :: (connection: *mpd_connection) -> s32 #foreign libmpdclient;

/**
* Returns the underlying #mpd_async object.  This can be used to send
* commands asynchronously.  During an asynchronous command, you must
* not use synchronous #mpd_connection functions until the
* asynchronous response has been finished.
*
* If an error occurs while using #mpd_async, you must close the
* #mpd_connection.
*/
mpd_connection_get_async :: (connection: *mpd_connection) -> *mpd_async #foreign libmpdclient;

/**
* Returns the libmpdclient error code.  MPD_ERROR_SUCCESS means no
* error occurred.
*/
mpd_connection_get_error :: (connection: *mpd_connection) -> mpd_error #foreign libmpdclient;

/**
* Returns the human-readable (English) libmpdclient error message.
* Calling this function is only valid if an error really occurred.
* Check with mpd_connection_get_error().
*
* For #MPD_ERROR_SERVER, the error message is encoded in UTF-8.
* #MPD_ERROR_SYSTEM obtains its error message from the operating
* system, and thus the locale's character set (and probably language)
* is used.  Keep that in mind when you print error messages.
*/
mpd_connection_get_error_message :: (connection: *mpd_connection) -> *u8 #foreign libmpdclient;

/**
* Returns the error code returned from the server.  Calling this
* function is only valid if mpd_connection_get_error() returned
* #MPD_ERROR_SERVER.
*/
mpd_connection_get_server_error :: (connection: *mpd_connection) -> mpd_server_error #foreign libmpdclient;

/**
* Returns the location of the server error, i.e. an index within the
* command list.  Calling this function is only valid in a command
* list response, and if mpd_connection_get_error() returned
* #MPD_ERROR_SERVER.
*
* @since libmpdclient 2.4
*/
mpd_connection_get_server_error_location :: (connection: *mpd_connection) -> u32 #foreign libmpdclient;

/**
* Returns the error code from the operating system; on most operating
* systems, this is the errno value.  Calling this function is only
* valid if mpd_connection_get_error() returned #MPD_ERROR_SYSTEM.
*
* May be 0 if the operating system did not specify an error code.
*/
mpd_connection_get_system_error :: (connection: *mpd_connection) -> s32 #foreign libmpdclient;

/**
* Attempts to recover from an error condition.  This function must be
* called after a non-fatal error before you can continue using this
* object.
*
* @return true on success, false if the error is fatal and cannot be
* recovered
*/
mpd_connection_clear_error :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Returns a three-tuple containing the major, minor and patch version
* of the MPD protocol.
*/
mpd_connection_get_server_version :: (connection: *mpd_connection) -> *u32 #foreign libmpdclient;

/**
* Compares the MPD protocol version with the specified triple.
*
* @return -1 if the server is older, 1 if it is newer, 0 if it is
* equal
*/
mpd_connection_cmp_server_version :: (connection: *mpd_connection, major: u32, minor: u32, patch: u32) -> s32 #foreign libmpdclient;

/**
* Get a recursive list of all directories, songs and playlist from
* MPD.  They are returned without metadata.  This is a rather
* expensive operation, because the response may be large.
*
* To read the response, you may use mpd_recv_entity().
*
* @param connection the connection to MPD
* @param path an optional base path for the query
* @return true on success, false on error
*/
mpd_send_list_all :: (connection: *mpd_connection, path: *u8) -> bool #foreign libmpdclient;

/**
* Like #mpd_send_list_all(), but return metadata.  This operation is
* even more expensive, because the response is larger.  If it is
* larger than a configurable server-side limit, MPD may disconnect
* you.
*
* To read the response, you may use mpd_recv_entity().
*
* @param connection the connection to MPD
* @param path an optional base path for the query
* @return true on success, false on error
*/
mpd_send_list_all_meta :: (connection: *mpd_connection, path: *u8) -> bool #foreign libmpdclient;

/**
* Get a list of all directories, songs and playlist in a directory
* from MPD, including metadata.
*
* To read the response, you may use mpd_recv_entity().
*
* @param connection the connection to MPD
* @param path an optional directory to be listed
* @return true on success, false on error
*/
mpd_send_list_meta :: (connection: *mpd_connection, path: *u8) -> bool #foreign libmpdclient;

/**
* Lists the contents of the specified directory, including files that are
* not recognized by MPD (command "listfiles").
*
* To read the response, you may use mpd_recv_entity().  All regular
* files will be reported as #MPD_ENTITY_TYPE_SONG, even if they are
* not actually songs.
*
* @param connection the connection to MPD
* @param uri the directory to be listed
* @return true on success, false on error
*
* @since libmpdclient 2.12, MPD 0.19
*/
mpd_send_list_files :: (connection: *mpd_connection, uri: *u8) -> bool #foreign libmpdclient;

/**
* Send "readcomments".  Read the "comments" of a song file.  This
* returns key/value pairs which can be read using mpd_recv_pair().
*
* @param connection the connection to MPD
* @param path the relative path of the song file within the music
* directory or an arbitrary file path starting with file:///
* @return true on success, false on error
*
* @since libmpdclient 2.9
*/
mpd_send_read_comments :: (connection: *mpd_connection, path: *u8) -> bool #foreign libmpdclient;

/**
* Instructs MPD to update the music database: find new files, remove
* deleted files, update modified files.
*
* @param connection the connection to MPD
* @param path optional path to update; if NULL, then all of the music
* directory is updated
* @return true on success, false on error
*/
mpd_send_update :: (connection: *mpd_connection, path: *u8) -> bool #foreign libmpdclient;

/**
* Like mpd_send_update(), but also rescans unmodified files.
*
* @param connection the connection to MPD
* @param path optional path to update; if NULL, then all of the music
* directory is updated
* @return true on success, false on error
*/
mpd_send_rescan :: (connection: *mpd_connection, path: *u8) -> bool #foreign libmpdclient;

/**
* Receives the id of the update job which was submitted by
* mpd_send_update().
*
* @param connection the connection to MPD
* @return a positive job id on success, 0 on error
*/
mpd_recv_update_id :: (connection: *mpd_connection) -> u32 #foreign libmpdclient;

/**
* Shortcut for mpd_send_update() and mpd_recv_update_id().
*
* @param connection the connection to MPD
* @param path optional path to update; if NULL, then all of the music
* directory is updated
* @return a positive job id on success, 0 on error
*/
mpd_run_update :: (connection: *mpd_connection, path: *u8) -> u32 #foreign libmpdclient;

/**
* Like mpd_run_update(), but also rescans unmodified files.
*
* @param connection the connection to MPD
* @param path optional path to update; if NULL, then all of the music
* directory is updated
* @return a positive job id on success, 0 on error
*/
mpd_run_rescan :: (connection: *mpd_connection, path: *u8) -> u32 #foreign libmpdclient;

/**
* \struct mpd_directory
*
* An opaque directory object.  This is a container for more songs,
* directories or playlists.
*/
mpd_directory :: struct {}

/**
* Duplicates a #mpd_directory object.
*
* @return the new object, or NULL on out of memory
*/
mpd_directory_dup :: (directory: *mpd_directory) -> *mpd_directory #foreign libmpdclient;

/**
* Free memory allocated by the #mpd_directory object.
*/
mpd_directory_free :: (directory: *mpd_directory) -> void #foreign libmpdclient;

/**
* Returns the path of this directory, relative to the MPD music
* directory.  It does not begin with a slash.
*/
mpd_directory_get_path :: (directory: *mpd_directory) -> *u8 #foreign libmpdclient;

/**
* @return the POSIX UTC time stamp of the last modification, or 0 if
* that is unknown
*
* @since libmpdclient 2.9
*/
mpd_directory_get_last_modified :: (directory: *mpd_directory) -> time_t #foreign libmpdclient;

/**
* Begins parsing a new directory.
*
* @param pair the first pair in this directory (name must be "directory")
* @return the new #mpd_entity object, or NULL on error (out of
* memory, or pair name is not "directory")
*/
mpd_directory_begin :: (pair: *mpd_pair) -> *mpd_directory #foreign libmpdclient;

/**
* Parses the pair, adding its information to the specified
* #mpd_directory object.
*
* @return true if the pair was parsed and added to the directory (or if
* the pair was not understood and ignored), false if this pair is the
* beginning of the next directory
*/
mpd_directory_feed :: (directory: *mpd_directory, pair: *mpd_pair) -> bool #foreign libmpdclient;

/**
* Receives the next directory from the MPD server.
*
* @return a #mpd_directory object, or NULL on error or if the directory list is
* finished
*/
mpd_recv_directory :: (connection: *mpd_connection) -> *mpd_directory #foreign libmpdclient;

/**
* \struct mpd_song
*
* An opaque representation for a song in MPD's database or playlist.
* Use the functions provided by this header to access the object's
* attributes.
*/
mpd_song :: struct {}

/**
* Free memory allocated by the #mpd_song object.
*/
mpd_song_free :: (song: *mpd_song) -> void #foreign libmpdclient;

/**
* Duplicates the specified #mpd_song object.
*
* @returns the copy, or NULL if out of memory
*/
mpd_song_dup :: (song: *mpd_song) -> *mpd_song #foreign libmpdclient;

/**
* Returns the URI of the song.  This is either a path relative to the
* MPD music directory (without leading slash), or an URL with a
* scheme, e.g. a HTTP URL for a radio stream.
*/
mpd_song_get_uri :: (song: *mpd_song) -> *u8 #foreign libmpdclient;

/**
* Queries a tag value.
*
* @param song the song object
* @param type the tag type
* @param idx pass 0 to get the first value for this tag type.  This
* argument may be used to iterate all values, until this function
* returns NULL
* @return the tag value, or NULL if this tag type (or this index)
* does not exist
*/
mpd_song_get_tag :: (song: *mpd_song, type: mpd_tag_type, idx: u32) -> *u8 #foreign libmpdclient;

/**
* Returns the duration of this song in seconds.  0 means the duration
* is unknown.
*/
mpd_song_get_duration :: (song: *mpd_song) -> u32 #foreign libmpdclient;

/**
* Returns the duration of this song in milliseconds.  0 means the
* duration is unknown.
*
* @since libmpdclient 2.10
*/
mpd_song_get_duration_ms :: (song: *mpd_song) -> u32 #foreign libmpdclient;

/**
* Returns the start of the virtual song within the physical file in
* seconds.
*
* @since libmpdclient 2.3
*/
mpd_song_get_start :: (song: *mpd_song) -> u32 #foreign libmpdclient;

/**
* Returns the end of the virtual song within the physical file in
* seconds. 0 means that the physical song file is played to the end.
*
* @since libmpdclient 2.3
*/
mpd_song_get_end :: (song: *mpd_song) -> u32 #foreign libmpdclient;

/**
* @return the POSIX UTC time stamp of the last modification, or 0 if
* that is unknown
*/
mpd_song_get_last_modified :: (song: *mpd_song) -> time_t #foreign libmpdclient;

/**
* Sets the position within the queue.  This value is not used for
* songs which are not in the queue.
*
* This function is useful when applying the values returned by
* mpd_recv_queue_change_brief().
*/
mpd_song_set_pos :: (song: *mpd_song, pos: u32) -> void #foreign libmpdclient;

/**
* Returns the position of this song in the queue.  The value is
* undefined if you did not obtain this song from the queue.
*/
mpd_song_get_pos :: (song: *mpd_song) -> u32 #foreign libmpdclient;

/**
* Returns the id of this song in the playlist.  The value is
* undefined if you did not obtain this song from the queue.
*/
mpd_song_get_id :: (song: *mpd_song) -> u32 #foreign libmpdclient;

/**
* Returns the priority of this song in the playlist.  The value is
* undefined if you did not obtain this song from the queue.
*
* @since libmpdclient 2.8
*/
mpd_song_get_prio :: (song: *mpd_song) -> u32 #foreign libmpdclient;

/**
* Returns audio format as determined by MPD's decoder plugin.  May
* return NULL if the format is not available or unknown.
*
* @since libmpdclient 2.15
*/
mpd_song_get_audio_format :: (song: *mpd_song) -> *mpd_audio_format #foreign libmpdclient;

/**
* Begins parsing a new song.
*
* @param pair the first pair in this song (name must be "file")
* @return the new #mpd_entity object, or NULL on error (out of
* memory, or pair name is not "file")
*/
mpd_song_begin :: (pair: *mpd_pair) -> *mpd_song #foreign libmpdclient;

/**
* Parses the pair, adding its information to the specified
* #mpd_song object.
*
* @return true if the pair was parsed and added to the song (or if
* the pair was not understood and ignored), false if this pair is the
* beginning of the next song
*/
mpd_song_feed :: (song: *mpd_song, pair: *mpd_pair) -> bool #foreign libmpdclient;

/**
* Receives the next song from the MPD server.
*
* @return a #mpd_song object, or NULL on error or if the song list is
* finished
*/
mpd_recv_song :: (connection: *mpd_connection) -> *mpd_song #foreign libmpdclient;

/**
* The type of a #mpd_entity object.
*/
mpd_entity_type :: enum u32 {
    UNKNOWN   :: 0;
    DIRECTORY :: 1;
    SONG      :: 2;
    PLAYLIST  :: 3;
}

/**
* \struct mpd_entity
*
* An "entity" is an object returned by commands like "lsinfo".  It is
* an object wrapping all possible entity types.
*/
mpd_entity :: struct {}

/**
* Releases an entity.  This also frees the wrapped object.
*/
mpd_entity_free :: (entity: *mpd_entity) -> void #foreign libmpdclient;

/**
* @return the type of this entity.
*/
mpd_entity_get_type :: (entity: *mpd_entity) -> mpd_entity_type #foreign libmpdclient;

/**
* Obtains a pointer to the #mpd_directory object enclosed by this
* #mpd_entity.  Calling this function is only allowed if
* mpd_entity_get_type() has returned #MPD_ENTITY_TYPE_DIRECTORY.
*
* @return the directory object
*/
mpd_entity_get_directory :: (entity: *mpd_entity) -> *mpd_directory #foreign libmpdclient;

/**
* Obtains a pointer to the #mpd_song object enclosed by this
* #mpd_entity.  Calling this function is only allowed if
* mpd_entity_get_type() has returned #MPD_ENTITY_TYPE_SONG.
*
* @return the song object
*/
mpd_entity_get_song :: (entity: *mpd_entity) -> *mpd_song #foreign libmpdclient;

/**
* \struct mpd_playlist
*
* An opaque representation for a playlist stored in MPD's
* playlist directory.  Use the functions provided by this header to
* access the object's attributes.
*/
mpd_playlist :: struct {}
/**
* Obtains a pointer to the #mpd_playlist object enclosed by
* this #mpd_entity.  Calling this function is only allowed if
* mpd_entity_get_type() has returned #MPD_ENTITY_TYPE_PLAYLIST.
*
* @return the playlist object
*/
mpd_entity_get_playlist :: (entity: *mpd_entity) -> *mpd_playlist #foreign libmpdclient;

/**
* Begins parsing a new entity.
*
* @param pair the first pair in this entity
* @return the new #mpd_entity object, or NULL on error (out of memory)
*/
mpd_entity_begin :: (pair: *mpd_pair) -> *mpd_entity #foreign libmpdclient;

/**
* Parses the pair, adding its information to the specified
* #mpd_entity object.
*
* @return true if the pair was parsed and added to the entity (or if
* the pair was not understood and ignored), false if this pair is the
* beginning of the next entity
*/
mpd_entity_feed :: (entity: *mpd_entity, pair: *mpd_pair) -> bool #foreign libmpdclient;

/**
* Receives the next entity from the MPD server.
*
* @return an entity object, or NULL on error or if the entity list is
* finished
*/
mpd_recv_entity :: (connection: *mpd_connection) -> *mpd_entity #foreign libmpdclient;

mpd_fingerprint_type :: enum u32 {
    UNKNOWN     :: 0;
    CHROMAPRINT :: 1;
}

/**
* Parse a #mpd_pair name to check which fingerprint type it contains.
*/
mpd_parse_fingerprint_type :: (name: *u8) -> mpd_fingerprint_type #foreign libmpdclient;

/**
* Sends the "getfingerprint" command to MPD.  Call mpd_recv_pair() to
* read response lines.  Use mpd_parse_fingerprint_type() to check
* each pair's name; the pair's value then contains the actual
* fingerprint.
*
* @param connection a valid and connected #mpd_connection
* @param uri the song URI
* @return true on success
*
* @since libmpdclient 2.17, MPD 0.22
*/
mpd_send_getfingerprint :: (connection: *mpd_connection, uri: *u8) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_getfingerprint(), mpd_recv_pair_named() and
* mpd_response_finish().
*
* @param connection a valid and connected #mpd_connection
* @param uri the song URI
* @param buffer a buffer for the fingerprint string
* @param buffer_size the size of the buffer (with enough room for a
* trailing null byte); if the buffer is too small, behavior is
* undefined; the library may truncate the string or fail
* @return a pointer to the buffer on success or NULL on error (or if
* there was no chromaprint in MPD's response)
*
* @since libmpdclient 2.17, MPD 0.22
*/
mpd_run_getfingerprint_chromaprint :: (connection: *mpd_connection, uri: *u8, buffer: *u8, buffer_size: size_t) -> *u8 #foreign libmpdclient;

/**
* This enum contains bit masks for all idle events.
*
* @since libmpdclient 2.5 added support for #MPD_IDLE_STICKER,
* #MPD_IDLE_SUBSCRIPTION and #MPD_IDLE_MESSAGE.
* @since libmpdclient 2.17 added support for #MPD_IDLE_PARTITION.
* @since libmpdclient 2.19 added support for #MPD_IDLE_NEIGHBOR,
* #MPD_IDLE_MOUNT
*/
mpd_idle :: enum u32 {
    DATABASE        :: 1;
    STORED_PLAYLIST :: 2;
    QUEUE           :: 4;
    PLAYLIST        :: 4;
    PLAYER          :: 8;
    MIXER           :: 16;
    OUTPUT          :: 32;
    OPTIONS         :: 64;
    UPDATE          :: 128;
    STICKER         :: 256;
    SUBSCRIPTION    :: 512;
    MESSAGE         :: 1024;
    PARTITION       :: 2048;
    NEIGHBOR        :: 4096;
    MOUNT           :: 8192;
}

/**
* Returns the name of the specified idle event.
*
* @param idle an idle event id
* @return the name, or NULL if that event is not known
*/
mpd_idle_name :: (idle: mpd_idle) -> *u8 #foreign libmpdclient;

/**
* Parses the name of an idle event.
*
* @param name an idle event name
* @return the id, or 0 if that event is not known
*/
mpd_idle_name_parse :: (name: *u8) -> mpd_idle #foreign libmpdclient;

/**
* Enters "idle" mode: MPD will stall the response until an event has
* occurred.  Call mpd_send_noidle() to abort the idle mode, or
* mpd_recv_idle() to read the event mask (or synchronously wait for
* events).
*
* @param connection the connection to MPD
* @return true on success
*/
mpd_send_idle :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Same as mpd_send_idle(), but listen only on specific events.
*
* @param connection the connection to MPD
* @param mask a bit mask of idle events; must not be 0
* @return true on success
*/
mpd_send_idle_mask :: (connection: *mpd_connection, mask: mpd_idle) -> bool #foreign libmpdclient;

/**
* Tells MPD to leave the "idle" mode.  MPD will then respond with a
* list of events which have occurred (which may be empty).  Call
* mpd_recv_idle() after that.
*
* @param connection the connection to MPD
* @return true on success
*/
mpd_send_noidle :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Parses a "changed" pair, which is part of MPD's response to the
* "idle" command.
*
* @param pair the "changed" pair
* @return an idle code, or 0 if the pair was not understood
*/
mpd_idle_parse_pair :: (pair: *mpd_pair) -> mpd_idle #foreign libmpdclient;

/**
* Waits until MPD sends the list of idle events and returns it in a
* bit mask.
*
* @param connection the connection to MPD
* @param disable_timeout if true, then libmpdclient temporarily
* disables the configured timeout (see mpd_connection_set_timeout()):
* this function blocks forever, until either MPD sends a response, or
* an error occurs.
* @return the event bit mask, or 0 on error or if there were no
* events
*/
mpd_recv_idle :: (connection: *mpd_connection, disable_timeout: bool) -> mpd_idle #foreign libmpdclient;

/**
* Shortcut for mpd_send_idle() and mpd_recv_idle().  During
* mpd_recv_idle(), the configured timeout is disabled.
*
* @param connection the connection to MPD
* @return the event bit mask, or 0 on error
*/
mpd_run_idle :: (connection: *mpd_connection) -> mpd_idle #foreign libmpdclient;

/**
* Shortcut for mpd_send_idle_mask() and mpd_recv_idle().  During
* mpd_recv_idle(), the configured timeout is disabled.
*
* @param connection the connection to MPD
* @param mask a bit mask of idle events; must not be 0
* @return the event bit mask, or 0 on error
*/
mpd_run_idle_mask :: (connection: *mpd_connection, mask: mpd_idle) -> mpd_idle #foreign libmpdclient;

/**
* Shortcut for mpd_send_noidle() and mpd_recv_idle().  During
* mpd_recv_idle(), the configured timeout is not disabled.
*
* @param connection the connection to MPD
* @return the event bit mask, or 0 on error or if there were no
* events
*/
mpd_run_noidle :: (connection: *mpd_connection) -> mpd_idle #foreign libmpdclient;

/**
* Starts a command list, i.e. a group of pipelined commands which are
* transferred in one block.  If one command fails, the rest of the
* command list is canceled.
*
* Note that there is no guarantee on atomicity.
*
* @param connection the connection to MPD
* @param discrete_ok tells MPD whether to acknowledge every list
* command with an "list_OK" response
* @return true on success
*/
mpd_command_list_begin :: (connection: *mpd_connection, discrete_ok: bool) -> bool #foreign libmpdclient;

/**
* Commits the command list, i.e. makes MPD execute all commands which
* were queued.
*
* Note: there is no way to cancel a command list once it is started.
* You may however close the socket connection.
*
* @param connection the connection to MPD
* @return true on success
*/
mpd_command_list_end :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* \struct mpd_message
*/
mpd_message :: struct {}

/**
* Begins parsing a new message.
*
* @param pair the first pair in this message (name must be "channel")
* @return the new #mpd_entity object, or NULL on error (out of
* memory, or pair name is not "channel")
*
* @since libmpdclient 2.5
*/
mpd_message_begin :: (pair: *mpd_pair) -> *mpd_message #foreign libmpdclient;

/**
* Parses the pair, adding its information to the specified
* #mpd_message object.
*
* @return true if the pair was parsed and added to the message (or if
* the pair was not understood and ignored), false if this pair is the
* beginning of the next message
*
* @since libmpdclient 2.5
*/
mpd_message_feed :: (output: *mpd_message, pair: *mpd_pair) -> bool #foreign libmpdclient;

/**
* Frees a #mpd_message object.
*
* @since libmpdclient 2.5
*/
mpd_message_free :: (message: *mpd_message) -> void #foreign libmpdclient;

/**
* Returns the channel name.
*
* @since libmpdclient 2.5
*/
mpd_message_get_channel :: (message: *mpd_message) -> *u8 #foreign libmpdclient;

/**
* Returns the message text.
*
* @since libmpdclient 2.5
*/
mpd_message_get_text :: (message: *mpd_message) -> *u8 #foreign libmpdclient;

/**
* Sends the "subscribe" command: subscribe to a message channel.
*
* @param connection the connection to MPD
* @param channel the channel name
* @return true on success
*
* @since libmpdclient 2.5
*/
mpd_send_subscribe :: (connection: *mpd_connection, channel: *u8) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_subscribe() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param channel the channel name
* @return true on success
*
* @since libmpdclient 2.5
*/
mpd_run_subscribe :: (connection: *mpd_connection, channel: *u8) -> bool #foreign libmpdclient;

/**
* Sends the "unsubscribe" command: unsubscribe from a message
* channel.
*
* @param connection the connection to MPD
* @param channel the channel name
* @return true on success
*
* @since libmpdclient 2.5
*/
mpd_send_unsubscribe :: (connection: *mpd_connection, channel: *u8) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_unsubscribe() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param channel the channel name
* @return true on success
*
* @since libmpdclient 2.5
*/
mpd_run_unsubscribe :: (connection: *mpd_connection, channel: *u8) -> bool #foreign libmpdclient;

/**
* Sends the "sendmessage" command: send a message to a channel.
*
* @param connection the connection to MPD
* @param channel the channel name
* @param text the message text
* @return true on success
*
* @since libmpdclient 2.5
*/
mpd_send_send_message :: (connection: *mpd_connection, channel: *u8, text: *u8) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_send_message() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param channel the channel name
* @param text the message text
* @return true on success
*
* @since libmpdclient 2.5
*/
mpd_run_send_message :: (connection: *mpd_connection, channel: *u8, text: *u8) -> bool #foreign libmpdclient;

/**
* Sends the "readmessages" command: send a message to a channel.
*
* @param connection the connection to MPD
* @return true on success
*
* @since libmpdclient 2.5
*/
mpd_send_read_messages :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Reads the next mpd_message from the MPD response.  Free the return
* value with mpd_message_free().
*
* @return a mpd_message object on success, NULL on error or
* end-of-response
*
* @since libmpdclient 2.5
*/
mpd_recv_message :: (connection: *mpd_connection) -> *mpd_message #foreign libmpdclient;

/**
* Sends the "channels" command: get a list of all channels.
*
* @param connection the connection to MPD
* @return true on success
*
* @since libmpdclient 2.5
*/
mpd_send_channels :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Sets the volume of all output devices.
*
* @param connection the connection to MPD
* @param volume the volume, an integer between 0 and 100
* @return true on success, false on error
*/
mpd_send_set_volume :: (connection: *mpd_connection, volume: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_set_volume() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param volume the volume, an integer between 0 and 100
* @return true on success, false on error
*/
mpd_run_set_volume :: (connection: *mpd_connection, volume: u32) -> bool #foreign libmpdclient;

/**
* Changes the volume of all output devices.
*
* @param connection the connection to MPD
* @param relative_volume the relative volume, an integer between -100 and 100
* @return true on success, false on error
*
* @since libmpdclient 2.9
*/
mpd_send_change_volume :: (connection: *mpd_connection, relative_volume: s32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_change_volume() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param relative_volume the relative volume, an integer between -100 and 100
* @return true on success, false on error
*
* @since libmpdclient 2.9
*/
mpd_run_change_volume :: (connection: *mpd_connection, relative_volume: s32) -> bool #foreign libmpdclient;

/**
* Sends the "getvol" command to MPD.  Call mpd_recv_pair() to
* read the response line.
*
* @param connection a valid and connected #mpd_connection
* @return true on success
*
* @since libmpdclient 2.20, MPD 0.23
*/
mpd_send_get_volume :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_get_volume(), mpd_recv_pair_named() and
* mpd_response_finish().
*
* @param connection a valid and connected #mpd_connection
* @return volume on success or -1 on error
*
* @since libmpdclient 2.20, MPD 0.23
*/
mpd_run_get_volume :: (connection: *mpd_connection) -> s32 #foreign libmpdclient;

/**
* \struct mpd_mount
*
* This type represents a mount point on the MPD server.
*/
mpd_mount :: struct {}

/**
* Begins parsing a new #mpd_mount.
*
* @param pair the first pair in this mount point
* @return the new #mpd_mount object, or NULL on error (out of
* memory, or wrong pair name)
*
* @since libmpdclient 2.16
*/
mpd_mount_begin :: (pair: *mpd_pair) -> *mpd_mount #foreign libmpdclient;

/**
* Parses the pair, adding its information to the specified
* #mpd_mount object.
*
* @return true if the pair was parsed and added to the mount (or if
* the pair was not understood and ignored), false if this pair is the
* beginning of the next mount
*
* @since libmpdclient 2.16
*/
mpd_mount_feed :: (mnt: *mpd_mount, pair: *mpd_pair) -> bool #foreign libmpdclient;

/**
* Frees a mpd_mount object returned from mpd_recv_mount() or mpd_mount_begin().
*
* @since libmpdclient 2.16
*/
mpd_mount_free :: (mount: *mpd_mount) -> void #foreign libmpdclient;

/**
* @return the mount point URI of the specified #mpd_mount object
*
* @since libmpdclient 2.16
*/
mpd_mount_get_uri :: (mnt: *mpd_mount) -> *u8 #foreign libmpdclient;

/**
* @return the mounted storage URI of the specified #mpd_mount object;
* may be NULL if MPD did not reveal it
*
* @since libmpdclient 2.16
*/
mpd_mount_get_storage :: (mnt: *mpd_mount) -> *u8 #foreign libmpdclient;

/**
* Sends the "listmounts" command to MPD.  Call mpd_recv_mount() to
* read the response.
*
* @param connection a valid and connected mpd_connection.
* @return true on success
*
* @since libmpdclient 2.16, MPD 0.19
*/
mpd_send_list_mounts :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Reads the next mpd_mount from the MPD response.  Free the return
* value with mpd_mount_free().
*
* @return a mpd_mount object on success, NULL on error or
* end-of-response
*
* @since libmpdclient 2.16, MPD 0.19
*/
mpd_recv_mount :: (connection: *mpd_connection) -> *mpd_mount #foreign libmpdclient;

/**
* Sends the "mount" command to MPD.
*
* @param connection a valid and connected mpd_connection.
* @param uri the mount point URI
* @param storage the mounted storage URI
* @return true on success
*
* @since libmpdclient 2.16, MPD 0.19
*/
mpd_send_mount :: (connection: *mpd_connection, uri: *u8, storage: *u8) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_mount() and mpd_response_finish().
*
* @param connection A valid and connected mpd_connection.
* @param uri the mount point URI
* @param storage the mounted storage URI
* @return true on success
*
* @since libmpdclient 2.16, MPD 0.19
*/
mpd_run_mount :: (connection: *mpd_connection, uri: *u8, storage: *u8) -> bool #foreign libmpdclient;

/**
* Sends the "unmount" command to MPD.
*
* @param connection a valid and connected mpd_connection.
* @param uri the mount point URI
* @return true on success
*
* @since libmpdclient 2.16, MPD 0.19
*/
mpd_send_unmount :: (connection: *mpd_connection, uri: *u8) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_unmount() and mpd_response_finish().
*
* @param connection A valid and connected mpd_connection.
* @param uri the mount point URI
* @return true on success
*
* @since libmpdclient 2.16, MPD 0.19
*/
mpd_run_unmount :: (connection: *mpd_connection, uri: *u8) -> bool #foreign libmpdclient;

/**
* \struct mpd_neighbor
*
* This type represents a neighbor (accessible file servers on the local net)
* on the MPD server.
*/
mpd_neighbor :: struct {}

/**
* Begins parsing a new #mpd_neighbor.
*
* @param pair the first pair in this mount point
* @return the new #mpd_neighbor object, or NULL on error (out of
* memory, or wrong pair name)
*
* @since libmpdclient 2.17
*/
mpd_neighbor_begin :: (pair: *mpd_pair) -> *mpd_neighbor #foreign libmpdclient;

/**
* Parses the pair, adding its information to the specified
* #mpd_neighbor object.
*
* @return true if the pair was parsed and added to the mpd_neighbor (or if
* the pair was not understood and ignored), false if this pair is the
* beginning of the next neighbor
*
* @since libmpdclient 2.17
*/
mpd_neighbor_feed :: (neighbor: *mpd_neighbor, pair: *mpd_pair) -> bool #foreign libmpdclient;

/**
* Frees a #mpd_neighbor object returned from mpd_recv_neighbor() or 
* mpd_neighbor_begin().
*
* @since libmpdclient 2.17
*/
mpd_neighbor_free :: (neighbor: *mpd_neighbor) -> void #foreign libmpdclient;

/**
* @return the neighbor mount point URI of the specified #mpd_neighbor object
*
* @since libmpdclient 2.17
*/
mpd_neighbor_get_uri :: (neighbor: *mpd_neighbor) -> *u8 #foreign libmpdclient;

/**
* @return the display name of the specified #mpd_neighbor object;
*
* @since libmpdclient 2.17
*/
mpd_neighbor_get_display_name :: (neighbor: *mpd_neighbor) -> *u8 #foreign libmpdclient;

/**
* Sends the "listneighbors" command to MPD: queries a list of "neighbors"
* (e.g. accessible file servers on the local net). Call mpd_recv_neighbor() to
* read the response.
*
* @param connection a valid and connected mpd_connection.
* @return true on success
*
* @since libmpdclient 2.17, MPD 0.19
*/
mpd_send_list_neighbors :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Reads the next mpd_neighbor from the MPD response.  Free the return
* value with mpd_neighbor_free().
*
* @return a mpd_neighbor object on success, NULL on error or
* end-of-response
*
* @since libmpdclient 2.17, MPD 0.19
*/
mpd_recv_neighbor :: (connection: *mpd_connection) -> *mpd_neighbor #foreign libmpdclient;

/**
* \struct mpd_output
*
* This type represents an audio output device on the MPD server.
*/
mpd_output :: struct {}

/**
* Begins parsing a new #mpd_output.
*
* @param pair the first pair in this output (name is "outputid")
* @return the new #mpd_output object, or NULL on error (out of
* memory, or wrong pair name)
*/
mpd_output_begin :: (pair: *mpd_pair) -> *mpd_output #foreign libmpdclient;

/**
* Parses the pair, adding its information to the specified
* #mpd_output object.
*
* @return true if the pair was parsed and added to the output (or if
* the pair was not understood and ignored), false if this pair is the
* beginning of the next output
*/
mpd_output_feed :: (output: *mpd_output, pair: *mpd_pair) -> bool #foreign libmpdclient;

/**
* Frees a mpd_output object returned from mpd_recv_output() or
* mpd_output_begin().
*/
mpd_output_free :: (output: *mpd_output) -> void #foreign libmpdclient;

/**
* @return the id of the specified #mpd_output object
*/
mpd_output_get_id :: (output: *mpd_output) -> u32 #foreign libmpdclient;

/**
* @return the configured name of the specified #mpd_output object
*/
mpd_output_get_name :: (output: *mpd_output) -> *u8 #foreign libmpdclient;

/**
* @return the plugin of the specified #mpd_output object, or NULL if
* none was specified by the server
*
* @since libmpdclient 2.14, MPD 0.21
*/
mpd_output_get_plugin :: (output: *mpd_output) -> *u8 #foreign libmpdclient;

/**
* @return true if this output is enabled
*/
mpd_output_get_enabled :: (output: *mpd_output) -> bool #foreign libmpdclient;

/**
* Find an attribute with the given name and return its value.
*
* @return the attribute value or NULL if there is no such attributes
*
* @since libmpdclient 2.16, MPD 0.21
*/
mpd_output_get_attribute :: (output: *mpd_output, name: *u8) -> *u8 #foreign libmpdclient;

/**
* Obtains the first attribute for this output.  This rewinds the
* current attribute pointer to the start.  Call
* mpd_output_next_attribute() to obtain more attributes.
*
* @return a pointer to the first attribute or NULL if there are no
* attributes
*
* @since libmpdclient 2.14, MPD 0.21
*/
mpd_output_first_attribute :: (output: *mpd_output) -> *mpd_pair #foreign libmpdclient;

/**
* Obtains the next attribute for this output.  Call this function
* repeatedly until it returns NULL to get a full list of attributes.
*
* @return a pointer to the next attribute or NULL if there are no
* more attributes
*
* @since libmpdclient 2.14, MPD 0.21
*/
mpd_output_next_attribute :: (output: *mpd_output) -> *mpd_pair #foreign libmpdclient;

/**
* Sends the "outputs" command to MPD: fetch information about all outputs.
* Call mpd_recv_output() to read the response.
*
* @param connection A valid and connected mpd_connection.
* @return true on success
*/
mpd_send_outputs :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Reads the next mpd_output from the MPD response.  Free the return
* value with mpd_output_free().
*
* @return a mpd_output object on success, NULL on error or
* end-of-response
*/
mpd_recv_output :: (connection: *mpd_connection) -> *mpd_output #foreign libmpdclient;

/**
* Sends the "enableoutput" command to MPD.
*
* @param connection A valid and connected mpd_connection.
* @param output_id an identifier for the output device (see
* mpd_recv_output())
* @return true on success
*/
mpd_send_enable_output :: (connection: *mpd_connection, output_id: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_enable_output() and mpd_response_finish().
*
* @param connection A valid and connected mpd_connection.
* @param output_id an identifier for the output device (see
* mpd_recv_output())
* @return true on success
*/
mpd_run_enable_output :: (connection: *mpd_connection, output_id: u32) -> bool #foreign libmpdclient;

/**
* Sends the "disableoutput" command to MPD.
*
* @param connection A valid and connected mpd_connection.
* @param output_id an identifier for the output device (see
* mpd_recv_output())
* @return true on success
*/
mpd_send_disable_output :: (connection: *mpd_connection, output_id: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_disable_output() and mpd_response_finish().
*
* @param connection A valid and connected mpd_connection.
* @param output_id an identifier for the output device (see
* mpd_recv_output())
* @return true on success
*/
mpd_run_disable_output :: (connection: *mpd_connection, output_id: u32) -> bool #foreign libmpdclient;

/**
* Sends the "toggleoutput" command to MPD.
*
* @param connection a valid and connected mpd_connection.
* @param output_id an identifier for the output device (see
* mpd_recv_output())
* @return true on success
*
* @since libmpdclient 2.9
*/
mpd_send_toggle_output :: (connection: *mpd_connection, output_id: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_toggle_output() and mpd_response_finish().
*
* @param connection a valid and connected mpd_connection.
* @param output_id an identifier for the output device (see
* mpd_recv_output())
* @return true on success
*
* @since libmpdclient 2.9
*/
mpd_run_toggle_output :: (connection: *mpd_connection, output_id: u32) -> bool #foreign libmpdclient;

/**
* Sends the "outputset" command to MPD: set a runtime attribute for the
* specified output_id.
*
* @param connection a valid and connected mpd_connection
* @param output_id an identifier for the output device (see
* mpd_recv_output())
* @param attribute_name the attribute name
* @param attribute_value the attribute value
* @return true on success
*
* @since libmpdclient 2.14, MPD 0.21
*/
mpd_send_output_set :: (connection: *mpd_connection, output_id: u32, attribute_name: *u8, attribute_value: *u8) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_output_set() and mpd_response_finish().
*
* @since libmpdclient 2.14, MPD 0.21
*/
mpd_run_output_set :: (connection: *mpd_connection, output_id: u32, attribute_name: *u8, attribute_value: *u8) -> bool #foreign libmpdclient;

/**
* Move an output to the current partition.
*
* @param connection the connection to MPD
* @param output_name the name of the output to be moved
* @return true on success
*
* @since libmpdclient 2.18, MPD 0.22.
*/
mpd_send_move_output :: (connection: *mpd_connection, output_name: *u8) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_move_output() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param output_name the name of the output to be moved
* @return true on success
*
* @since libmpdclient 2.18, MPD 0.22.
*/
mpd_run_move_output :: (connection: *mpd_connection, output_name: *u8) -> bool #foreign libmpdclient;

/**
* A name-value pair received from the MPD server.
*/
mpd_pair :: struct {
    /** the name of the element */
    name:  *u8;
    /** the value of the element */
    value: *u8;
}

/**
* \struct mpd_partition
*/
mpd_partition :: struct {}

/**
* Creates a new partition object from the pair received from MPD server.
*
* @param pair a #mpd_pair received from MPD (name must be "partition")
* @return the new #mpd_partition object, or NULL on error (out of
* memory, or pair name is not "partition")
*
* @since libmpdclient 2.17
*/
mpd_partition_new :: (pair: *mpd_pair) -> *mpd_partition #foreign libmpdclient;

/**
* Frees a #mpd_partition object.
*
* @since libmpdclient 2.17
*/
mpd_partition_free :: (partition: *mpd_partition) -> void #foreign libmpdclient;

/**
* Returns the partition name.
*
* @since libmpdclient 2.17
*/
mpd_partition_get_name :: (partition: *mpd_partition) -> *u8 #foreign libmpdclient;

/**
* Creates a new partition.
* A partition is one frontend of a multi-player MPD process: it has separate
* queue, player and outputs. A client is assigned to one partition at a time.
*
* @param connection the connection to MPD
* @param partition the partition name
* @return true on success
*
* @since libmpdclient 2.17
*/
mpd_send_newpartition :: (connection: *mpd_connection, partition: *u8) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_newpartition() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param partition the partition name
* @return true on success
*
* @since libmpdclient 2.17
*/
mpd_run_newpartition :: (connection: *mpd_connection, partition: *u8) -> bool #foreign libmpdclient;

/**
* Delete a partition.
*
* @param connection the connection to MPD
* @param partition the partition name
* @return true on success
*
* @since libmpdclient 2.18, MPD 0.22
*/
mpd_send_delete_partition :: (connection: *mpd_connection, partition: *u8) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_delete_partition() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param partition the partition name
* @return true on success
*
* @since libmpdclient 2.18, MPD 0.22
*/
mpd_run_delete_partition :: (connection: *mpd_connection, partition: *u8) -> bool #foreign libmpdclient;

/**
* Switch the client to a different partition.
*
* @param connection the connection to MPD
* @param partition the partition name
* @return true on success
*
* @since libmpdclient 2.17
*/
mpd_send_switch_partition :: (connection: *mpd_connection, partition: *u8) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_switch_partition() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param partition the partition name
* @return true on success
*
* @since libmpdclient 2.17
*/
mpd_run_switch_partition :: (connection: *mpd_connection, partition: *u8) -> bool #foreign libmpdclient;

/**
* Sends the "listpartitions" command: request the list of partitions.
* Call mpd_recv_partition() repeatedly to read the response.
*
* @param connection the connection to MPD
* @return true on success
*
* @since libmpdclient 2.17
*/
mpd_send_listpartitions :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Reads the next #mpd_partition from the MPD response.  Free the
* return value with mpd_partition_free().
*
* @return a mpd_partition object on success, NULL on error or
* end-of-response
*
* @since libmpdclient 2.18
*/
mpd_recv_partition :: (connection: *mpd_connection) -> *mpd_partition #foreign libmpdclient;

/**
* Sends the password to MPD, to gain more privileges.
*/
mpd_send_password :: (connection: *mpd_connection, password: *u8) -> bool #foreign libmpdclient;

/**
* Sends the password to MPD and receives its response.
*
* @return true on success, false on failure
*/
mpd_run_password :: (connection: *mpd_connection, password: *u8) -> bool #foreign libmpdclient;

/**
* MPD's playback state.
*/
mpd_state :: enum u32 {
    UNKNOWN :: 0;
    STOP    :: 1;
    PLAY    :: 2;
    PAUSE   :: 3;
}

/**
* MPD's single state.
*
* @since libmpdclient 2.18, MPD 0.21.
*/
mpd_single_state :: enum u32 {
    OFF     :: 0;
    ON      :: 1;
    ONESHOT :: 2;
    UNKNOWN :: 3;
}

/**
* \struct mpd_status
*
* Holds information about MPD's status.
*/
mpd_status :: struct {}

/**
* Begins parsing the server status: creates a new empty #mpd_status
* object.  Free it with mpd_status_free().
*
* @return the newly allocated #mpd_status object, or NULL if out of
* memory
*/
mpd_status_begin :: () -> *mpd_status #foreign libmpdclient;

/**
* Parses the pair, adding its information to the specified
* #mpd_status object.
*/
mpd_status_feed :: (status: *mpd_status, pair: *mpd_pair) -> void #foreign libmpdclient;

/**
* Sends the "status" command to MPD.  Call mpd_recv_status() to read
* the response.
*
* @return true on success
*/
mpd_send_status :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Receives a #mpd_status object from the server.
*
* @return the received #mpd_status object, or NULL on error
*/
mpd_recv_status :: (connection: *mpd_connection) -> *mpd_status #foreign libmpdclient;

/**
* Executes the "status" command and reads the response.
*
* @return the #mpd_status object returned by the server, or NULL on
* error
*/
mpd_run_status :: (connection: *mpd_connection) -> *mpd_status #foreign libmpdclient;

/**
* Releases a #mpd_status object.
*/
mpd_status_free :: (status: *mpd_status) -> void #foreign libmpdclient;

/**
* Returns the current volume: 0-100, or -1 when there is no volume
* support.
*/
mpd_status_get_volume :: (status: *mpd_status) -> s32 #foreign libmpdclient;

/**
* Returns true if repeat mode is on.
*/
mpd_status_get_repeat :: (status: *mpd_status) -> bool #foreign libmpdclient;

/**
* Returns true if random mode is on.
*/
mpd_status_get_random :: (status: *mpd_status) -> bool #foreign libmpdclient;

/**
* Returns the current state of single mode on MPD.
*
* If the state is #MPD_SINGLE_ONESHOT, MPD will transition to #MPD_SINGLE_OFF
* after a song is played and if there is another song in the queue. The
* #mpd_status object will not be updated accordingly. In this case, you need
* to call mpd_send_status() and mpd_recv_status() again.
*
* @since MPD 0.21, libmpdclient 2.18.
*/
mpd_status_get_single_state :: (status: *mpd_status) -> mpd_single_state #foreign libmpdclient;

/**
* This function is deprecated as it does not distinguish the states of
* the single mode (added to MPD 0.21). Call mpd_status_get_single_state() in
* its place.
*
* Returns true if single mode is either on or in oneshot.
*/
mpd_status_get_single :: (status: *mpd_status) -> bool #foreign libmpdclient;

/**
* Returns true if consume mode is on.
*/
mpd_status_get_consume :: (status: *mpd_status) -> bool #foreign libmpdclient;

/**
* Returns the number of songs in the queue.  If MPD did not
* specify that, this function returns 0.
*/
mpd_status_get_queue_length :: (status: *mpd_status) -> u32 #foreign libmpdclient;

/**
* Returns queue version number.  You may use this to determine
* when the queue has changed since you have last queried it.
*/
mpd_status_get_queue_version :: (status: *mpd_status) -> u32 #foreign libmpdclient;

/**
* Returns the state of the player: either stopped, playing or paused.
*/
mpd_status_get_state :: (status: *mpd_status) -> mpd_state #foreign libmpdclient;

/**
* Returns crossfade setting in seconds.  0 means crossfading is
* disabled.
*/
mpd_status_get_crossfade :: (status: *mpd_status) -> u32 #foreign libmpdclient;

/**
* Returns mixrampdb setting in db. 0 means mixrampdb is disabled.
*
* @since libmpdclient 2.2
*/
mpd_status_get_mixrampdb :: (status: *mpd_status) -> float #foreign libmpdclient;

/**
* Returns mixrampdelay setting in seconds.  Negative means mixrampdelay is
* disabled.
*
* @since libmpdclient 2.2
*/
mpd_status_get_mixrampdelay :: (status: *mpd_status) -> float #foreign libmpdclient;

/**
* Returns the position of the currently playing song in the queue
* (beginning with 0) if a song is currently selected (always the case when
* state is MPD_STATE_PLAY or MPD_STATE_PAUSE).  If there is no current song,
* -1 is returned.
*/
mpd_status_get_song_pos :: (status: *mpd_status) -> s32 #foreign libmpdclient;

/**
* Returns the id of the current song.  If there is no current song,
* -1 is returned.
*/
mpd_status_get_song_id :: (status: *mpd_status) -> s32 #foreign libmpdclient;

/**
* The same as mpd_status_get_song_pos(), but for the next song to be
* played.
*
* @since libmpdclient 2.7
*/
mpd_status_get_next_song_pos :: (status: *mpd_status) -> s32 #foreign libmpdclient;

/**
* Returns the id of the next song to be played.  If it is not known, -1 is
* returned.
*
* @since libmpdclient 2.7
*/
mpd_status_get_next_song_id :: (status: *mpd_status) -> s32 #foreign libmpdclient;

/**
* This function uses a deprecated feature of MPD, call
* mpd_status_get_elapsed_ms() instead.
*
* Returns time in seconds that have elapsed in the currently playing/paused
* song.
*
*/
mpd_status_get_elapsed_time :: (status: *mpd_status) -> u32 #foreign libmpdclient;

/**
* Returns time in milliseconds that have elapsed in the currently
* playing/paused song.
*
* @since libmpdclient 2.1
*/
mpd_status_get_elapsed_ms :: (status: *mpd_status) -> u32 #foreign libmpdclient;

/**
* Returns the length in seconds of the currently playing/paused song
*/
mpd_status_get_total_time :: (status: *mpd_status) -> u32 #foreign libmpdclient;

/**
* Returns current bit rate in kbps.  0 means unknown.
*/
mpd_status_get_kbit_rate :: (status: *mpd_status) -> u32 #foreign libmpdclient;

/**
* Returns audio format which MPD is currently playing.  May return
* NULL if MPD is not playing or if the audio format is unknown.
*/
mpd_status_get_audio_format :: (status: *mpd_status) -> *mpd_audio_format #foreign libmpdclient;

/**
* Returns 1 if mpd is updating, 0 otherwise
*/
mpd_status_get_update_id :: (status: *mpd_status) -> u32 #foreign libmpdclient;

/**
* Returns the name of the current partition or NULL if the server did
* not send a name.
*/
mpd_status_get_partition :: (status: *mpd_status) -> *u8 #foreign libmpdclient;

/**
* Returns the error message
*/
mpd_status_get_error :: (status: *mpd_status) -> *u8 #foreign libmpdclient;

/**
* Fetches the currently selected song (the song referenced by
* mpd_status_get_song_id()).
* Call mpd_recv_song() to receive the response.
*
* @param connection the connection to MPD
* @return true on success, false on error
*/
mpd_send_current_song :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_current_song() and mpd_recv_song().
*
* @param connection the connection to MPD
* @return the current song, or NULL on error or if there is no
* current song
*/
mpd_run_current_song :: (connection: *mpd_connection) -> *mpd_song #foreign libmpdclient;

/**
* Starts playing the current song from the beginning.
*
* @param connection the connection to MPD
* @return true on success, false on error
*/
mpd_send_play :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_play() and mpd_response_finish().
*
* @param connection the connection to MPD
* @return true on success, false on error
*/
mpd_run_play :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Starts playing the specified song from the beginning.
*
* @param connection the connection to MPD
* @param song_pos the position of the song in the queue
* @return true on success, false on error
*/
mpd_send_play_pos :: (connection: *mpd_connection, song_pos: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_play() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param song_pos the position of the song in the queue
* @return true on success, false on error
*/
mpd_run_play_pos :: (connection: *mpd_connection, song_pos: u32) -> bool #foreign libmpdclient;

/**
* Starts playing the specified song from the beginning.
*
* @param connection the connection to MPD
* @param song_id the id of the song
* @return true on success, false on error
*/
mpd_send_play_id :: (connection: *mpd_connection, song_id: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_play_id() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param song_id the id of the song
* @return true on success, false on error
*/
mpd_run_play_id :: (connection: *mpd_connection, song_id: u32) -> bool #foreign libmpdclient;

/**
* Stops playing the current song.
*
* @param connection the connection to MPD
* @return true on success, false on error
*/
mpd_send_stop :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_stop() and mpd_response_finish().
*
* @param connection the connection to MPD
* @return true on success, false on error
*/
mpd_run_stop :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* This function uses a deprecated feature of MPD, you should avoid it.
*
* Toggles the pause mode by sending "pause" without arguments.
*
* @param connection the connection to MPD
* @return true on success, false on error
*/
mpd_send_toggle_pause :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* This function uses a deprecated feature of MPD, you should avoid it.
* Shortcut for mpd_send_toggle_pause() and mpd_response_finish().
*
* @param connection the connection to MPD
* @return true on success, false on error
*/
mpd_run_toggle_pause :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Pauses/Resumes playing the current song.
* If mode is true, MPD pauses the song; otherwise, MPD resumes the song.
*
* @param connection the connection to MPD
* @param mode if true: pause, if false: resume
* @return true on success, false on error
*/
mpd_send_pause :: (connection: *mpd_connection, mode: bool) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_pause() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param mode if true: pause, if false: resume
* @return true on success, false on error
*/
mpd_run_pause :: (connection: *mpd_connection, mode: bool) -> bool #foreign libmpdclient;

/**
* Play the next song in the playlist.
*
* @param connection the connection to MPD
* @return true on success, false on error
*/
mpd_send_next :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_next() and mpd_response_finish().
*
* @param connection the connection to MPD
* @return true on success, false on error
*/
mpd_run_next :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Play the previous song in the playlist.
*
* @param connection the connection to MPD
* @return true on success, false on error
*/
mpd_send_previous :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_previous() and mpd_response_finish().
*
* @param connection the connection to MPD
* @return true on success, false on error
*/
mpd_run_previous :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Seeks to the position t (in seconds) of position song_pos in the playlist.
*
* @param connection the connection to MPD
* @param song_pos the position of the song in the queue
* @param t the position within the song, in seconds
* @return true on success, false on error
*/
mpd_send_seek_pos :: (connection: *mpd_connection, song_pos: u32, t: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_seek_pos() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param song_pos the position of the song in the queue
* @param t the position within the song, in seconds
* @return true on success, false on error
*/
mpd_run_seek_pos :: (connection: *mpd_connection, song_pos: u32, t: u32) -> bool #foreign libmpdclient;

/**
* Seeks to the position t (in seconds) of song id song_id.
*
* @param connection the connection to MPD
* @param song_id the id of the song
* @param t the position within the song, in seconds
* @return true on success, false on error
*/
mpd_send_seek_id :: (connection: *mpd_connection, song_id: u32, t: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_seek_id() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param song_id the id of the song
* @param t the position within the song, in seconds
* @return true on success, false on error
*/
mpd_run_seek_id :: (connection: *mpd_connection, song_id: u32, t: u32) -> bool #foreign libmpdclient;

/**
* Seeks to the position t (in seconds; fractions allowed) of song id song_id.
*
* @param connection the connection to MPD
* @param song_id the id of the song
* @param t the position within the song, in seconds (fractions allowed)
* @return true on success, false on error
*/
mpd_send_seek_id_float :: (connection: *mpd_connection, song_id: u32, t: float) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_seek_id_float() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param song_id the id of the song
* @param t the position within the song, in seconds (fractions allowed)
* @return true on success, false on error
*/
mpd_run_seek_id_float :: (connection: *mpd_connection, song_id: u32, t: float) -> bool #foreign libmpdclient;

/**
* Seeks the current song.
*
* @param connection the connection to MPD
* @param t the position within the song, in seconds
* @param relative true makes #t a relative to the current position
* @return true on success, false on error
*
* @since MPD 0.17, libmpdclient 2.15
*/
mpd_send_seek_current :: (connection: *mpd_connection, t: float, relative: bool) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_seek_current() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param t the new position (in seconds)
* @param relative true to seek relative to the current position and
* false to seek to an absolute time stamp within the song
* @return true on success, false on error
*
* @since MPD 0.17, libmpdclient 2.15
*/
mpd_run_seek_current :: (connection: *mpd_connection, t: float, relative: bool) -> bool #foreign libmpdclient;

/**
* Sets repeat on/off for the current song.
* If mode is true, MPD repeats the song; otherwise, MPD does not repeat the
* song.
*
* @param connection the connection to MPD
* @param mode if true: repeat, if false: do not repeat
* @return true on success, false on error
*/
mpd_send_repeat :: (connection: *mpd_connection, mode: bool) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_repeat() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param mode if true: pause, if false: resume
* @return true on success, false on error
*/
mpd_run_repeat :: (connection: *mpd_connection, mode: bool) -> bool #foreign libmpdclient;

/**
* Sets random mode on/off for the queue.
* If mode is true, MPD enables random mode; otherwise, MPD disables random
* mode.
*
* @param connection the connection to MPD
* @param mode if true: enable random mode, if false: disable random mode
* @return true on success, false on error
*/
mpd_send_random :: (connection: *mpd_connection, mode: bool) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_random() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param mode if true: enable random mode, if false: disable random mode
* @return true on success, false on error
*/
mpd_run_random :: (connection: *mpd_connection, mode: bool) -> bool #foreign libmpdclient;

/**
* Sets single state for the playlist.
* If state is #MPD_SINGLE_ON, MPD enables single mode: playback is stopped
* after current song, or song is repeated if the repeat mode is enabled.
*
* If state is #MPD_SINGLE_OFF, MPD disables single mode: if random mode is
* enabled, the playlist order is shuffled after it is played completely.
*
* If state is #MPD_SINGLE_ONESHOT, MPD enables single mode temporarily: single
* mode is disabled (#MPD_SINGLE_OFF) after a song has been played and there is
* another song in the current playlist.
*
* @param connection the connection to MPD
* @param state the desired single mode state
* @return true on success, false on error or state is #MPD_SINGLE_UNKNOWN
*
* @since MPD 0.21, libmpdclient 2.18.
*/
mpd_send_single_state :: (connection: *mpd_connection, state: mpd_single_state) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_single_state() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param state the desired single mode state
* @return true on success, false on error or state is #MPD_SINGLE_UNKNOWN
*
* @since MPD 0.21, libmpdclient 2.18.
*/
mpd_run_single_state :: (connection: *mpd_connection, state: mpd_single_state) -> bool #foreign libmpdclient;

/**
* Sets single mode on/off for the playlist.
* This function does not support the 'oneshot' state for single mode: use
* mpd_send_single_state() instead.
*
* If mode is true, MPD enables single mode: playback is stopped after current
* song, or song is repeated if the repeat mode is enabled.
*
* If mode is false, MPD disables single mode: if random mode is enabled, the
* playlist order is shuffled after it is played completely.
*
* @param connection the connection to MPD
* @param mode if true: enable single mode, if false: disable single mode
* @return true on success, false on error
*
* @since MPD 0.15
*/
mpd_send_single :: (connection: *mpd_connection, mode: bool) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_single() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param mode if true: enable single mode, if false: disable single mode
* @return true on success, false on error
*
* @since MPD 0.15
*/
mpd_run_single :: (connection: *mpd_connection, mode: bool) -> bool #foreign libmpdclient;

/**
* Sets consume mode on/off for the playlist.
* If mode is true, MPD enables consume mode: each song played is removed from
* the playlist.
*
* If mode is false, MPD disables consume mode.
*
* @param connection the connection to MPD
* @param mode if true: enable consume mode, if false: disable consume mode
* @return true on success, false on error
*
* @since MPD 0.15
*/
mpd_send_consume :: (connection: *mpd_connection, mode: bool) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_consume() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param mode if true: enable consume mode, if false: disable consume mode
* @return true on success, false on error
*
* @since MPD 0.15
*/
mpd_run_consume :: (connection: *mpd_connection, mode: bool) -> bool #foreign libmpdclient;

/**
* Sets crossfading of seconds between songs on for the playlist.
* Crossfading only happens when the songs audio format are the same.
*
* @param connection the connection to MPD
* @param seconds seconds of crossfading between songs
* @return true on success, false on error
*/
mpd_send_crossfade :: (connection: *mpd_connection, seconds: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_crossfade() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param seconds seconds of crossfading between songs
* @return true on success, false on error
*/
mpd_run_crossfade :: (connection: *mpd_connection, seconds: u32) -> bool #foreign libmpdclient;

/**
* Sets the threshold at which songs will be overlapped. Like crossfading but
* doesn't fade the track volume, just overlaps.
*
* The songs need to have MixRamp tags added by an external tool. 0dB is the
* normalized maximum volume; so use negative values (I prefer -17dB). In the
* absence of MixRamp tags, crossfading will be used.
*
* @param connection the connection to MPD
* @param db decibels of volume for overlapping songs
* @return true on success, false on error
*
* @since libmpdclient 2.2
*/
mpd_send_mixrampdb :: (connection: *mpd_connection, db: float) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_mixrampdb() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param db decibels of volume for overlapping songs
* @return true on success, false on error
*
* @since libmpdclient 2.2
*/
mpd_run_mixrampdb :: (connection: *mpd_connection, db: float) -> bool #foreign libmpdclient;

/**
* Sets additional time subtracted from the overlap calculated by mixrampdb.
* A value of NaN disables MixRamp overlapping and falls back to crossfading.
*
* @param connection the connection to MPD
* @param seconds seconds subtracted from the overlap calculated by mixrampdb
* @return true on success, false on error
*
* @since libmpdclient 2.2
*/
mpd_send_mixrampdelay :: (connection: *mpd_connection, seconds: float) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_mixrampdelay() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param seconds seconds subtracted from the overlap calculated by mixrampdb
* @return true on success, false on error
*
* @since libmpdclient 2.2
*/
mpd_run_mixrampdelay :: (connection: *mpd_connection, seconds: float) -> bool #foreign libmpdclient;

/**
* Clears the current error message in MPD's status (this is also accomplished
* by any command that starts playback).
*
* @param connection the connection to MPD
* @return true on success, false on error
*
* @since libmpdclient 2.4
*/
mpd_send_clearerror :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_clearerror() and mpd_response_finish().
*
* @param connection the connection to MPD
* @return true on success, false on error
*
* @since libmpdclient 2.4
*/
mpd_run_clearerror :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

mpd_position_whence :: enum u32 {
    ABSOLUTE       :: 0;
    AFTER_CURRENT  :: 1;
    BEFORE_CURRENT :: 2;
}

/**
* Looks up the character of the specified whence position.
*
* @return the charater, or "" if the whence position is absolute or not valid.
*/
mpd_position_whence_char :: (whence: mpd_position_whence) -> *u8 #foreign libmpdclient;

/**
* Free memory allocated by the #mpd_playlist object.
*/
mpd_playlist_free :: (playlist: *mpd_playlist) -> void #foreign libmpdclient;

/**
* Duplicates a #mpd_playlist object.
*
* @return the new object, or NULL on out of memory
*/
mpd_playlist_dup :: (playlist: *mpd_playlist) -> *mpd_playlist #foreign libmpdclient;

/**
* Returns the path name of this playlist file.  It does not begin
* with a slash.
*/
mpd_playlist_get_path :: (playlist: *mpd_playlist) -> *u8 #foreign libmpdclient;

/**
* @return the POSIX UTC time stamp of the last modification, or 0 if
* that is unknown
*/
mpd_playlist_get_last_modified :: (playlist: *mpd_playlist) -> time_t #foreign libmpdclient;

/**
* Begins parsing a new playlist.
*
* @param pair the first pair in this playlist (name must be
* "playlist")
* @return the new #mpd_playlist object, or NULL on error (out of
* memory, or pair name is not "playlist")
*/
mpd_playlist_begin :: (pair: *mpd_pair) -> *mpd_playlist #foreign libmpdclient;

/**
* Parses the pair, adding its information to the specified
* #mpd_playlist object.
*
* @return true if the pair was parsed and added to the playlist (or if
* the pair was not understood and ignored), false if this pair is the
* beginning of the next playlist
*/
mpd_playlist_feed :: (playlist: *mpd_playlist, pair: *mpd_pair) -> bool #foreign libmpdclient;

/**
* Obtain a list of stored playlists.
* Use mpd_recv_playlist() to read the playlists.
*
* @param connection the connection to MPD
* @return true on success, false on error
*
* @since libmpdclient 2.5
*/
mpd_send_list_playlists :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Receives the next playlist from the MPD server.
*
* @return a #mpd_playlist object, or NULL on error or if the playlist list is
* finished
*/
mpd_recv_playlist :: (connection: *mpd_connection) -> *mpd_playlist #foreign libmpdclient;

/**
* List the content of the stored playlist identified by name.
* Use mpd_recv_entity() to receive the songs (#MPD_ENTITY_TYPE_SONG).
*
* @param connection the connection to MPD
* @param name the name of the playlist
* @return true on success, false on error
*/
mpd_send_list_playlist :: (connection: *mpd_connection, name: *u8) -> bool #foreign libmpdclient;

/**
* List the content, with full metadata, of the stored playlist identified by
* name.  Use mpd_recv_entity() to receive the songs (#MPD_ENTITY_TYPE_SONG).
*
* @param connection the connection to MPD
* @param name the name of the playlist
* @return true on success, false on error
*/
mpd_send_list_playlist_meta :: (connection: *mpd_connection, name: *u8) -> bool #foreign libmpdclient;

/**
* Clear the playlist name (i.e. truncate name.m3u)
*
* @param connection the connection to MPD
* @param name the name of the playlist
* @return true on success, false on error
*/
mpd_send_playlist_clear :: (connection: *mpd_connection, name: *u8) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_playlist_clear() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param name the name of the playlist
* @return true on success, false on error
*/
mpd_run_playlist_clear :: (connection: *mpd_connection, name: *u8) -> bool #foreign libmpdclient;

/**
* Add a path to a playlist. The playlist will be created if it does not
* exist.
*
* @param connection the connection to MPD
* @param name the name of the playlist
* @param path URI to be added
* @return true on success, false on error
*/
mpd_send_playlist_add :: (connection: *mpd_connection, name: *u8, path: *u8) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_playlist_add() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param name the name of the playlist
* @param path URI to be added
* @return true on success, false on error
*/
mpd_run_playlist_add :: (connection: *mpd_connection, name: *u8, path: *u8) -> bool #foreign libmpdclient;

/**
* Inserts a uri to a playlist for a given position. The playlist 
* will be created if it does not exist.
*
* @param connection the connection to MPD
* @param name the name of the playlist
* @param uri URI to be added
* @param to the desired position
* @return true on success, false on error
*
* @since libmpdclient 2.20
*/
mpd_send_playlist_add_to :: (connection: *mpd_connection, name: *u8, uri: *u8, to: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_playlist_add_to() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param name the name of the playlist
* @param uri URI to be added
* @param to the desired position
* @return true on success, false on error
*
* @since libmpdclient 2.20
*/
mpd_run_playlist_add_to :: (connection: *mpd_connection, name: *u8, uri: *u8, to: u32) -> bool #foreign libmpdclient;

/**
* Move a song from one position to another in the same playlist.
*
* @param connection the connection to MPD
* @param name the name of the playlist
* @param from previous song place in the playlist
* @param to next song position in the playlist
* @return true on success, false on error
*/
mpd_send_playlist_move :: (connection: *mpd_connection, name: *u8, from: u32, to: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_playlist_move() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param name the name of the playlist
* @param from previous song place in the playlist
* @param to next song position in the playlist
* @return true on success, false on error
*
* @since libmpdclient 2.19
*/
mpd_run_playlist_move :: (connection: *mpd_connection, name: *u8, from: u32, to: u32) -> bool #foreign libmpdclient;

/**
* Delete a position from a playlist.
*
* @param connection the connection to MPD
* @param name the name of the playlist
* @param pos song position in the playlist
* @return true on success, false on error
*/
mpd_send_playlist_delete :: (connection: *mpd_connection, name: *u8, pos: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_playlist_delete() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param name the name of the playlist
* @param pos song position in the playlist
* @return true on success, false on error
*/
mpd_run_playlist_delete :: (connection: *mpd_connection, name: *u8, pos: u32) -> bool #foreign libmpdclient;

/**
* Delete a range from a playlist.
*
* @param connection the connection to MPD
* @param name the name of the playlist
* @param start the start position of the range (including)
* @param end the end position of the range (excluding)
* @return true on success, false on error
*
* @since libmpdclient 2.20
*/
mpd_send_playlist_delete_range :: (connection: *mpd_connection, name: *u8, start: u32, end: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_playlist_delete_range() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param name the name of the playlist
* @param start the start position of the range (including)
* @param end the end position of the range (excluding)
* @return true on success, false on error
*
* @since libmpdclient 2.20
*/
mpd_run_playlist_delete_range :: (connection: *mpd_connection, name: *u8, start: u32, end: u32) -> bool #foreign libmpdclient;

/**
* Saves the current queue as a m3u file in the playlist directory
* (i.e. name.m3u).
*
* @param connection the connection to MPD
* @param name the name of the playlist file
* @return true on success, false on error
*/
mpd_send_save :: (connection: *mpd_connection, name: *u8) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_save() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param name the name of the playlist file
* @return true on success, false on error
*/
mpd_run_save :: (connection: *mpd_connection, name: *u8) -> bool #foreign libmpdclient;

/**
* Load a stored playlist into the queue.
*
* @param connection the connection to MPD
* @param name the name of the playlist file
* @return true on success, false on error
*
* @since libmpdclient 2.0
*/
mpd_send_load :: (connection: *mpd_connection, name: *u8) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_load() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param name the name of the playlist file
* @return true on success, false on error
*
* @since libmpdclient 2.0
*/
mpd_run_load :: (connection: *mpd_connection, name: *u8) -> bool #foreign libmpdclient;

/**
* Like mpd_send_load(), but load only a portion of the playlist.
*
* @param connection the connection to MPD
* @param name the name of the playlist file
* @param start the start position of the range (including)
* @param end the end position of the range (excluding); the special
* value "UINT_MAX" makes the end of the range open
* @return true on success, false on error
*
* @since libmpdclient 2.16
*/
mpd_send_load_range :: (connection: *mpd_connection, name: *u8, start: u32, end: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_load_range() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param name the name of the playlist file
* @param start the start position of the range (including)
* @param end the end position of the range (excluding); the special
* value "UINT_MAX" makes the end of the range open
* @return true on success, false on error
*
* @since libmpdclient 2.16
*/
mpd_run_load_range :: (connection: *mpd_connection, name: *u8, start: u32, end: u32) -> bool #foreign libmpdclient;

/**
* Like mpd_send_load() or mpd_send_load_range(), but with range 
* and to parameters.
*
* @param connection the connection to MPD
* @param name the name of the playlist file
* @param start the start position of the range (including)
* @param end the end position of the range (excluding); the special
* value "UINT_MAX" makes the end of the range open
* @param to the desired position of the song
* @param whence how to interpret the position parameter
* @return true on success, false on error
*
* @since libmpdclient 2.20
*/
mpd_send_load_range_to :: (connection: *mpd_connection, name: *u8, start: u32, end: u32, to: u32, whence: mpd_position_whence) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_load_range_to() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param name the name of the playlist file
* @param start the start position of the range (including)
* @param end the end position of the range (excluding); the special
* value "UINT_MAX" makes the end of the range open
* @param to the desired position of the song
* @param whence how to interpret the position parameter
* @return true on success, false on error
*
* @since libmpdclient 2.20
*/
mpd_run_load_range_to :: (connection: *mpd_connection, name: *u8, start: u32, end: u32, to: u32, whence: mpd_position_whence) -> bool #foreign libmpdclient;

/**
* Rename a playlist in the playlist directory.
*
* @param connection the connection to MPD
* @param from the previous name of the playlist file
* @param to the next name of the playlist file
* @return true on success, false on error
*/
mpd_send_rename :: (connection: *mpd_connection, from: *u8, to: *u8) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_rename() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param from the previous name of the playlist file
* @param to the next name of the playlist file
* @return true on success, false on error
*/
mpd_run_rename :: (connection: *mpd_connection, from: *u8, to: *u8) -> bool #foreign libmpdclient;

/**
* Remove a playlist from the playlist directory.
*
* @param connection the connection to MPD
* @param name the name of the playlist file
* @return true on success, false on error
*/
mpd_send_rm :: (connection: *mpd_connection, name: *u8) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_rm() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param name the name of the playlist file
* @return true on success, false on error
*/
mpd_run_rm :: (connection: *mpd_connection, name: *u8) -> bool #foreign libmpdclient;

/**
* Sends the "playlistinfo" command: list all songs in the queue
* including meta information.
* Use mpd_recv_entity() to receive the songs (#MPD_ENTITY_TYPE_SONG).
*
* @param connection the connection to MPD
* @return true on success, false on error
*/
mpd_send_list_queue_meta :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Like mpd_send_list_queue_meta(), but specifies a (position) range.
* Use mpd_recv_entity() to receive the songs (#MPD_ENTITY_TYPE_SONG).
*
* @param connection the connection to MPD
* @param start the start position of the range (including)
* @param end the end position of the range (excluding); the special
* value "UINT_MAX" makes the end of the range open
* @return true on success, false on error
*
* @since libmpdclient 2.8 added support for "UINT_MAX"
*/
mpd_send_list_queue_range_meta :: (connection: *mpd_connection, start: u32, end: u32) -> bool #foreign libmpdclient;

/**
* Requests information (including tags) about one song in the
* playlist (command "playlistid").
* Use mpd_recv_song() to obtain the song information.
*
* @param connection the connection to MPD
* @param pos the position of the requested song
*/
mpd_send_get_queue_song_pos :: (connection: *mpd_connection, pos: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_get_queue_song_pos() and mpd_recv_song().
*
* @param connection the connection to MPD
* @param pos the position of the requested song
* @return the song at the specified position, or NULL on error
*/
mpd_run_get_queue_song_pos :: (connection: *mpd_connection, pos: u32) -> *mpd_song #foreign libmpdclient;

/**
* Requests information (including tags) about one song in the
* playlist (command "playlistid").
* Use mpd_recv_song() to obtain the song information.
*
* @param connection the connection to MPD
* @param id the id of the requested song
*/
mpd_send_get_queue_song_id :: (connection: *mpd_connection, id: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_get_queue_song_id() and mpd_recv_song().
*
* @param connection the connection to MPD
* @param id the id of the requested song
* @return the song at the specified id, or NULL on error
*/
mpd_run_get_queue_song_id :: (connection: *mpd_connection, id: u32) -> *mpd_song #foreign libmpdclient;

/**
* Request the queue changes from MPD since the specified version,
* including tags.  The MPD command is called "plchanges".
*
* The current version can be fetched with mpd_status_get_queue_version().
* Use mpd_recv_song() to receive the songs of the new version.
*
* @param connection the connection to MPD
* @param version The playlist version you want the diff with.
* @return true on success, false on error
*/
mpd_send_queue_changes_meta :: (connection: *mpd_connection, version: u32) -> bool #foreign libmpdclient;

/**
* Same as mpd_send_queue_changes_meta(), but limit the result to a
* range.
*
* The current version can be fetched with mpd_status_get_queue_version().
* Use mpd_recv_song() to receive the songs of the new queue.
*
* @param connection the connection to MPD
* @param version The playlist version you want the diff with.
* @param start the start position of the range (including)
* @param end the end position of the range (excluding); the special
* value "UINT_MAX" makes the end of the range open
* @return true on success, false on error
*
* @since libmpdclient 2.12
*/
mpd_send_queue_changes_meta_range :: (connection: *mpd_connection, version: u32, start: u32, end: u32) -> bool #foreign libmpdclient;

/**
* A more bandwidth efficient version of the
* mpd_send_queue_changes_meta().  It only returns the position and id
* of changed songs.  The MPD command is called "plchangesposid".
*
* Use mpd_recv_queue_change_brief() for the response.
*
* @param connection A valid and connected mpd_connection.
* @param version The playlist version you want the diff with.
* @return true on success, false on error
*/
mpd_send_queue_changes_brief :: (connection: *mpd_connection, version: u32) -> bool #foreign libmpdclient;

/**
* Same as mpd_send_queue_changes_brief(), but limit the result to a
* range.
*
* Use mpd_recv_queue_change_brief() for the response.
*
* @param connection the connection to MPD
* @param version The playlist version you want the diff with.
* @param start the start position of the range (including)
* @param end the end position of the range (excluding); the special
* value "UINT_MAX" makes the end of the range open
* @return true on success, false on error
*
* @since libmpdclient 2.12
*/
mpd_send_queue_changes_brief_range :: (connection: *mpd_connection, version: u32, start: u32, end: u32) -> bool #foreign libmpdclient;

/**
* Receives a response element of mpd_send_queue_changes_brief() or
* mpd_send_queue_changes_brief_range().
*
* @param connection A valid and connected mpd_connection.
* @param position_r reference to the position of the changed song
* @param id_r reference to the id of the changed song
* @return true on success, false on error or if there are no more
* changes in this response
*/
mpd_recv_queue_change_brief :: (connection: *mpd_connection, position_r: *u32, id_r: *u32) -> bool #foreign libmpdclient;

/**
* Appends a song to the playlist: either a single file or a directory.
*
* @param connection A valid and connected mpd_connection.
* @param uri URI of a song or directory (added recursively)
* @return true on success, false on error
*/
mpd_send_add :: (connection: *mpd_connection, uri: *u8) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_add() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param uri URI of a song or directory (added recursively)
* @return true on success, false on error
*/
mpd_run_add :: (connection: *mpd_connection, uri: *u8) -> bool #foreign libmpdclient;

/**
* Inserts a song into the playlist for a given position: either a single file or a directory.
*
* @param connection A valid and connected mpd_connection.
* @param uri URI of a song or directory (added recursively)
* @param to the desired position of the song
* @param whence how to interpret the position parameter
* @return true on success, false on error
*
* @since libmpdclient 2.20
*/
mpd_send_add_whence :: (connection: *mpd_connection, uri: *u8, to: u32, whence: mpd_position_whence) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_add_whence() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param uri URI of a song or directory (added recursively)
* @param to the desired position of the song
* @param whence how to interpret the position parameter
* @return true on success, false on error
*
* @since libmpdclient 2.20
*/
mpd_run_add_whence :: (connection: *mpd_connection, uri: *u8, to: u32, whence: mpd_position_whence) -> bool #foreign libmpdclient;

/**
* Appends a song to the playlist. Call mpd_recv_song_id() for its id.
* file is always a single file or URL.
*
* @param connection the connection to MPD
* @param uri URI of the song to be added
* @return true on success, false on error
*/
mpd_send_add_id :: (connection: *mpd_connection, uri: *u8) -> bool #foreign libmpdclient;

/**
* Inserts a song into the playlist for a given position, and returns its id.
* file is always a single file or URL.
*
* @param connection the connection to MPD
* @param uri the URI of the song to be added
* @param to the desired position of the song
* @return true on success, false on error
*/
mpd_send_add_id_to :: (connection: *mpd_connection, uri: *u8, to: u32) -> bool #foreign libmpdclient;

/**
* Inserts a song into the playlist for a given position, and returns its id.
* file is always a single file or URL.
*
* @param connection the connection to MPD
* @param uri the URI of the song to be added
* @param to the desired position of the song
* @param whence how to interpret the position parameter
* @return true on success, false on error
* 
* @since libmpdclient 2.20
*/
mpd_send_add_id_whence :: (connection: *mpd_connection, uri: *u8, to: u32, whence: mpd_position_whence) -> bool #foreign libmpdclient;

/**
* Returns the id of the new song in the playlist.  To be called after
* mpd_send_add_id() or mpd_send_add_id_to().
*
* @param connection the connection to MPD
* @return the new song id, -1 on error or if MPD did not send an id
*/
mpd_recv_song_id :: (connection: *mpd_connection) -> s32 #foreign libmpdclient;

/**
* Executes the "addid" command and reads the response.
* file is always a single file or URL.
*
* @param connection the connection to MPD
* @param uri URI of a song to be added
* @return the new song id, -1 on error or if MPD did not send an id
*/
mpd_run_add_id :: (connection: *mpd_connection, uri: *u8) -> s32 #foreign libmpdclient;

/**
* Executes the "addid" command and reads the response.
* file is always a single file or URL.
*
* @param connection the connection to MPD
* @param uri the URI of the song to be added
* @param to the desired position of the song
* @return the new song id, -1 on error or if MPD did not send an id
*/
mpd_run_add_id_to :: (connection: *mpd_connection, uri: *u8, to: u32) -> s32 #foreign libmpdclient;

/**
* Executes the "addid" command and reads the response.
* file is always a single file or URL.
*
* @param connection the connection to MPD
* @param uri the URI of the song to be added
* @param to the desired position of the song
* @param whence how to interpret the position parameter
* @return the new song id, -1 on error or if MPD did not send an id
* 
* @since libmpdclient 2.20
*/
mpd_run_add_id_whence :: (connection: *mpd_connection, uri: *u8, to: u32, whence: mpd_position_whence) -> s32 #foreign libmpdclient;

/**
* Deletes a song from the queue.
*
* @param connection the connection to MPD
* @param pos the position of the song to be deleted
* @return true on success, false on error
*/
mpd_send_delete :: (connection: *mpd_connection, pos: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_delete() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param pos the position of the song to be deleted
* @return true on success, false on error
*/
mpd_run_delete :: (connection: *mpd_connection, pos: u32) -> bool #foreign libmpdclient;

/**
* Deletes songs from the queue.
*
* @param connection the connection to MPD
* @param start the start position of the range (including)
* @param end the end position of the range (excluding); the special
* value "UINT_MAX" makes the end of the range open
* @return true on success, false on error
*
* @since libmpdclient 2.8 added support for "UINT_MAX"
*/
mpd_send_delete_range :: (connection: *mpd_connection, start: u32, end: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_delete_range() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param start the start position of the range (including)
* @param end the end position of the range (excluding); the special
* value "UINT_MAX" makes the end of the range open
* @return true on success, false on error
*
* @since libmpdclient 2.8 added support for "UINT_MAX"
*/
mpd_run_delete_range :: (connection: *mpd_connection, start: u32, end: u32) -> bool #foreign libmpdclient;

/**
* Deletes a song from the queue.
*
* @param connection the connection to MPD
* @param id the id of the song to be deleted
* @return true on success, false on error
*/
mpd_send_delete_id :: (connection: *mpd_connection, id: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_delete_id() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param id the id of the song to be deleted
* @return true on success, false on error
*/
mpd_run_delete_id :: (connection: *mpd_connection, id: u32) -> bool #foreign libmpdclient;

/**
* Shuffles the queue.
*
* @param connection the connection to MPD
* @return true on success, false on error
*/
mpd_send_shuffle :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_shuffle() and mpd_response_finish().
*
* @param connection the connection to MPD
* @return true on success, false on error
*/
mpd_run_shuffle :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Shuffles a range within the queue.
*
* @param connection the connection to MPD
* @param start the start position of the range (including)
* @param end the end position of the range (excluding); the special
* value "UINT_MAX" makes the end of the range open
* @return true on success, false on error
*
* @since libmpdclient 2.8 added support for "UINT_MAX"
*/
mpd_send_shuffle_range :: (connection: *mpd_connection, start: u32, end: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_shuffle_range() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param start the start position of the range (including)
* @param end the end position of the range (excluding); the special
* value "UINT_MAX" makes the end of the range open
* @return true on success, false on error
*
* @since libmpdclient 2.8 added support for "UINT_MAX"
*/
mpd_run_shuffle_range :: (connection: *mpd_connection, start: u32, end: u32) -> bool #foreign libmpdclient;

/**
* Clear the queue.
*
* @param connection the connection to MPD
* @return true on success, false on error
*/
mpd_send_clear :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_clear() and mpd_response_finish().
*
* @param connection the connection to MPD
* @return true on success, false on error
*/
mpd_run_clear :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Moves a song within the queue.
*
* @param connection the connection to MPD
* @param from the source song position
* @param to the new position of the song
* @return true on success, false on error
*/
mpd_send_move :: (connection: *mpd_connection, from: u32, to: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_move() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param from the source song position
* @param to the new position of the song
* @return true on success, false on error
*/
mpd_run_move :: (connection: *mpd_connection, from: u32, to: u32) -> bool #foreign libmpdclient;

/**
* Moves a song within the queue.
*
* @param connection the connection to MPD
* @param from the source song id
* @param to the new position of the song (not an id!)
* @return true on success, false on error
*/
mpd_send_move_id :: (connection: *mpd_connection, from: u32, to: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_move_id() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param from the source song id
* @param to the new position of the song (not an id!)
* @return true on success, false on error
*/
mpd_run_move_id :: (connection: *mpd_connection, from: u32, to: u32) -> bool #foreign libmpdclient;

/**
* Moves a range of songs within the queue.
*
* @param connection the connection to MPD
* @param start the start position of the range (including)
* @param end the end position of the range (excluding); the special
* value "UINT_MAX" makes the end of the range open
* @param to the new position of the song range
* @return true on success, false on error
*
* @since libmpdclient 2.8 added support for "UINT_MAX"
*/
mpd_send_move_range :: (connection: *mpd_connection, start: u32, end: u32, to: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_move_range() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param start the start position of the range (including)
* @param end the end position of the range (excluding); the special
* value "UINT_MAX" makes the end of the range open
* @param to the new position of the song range
* @return true on success, false on error
*
* @since libmpdclient 2.8 added support for "UINT_MAX"
*/
mpd_run_move_range :: (connection: *mpd_connection, start: u32, end: u32, to: u32) -> bool #foreign libmpdclient;

/**
* Swap the position of two songs in the queue.
*
* @param connection the connection to MPD
* @param pos1 the position of one song
* @param pos2 the position of the other song
* @return true on success, false on error
*/
mpd_send_swap :: (connection: *mpd_connection, pos1: u32, pos2: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_swap() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param pos1 the position of one song
* @param pos2 the position of the other song
* @return true on success, false on error
*/
mpd_run_swap :: (connection: *mpd_connection, pos1: u32, pos2: u32) -> bool #foreign libmpdclient;

/**
* Swap the position of two songs in the queue.
*
* @param connection the connection to MPD
* @param id1 the id of one song
* @param id2 the id of the other song
* @return true on success, false on error
*/
mpd_send_swap_id :: (connection: *mpd_connection, id1: u32, id2: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_swap_id() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param id1 the id of one song
* @param id2 the id of the other song
* @return true on success, false on error
*/
mpd_run_swap_id :: (connection: *mpd_connection, id1: u32, id2: u32) -> bool #foreign libmpdclient;

/**
* Adds a tag to the specified song (command "addtagid").
*
* @param connection the connection to MPD
* @param id the id of the song
* @param tag the tag to be added
* @param value the tag value
* @return true on success, false on error
*
* @since libmpdclient 2.12, MPD 0.19
*/
mpd_send_add_tag_id :: (connection: *mpd_connection, id: u32, tag: mpd_tag_type, value: *u8) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_add_tag_id() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param id the id of the song
* @param tag the tag to be added
* @param value the tag value
* @return true on success, false on error
*
* @since libmpdclient 2.12, MPD 0.19
*/
mpd_run_add_tag_id :: (connection: *mpd_connection, id: u32, tag: mpd_tag_type, value: *u8) -> bool #foreign libmpdclient;

/**
* Remove a tag from the specified song (command "cleartagid").
*
* @param connection the connection to MPD
* @param id the id of the song
* @param tag the tag to be cleared
* @return true on success, false on error
*
* @since libmpdclient 2.12, MPD 0.19
*/
mpd_send_clear_tag_id :: (connection: *mpd_connection, id: u32, tag: mpd_tag_type) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_clear_tag_id() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param id the id of the song
* @param tag the tag to be cleared
* @return true on success, false on error
*
* @since libmpdclient 2.12, MPD 0.19
*/
mpd_run_clear_tag_id :: (connection: *mpd_connection, id: u32, tag: mpd_tag_type) -> bool #foreign libmpdclient;

/**
* Remove all tags from the specified song (command "cleartagid").
*
* @param connection the connection to MPD
* @param id the id of the song
* @return true on success, false on error
*
* @since libmpdclient 2.12, MPD 0.19
*/
mpd_send_clear_all_tags_id :: (connection: *mpd_connection, id: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_clear_all_tags_id() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param id the id of the song
* @return true on success, false on error
*
* @since libmpdclient 2.12, MPD 0.19
*/
mpd_run_clear_all_tags_id :: (connection: *mpd_connection, id: u32) -> bool #foreign libmpdclient;

/**
* Change the priority of the specified song.
*
* @param connection the connection to MPD
* @param priority a number between 0 and 255
* @param position the position of the song
* @return true on success, false on error
*
* @since libmpdclient 2.6
*/
mpd_send_prio :: (connection: *mpd_connection, priority: u32, position: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_prio() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param priority a number between 0 and 255
* @param position the position of the song
* @return true on success, false on error
*
* @since libmpdclient 2.6
*/
mpd_run_prio :: (connection: *mpd_connection, priority: u32, position: u32) -> bool #foreign libmpdclient;

/**
* Change the priority of a song range.
*
* @param connection the connection to MPD
* @param priority a number between 0 and 255
* @param start the start position of the range (including)
* @param end the end position of the range (excluding); the special
* value "UINT_MAX" makes the end of the range open
* @return true on success, false on error
*
* @since libmpdclient 2.6
* @since libmpdclient 2.8 added support for "UINT_MAX"
*/
mpd_send_prio_range :: (connection: *mpd_connection, priority: u32, start: u32, end: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_prio_range() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param priority a number between 0 and 255
* @param start the start position of the range (including)
* @param end the end position of the range (excluding); the special
* value "UINT_MAX" makes the end of the range open
* @return true on success, false on error
*
* @since libmpdclient 2.6
* @since libmpdclient 2.8 added support for "UINT_MAX"
*/
mpd_run_prio_range :: (connection: *mpd_connection, priority: u32, start: u32, end: u32) -> bool #foreign libmpdclient;

/**
* Change the priority of the specified song.
*
* @param connection the connection to MPD
* @param priority a number between 0 and 255
* @param id the id of the song
* @return true on success, false on error
*
* @since libmpdclient 2.6
*/
mpd_send_prio_id :: (connection: *mpd_connection, priority: u32, id: u32) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_prio_id() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param priority a number between 0 and 255
* @param id the id of the song
* @return true on success, false on error
*
* @since libmpdclient 2.6
*/
mpd_run_prio_id :: (connection: *mpd_connection, priority: u32, id: u32) -> bool #foreign libmpdclient;

/**
* Specify the portion of a song that shall be played.
* The song is identified by its id and cannot be the currently playing song.
*
* The start/end values are offsets in seconds (fractional seconds allowed);
* both are optional.
*
* @param connection the connection to MPD
* @param id the id of the song (cannot be the currently playing song)
* @param start the offset in seconds for starting the song
* @param end the offset in seconds for ending the song; a negative
* value makes the end of the range open
* @return true on success, false on error
*
* @since libmpdclient 2.19, MPD 0.20
*/
mpd_send_range_id :: (connection: *mpd_connection, id: u32, start: float, end: float) -> bool #foreign libmpdclient;

/**
*
* Shortcut for mpd_send_range_id() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param id the id of the song (cannot be the currently playing song)
* @param start the offset in seconds for starting the song
* @param end the offset in seconds for ending the song; a negative
* value makes the end of the range open
* @return true on success, false on error
*
* @since libmpdclient 2.19, MPD 0.20
*/
mpd_run_range_id :: (connection: *mpd_connection, id: u32, start: float, end: float) -> bool #foreign libmpdclient;

/**
* Sends the "readpicture" command to MPD.  Call mpd_recv_readpicture() to
* read response lines.
*
* @param connection a valid and connected #mpd_connection
* @param uri the URI of the song
* @param offset to read from
* @return true on success
*/
mpd_send_readpicture :: (connection: *mpd_connection, uri: *u8, offset: u32) -> bool #foreign libmpdclient;

/**
* Receives the "readpicture" response
*
* @param connection a valid and connected #mpd_connection
* @param buffer an already allocated buffer, should be of the same size as the binary
* chunk size (default 8192, can be set with binarylimit command)
* @param buffer_size the size of the allocated buffer
* @return read size on success, -1 on failure
*/
mpd_recv_readpicture :: (connection: *mpd_connection, buffer: *void, buffer_size: size_t) -> s32 #foreign libmpdclient;

/**
* Shortcut for mpd_send_readpicture(), mpd_recv_readpicture() and
* mpd_response_finish().
*
* @param connection a valid and connected #mpd_connection
* @param uri the URI of the song
* @param offset to read from
* @param buffer an already allocated buffer, should be of the same size as the binary
* chunk size (default 8192, can be set with binarylimit command)
* @param buffer_size the size of the allocated buffer
* @return read size on success, -1 on failure
*/
mpd_run_readpicture :: (connection: *mpd_connection, uri: *u8, offset: u32, buffer: *void, buffer_size: size_t) -> s32 #foreign libmpdclient;

/**
* MPD's replay gain mode.
*
* @since libmpdclient 2.19, MPD 0.16.
*/
mpd_replay_gain_mode :: enum u32 {
    OFF     :: 0;
    TRACK   :: 1;
    ALBUM   :: 2;
    AUTO    :: 3;
    UNKNOWN :: 4;
}

/**
* Parse a #mpd_pair value to check which replay gain mode it contains.
*/
mpd_parse_replay_gain_name :: (name: *u8) -> mpd_replay_gain_mode #foreign libmpdclient;

/**
* Looks up the name of the specified replay gain mode.
*
* @return the name, or NULL if the replay gain mode is not valid
*
* @since libmpdclient 2.19.
*/
mpd_lookup_replay_gain_mode :: (mode: mpd_replay_gain_mode) -> *u8 #foreign libmpdclient;

/**
* Queries the current state of replay gain mode on MPD.
*
* Sends the "replay_gain_status" command to MPD. Call mpd_recv_pair() to
* read response lines. The pair's name should be "replay_gain_mode". Use
* mpd_parse_replay_gain_name() to check each pair's value.
*
* @param connection the connection to MPD
* @return true on success, false on error
*
* @since MPD 0.16, libmpdclient 2.19.
*/
mpd_send_replay_gain_status :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_replay_gain_status(), mpd_recv_pair_named() and
* mpd_response_finish().
*
* @param connection the connection to MPD
* @return #mpd_replay_gain_mode object: #MPD_REPLAY_UNKNOWN on error (or
* unknown ReplayGain mode); other modes on success.
*
* @since MPD 0.16, libmpdclient 2.19.
*/
mpd_run_replay_gain_status :: (connection: *mpd_connection) -> mpd_replay_gain_mode #foreign libmpdclient;

/**
* Sets the current state of replay gain mode on MPD.
*
* @param connection the connection to MPD
* @param mode the desired replay gain mode
* @return true on success, false on error
*
* @since MPD 0.16, libmpdclient 2.19.
*/
mpd_send_replay_gain_mode :: (connection: *mpd_connection, mode: mpd_replay_gain_mode) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_replay_gain_mode() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param mode mode the desired replay gain mode
* @return true on success, false on error
*
* @since MPD 0.16, libmpdclient 2.19.
*/
mpd_run_replay_gain_mode :: (connection: *mpd_connection, mode: mpd_replay_gain_mode) -> bool #foreign libmpdclient;

/**
* Finishes the response and checks if the command was successful.  If
* there are data pairs left, they are discarded.
*
* @return true on success, false on error
*/
mpd_response_finish :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Finishes the response of the current list command.  If there are
* data pairs left, they are discarded.
*
* @return true on success, false on error
*/
mpd_response_next :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* This type is not yet used, it is reserved for a future protocol
* extension which will allow us to specify a comparison operator for
* constraints.
*/
mpd_operator :: enum u32 {
    MPD_OPERATOR_DEFAULT :: 0;
}

/**
* Search for songs in the database.
* Constraints may be specified with mpd_search_add_tag_constraint().
* Send the search command with mpd_search_commit(), and read the
* response items with mpd_recv_song().
*
* @param connection the connection to MPD
* @param exact if to match exact
* @return true on success, false on error
*/
mpd_search_db_songs :: (connection: *mpd_connection, exact: bool) -> bool #foreign libmpdclient;

/**
* Search for songs in the database and adds the result to the queue.
* Constraints may be specified with mpd_search_add_tag_constraint().
* Send the search command with mpd_search_commit().
*
* @param connection the connection to MPD
* @param exact if to match exact (only "true" supported by MPD 0.16)
* @return true on success, false on error
*/
mpd_search_add_db_songs :: (connection: *mpd_connection, exact: bool) -> bool #foreign libmpdclient;

/**
* Search for songs in the database and adds the result to a playlist.
* Constraints may be specified with mpd_search_add_tag_constraint().
* Send the search command with mpd_search_commit().
*
* @param connection the connection to MPD
* @param playlist_name the name of the playlist where songs shall be
* added
* @return true on success, false on error
*
* @since libmpdclient 2.17.
*/
mpd_search_add_db_songs_to_playlist :: (connection: *mpd_connection, playlist_name: *u8) -> bool #foreign libmpdclient;

/**
* Search for songs in the queue.
* Constraints may be specified with mpd_search_add_tag_constraint().
* Send the search command with mpd_search_commit(), and read the
* response items with mpd_recv_song().
*
* @param connection the connection to MPD
* @param exact if to match exact
* @return true on success, false on error
*/
mpd_search_queue_songs :: (connection: *mpd_connection, exact: bool) -> bool #foreign libmpdclient;

/**
* Obtains a list of unique tag values from the database.
* Constraints may be specified with mpd_search_add_tag_constraint().
* Send the search command with mpd_search_commit(), and read the
* response items with mpd_recv_pair_tag().
*
* @param connection the connection to MPD
* @param type The type of the tags to search for
* @return true on success, false on error
*/
mpd_search_db_tags :: (connection: *mpd_connection, type: mpd_tag_type) -> bool #foreign libmpdclient;

/**
* Gathers statistics on a set of songs in the database.
* Constraints may be specified with mpd_search_add_tag_constraint().
* Send the command with mpd_search_commit(), and read the response
* with mpd_recv_stats().
*
* @param connection the connection to MPD
* @return true on success, false on error
*/
mpd_count_db_songs :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Limit the search to a certain directory.
*
* @param connection a #mpd_connection
* @param oper reserved, pass #MPD_OPERATOR_DEFAULT
* @param value the URI relative to the music directory
* @return true on success, false on error
*
* @since libmpdclient 2.9
*/
mpd_search_add_base_constraint :: (connection: *mpd_connection, oper: mpd_operator, value: *u8) -> bool #foreign libmpdclient;

/**
* Add a constraint on the song's URI.
*
* @param connection a #mpd_connection
* @param oper reserved, pass #MPD_OPERATOR_DEFAULT
* @param value The value of the constraint
* @return true on success, false on error
*/
mpd_search_add_uri_constraint :: (connection: *mpd_connection, oper: mpd_operator, value: *u8) -> bool #foreign libmpdclient;

/**
* Add a constraint to a search limiting the value of a tag.
*
* @param connection a #mpd_connection
* @param oper reserved, pass #MPD_OPERATOR_DEFAULT
* @param type The tag type of the constraint
* @param value The value of the constraint
* @return true on success, false on error
*/
mpd_search_add_tag_constraint :: (connection: *mpd_connection, oper: mpd_operator, type: mpd_tag_type, value: *u8) -> bool #foreign libmpdclient;

/**
* Add a constraint to a search, search for a value in any tag.
*
* @param connection a #mpd_connection
* @param oper reserved, pass #MPD_OPERATOR_DEFAULT
* @param value The value of the constraint
* @return true on success, false on error
*/
mpd_search_add_any_tag_constraint :: (connection: *mpd_connection, oper: mpd_operator, value: *u8) -> bool #foreign libmpdclient;

/**
* Limit the search to files modified after the given time stamp.
*
* @param connection a #mpd_connection
* @param oper reserved, pass #MPD_OPERATOR_DEFAULT
* @param value the reference time stamp
* @return true on success, false on error
*
* @since libmpdclient 2.10
*/
mpd_search_add_modified_since_constraint :: (connection: *mpd_connection, oper: mpd_operator, value: time_t) -> bool #foreign libmpdclient;

/**
* Add an expression string.
*
* @param connection a #mpd_connection
* @param expression the expression string; must be enclosed in
* parentheses
* @return true on success, false on error
*
* @since libmpdclient 2.15, MPD 0.21
*/
mpd_search_add_expression :: (connection: *mpd_connection, expression: *u8) -> bool #foreign libmpdclient;

/**
* Group the results by the specified tag.
*
* @param connection a #mpd_connection
* @param type the tag type to group by
* @return true on success, false on error
*
* @since libmpdclient 2.12, MPD 0.19
*/
mpd_search_add_group_tag :: (connection: *mpd_connection, type: mpd_tag_type) -> bool #foreign libmpdclient;

/**
* Sort the results by the specified named attribute.
*
* @param connection a #mpd_connection
* @param name the attribute name to sort with; can be a tag name or
* "Last-Modified"
* @param descending sort in reverse order?
* @return true on success, false on error
*
* @since MPD 0.21, libmpdclient 2.15
*/
mpd_search_add_sort_name :: (connection: *mpd_connection, name: *u8, descending: bool) -> bool #foreign libmpdclient;

/**
* Sort the results by the specified tag.
*
* @param connection a #mpd_connection
* @param type the tag type to sort with
* @param descending sort in reverse order?
* @return true on success, false on error
*
* @since MPD 0.21, libmpdclient 2.11; #descending since libmpdclient
* 2.15
*/
mpd_search_add_sort_tag :: (connection: *mpd_connection, type: mpd_tag_type, descending: bool) -> bool #foreign libmpdclient;

/**
* Request only a portion of the result set.
*
* @param connection a #mpd_connection
* @param start the start offset (including)
* @param end the end offset (not including)
* @return true on success, false on error
*
* @since libmpdclient 2.10
*/
mpd_search_add_window :: (connection: *mpd_connection, start: u32, end: u32) -> bool #foreign libmpdclient;

/**
* Adds the search to the specified position in the queue.
*
* @param connection a #mpd_connection
* @param position the position in the queue
* @param whence how to interpret the position parameter
* 
* @since libmpdclient 2.20
*/
mpd_search_add_position :: (connection: *mpd_connection, position: u32, whence: mpd_position_whence) -> bool #foreign libmpdclient;

/**
* Starts the real search with constraints added with
* mpd_search_add_constraint().
*
* @param connection the connection to MPD
* @return true on success, false on error
*/
mpd_search_commit :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Cancels the search request before you have called
* mpd_search_commit().  Call this to clear the current search
* request.
*
* @param connection the connection to MPD
*/
mpd_search_cancel :: (connection: *mpd_connection) -> void #foreign libmpdclient;

/**
* Same as mpd_recv_pair_named(), but the pair name is specified as
* #mpd_tag_type.
*
* @param connection the connection to MPD
* @param type the tag type you are looking for
* @return a pair, or NULL on error or if there are no more matching
* pairs in this response
*/
mpd_recv_pair_tag :: (connection: *mpd_connection, type: mpd_tag_type) -> *mpd_pair #foreign libmpdclient;

/**
* Sends a command with arguments to the MPD server.  The argument
* list must be terminated with a NULL.
*
* @param connection the connection to the MPD server
* @param command the command to be sent
* @return true on success
*/
mpd_send_command_CFormat :: (connection: *mpd_connection, command: *u8, __args: ..Any) -> bool #foreign libmpdclient;
mpd_send_command :: (connection: *mpd_connection, command: string, __args: ..Any) -> bool {
    push_allocator(temp);
    formatted_text_builder: String_Builder;
    print_to_builder(*formatted_text_builder, command, ..__args);
    append(*formatted_text_builder, "\0");
    formatted_text := builder_to_string(*formatted_text_builder);
    return mpd_send_command_CFormat(connection, "%s", formatted_text.data);
} @PrintLike

/**
* Creates a new #mpd_settings object.  The values which are not
* passed by the caller are taken from environment variables.
*
* @param host the server's host name, IP address or Unix socket path.
* An address starting with '@' denotes an "abstract socket".
* NULL is allowed here, which will connect to the default host
* (using the MPD_HOST environment variable if present).
* @param port the TCP port to connect to, 0 for default port (using
* the MPD_PORT environment variable if present).  If "host" is a Unix
* socket path, this parameter is ignored.
* @param timeout_ms the timeout in milliseconds, 0 for the default
* timeout (the environment variable MPD_TIMEOUT may specify a timeout
* in seconds)
* @param reserved reserved for future use, pass NULL
* @param password the password, or NULL to use the default (MPD_HOST
* before "@")
* @return a #mpd_settings object or NULL if out of memory
*
* @since libmpdclient 2.4
*/
mpd_settings_new :: (host: *u8, port: u32, timeout_ms: u32, reserved: *u8, password: *u8) -> *mpd_settings #foreign libmpdclient;

/**
* Releases a #mpd_settings object.
*
* @since libmpdclient 2.4
*/
mpd_settings_free :: (settings: *mpd_settings) -> void #foreign libmpdclient;

/**
* Returns the host name (without password/port), or NULL if unknown.
*
* @since libmpdclient 2.4
*/
mpd_settings_get_host :: (settings: *mpd_settings) -> *u8 #foreign libmpdclient;

/**
* Returns the port number, or 0 if not applicable.
*
* @since libmpdclient 2.4
*/
mpd_settings_get_port :: (settings: *mpd_settings) -> u32 #foreign libmpdclient;

/**
* Returns the timeout in milliseconds, or 0 if unknown.
*
* @since libmpdclient 2.4
*/
mpd_settings_get_timeout_ms :: (settings: *mpd_settings) -> u32 #foreign libmpdclient;

/**
* Returns the password, or NULL if none was configured.
*
* @since libmpdclient 2.4
*/
mpd_settings_get_password :: (settings: *mpd_settings) -> *u8 #foreign libmpdclient;

/**
* \struct mpd_stats
*
* An opaque object representing MPD's response to the "stats"
* command.  To release this object, call mpd_stats_free().
*/
mpd_stats :: struct {}

/**
* Send the "stats" command to MPD. Call mpd_recv_stats() to read the response.
*
* @return true on success
*/
mpd_send_stats :: (connection: *mpd_connection) -> bool #foreign libmpdclient;

/**
* Begins parsing server stats: creates a new empty #mpd_stats object.
* Free it with mpd_stats_free().
*
* @return the newly allocated #mpd_stats object, or NULL if out of
* memory
*/
mpd_stats_begin :: () -> *mpd_stats #foreign libmpdclient;

/**
* Parses the pair, adding its information to the specified #mpd_stats
* object.
*/
mpd_stats_feed :: (stats: *mpd_stats, pair: *mpd_pair) -> void #foreign libmpdclient;

/**
* Reads the "stats" response from MPD.
*
* @return a #mpd_stats object, or NULL on error
*/
mpd_recv_stats :: (connection: *mpd_connection) -> *mpd_stats #foreign libmpdclient;

/**
* Shortcut for mpd_send_stats() and mpd_recv_stats().
*/
mpd_run_stats :: (connection: *mpd_connection) -> *mpd_stats #foreign libmpdclient;

/**
* Frees a #mpd_stats object.
*/
mpd_stats_free :: (stats: *mpd_stats) -> void #foreign libmpdclient;

/**
* @return the number of distinct artists in MPD's database, or 0 if
* unknown
*/
mpd_stats_get_number_of_artists :: (stats: *mpd_stats) -> u32 #foreign libmpdclient;

/**
* @return the number of distinct album names in MPD's database, or 0
* if unknown
*/
mpd_stats_get_number_of_albums :: (stats: *mpd_stats) -> u32 #foreign libmpdclient;

/**
* @return the total number of song files in MPD's database, or 0 if
* unknown
*/
mpd_stats_get_number_of_songs :: (stats: *mpd_stats) -> u32 #foreign libmpdclient;

/**
* @return the uptime of MPD in seconds, or 0 if unknown
*/
mpd_stats_get_uptime :: (stats: *mpd_stats) -> u64 #foreign libmpdclient;

/**
* @return the UNIX time stamp of the last database update, or 0 if
* unknown
*/
mpd_stats_get_db_update_time :: (stats: *mpd_stats) -> u64 #foreign libmpdclient;

/**
* @return the accumulated time MPD was playing music since the
* process was started, or 0 if unknown
*/
mpd_stats_get_play_time :: (stats: *mpd_stats) -> u64 #foreign libmpdclient;

/**
* @return the accumulated duration of all songs in the database, or 0
* if unknown
*/
mpd_stats_get_db_play_time :: (stats: *mpd_stats) -> u64 #foreign libmpdclient;

/**
* Adds or replaces a sticker value.
*
* @param connection the connection to MPD
* @param type the object type, e.g. "song"
* @param uri the URI of the object
* @param name the name of the sticker
* @param value the value of the sticker
* @return true on success, false on error
*
* @since libmpdclient 2.1
*/
mpd_send_sticker_set :: (connection: *mpd_connection, type: *u8, uri: *u8, name: *u8, value: *u8) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_sticker_set() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param type the object type, e.g. "song"
* @param uri the URI of the object
* @param name the name of the sticker
* @param value the value of the sticker
* @return true on success, false on error
*
* @since libmpdclient 2.1
*/
mpd_run_sticker_set :: (connection: *mpd_connection, type: *u8, uri: *u8, name: *u8, value: *u8) -> bool #foreign libmpdclient;

/**
* Deletes a sticker value.
*
* @param connection the connection to MPD
* @param type the object type, e.g. "song"
* @param uri the URI of the object
* @param name the name of the sticker
* @return true on success, false on error
*
* @since libmpdclient 2.1
*/
mpd_send_sticker_delete :: (connection: *mpd_connection, type: *u8, uri: *u8, name: *u8) -> bool #foreign libmpdclient;

/**
* Shortcut for mpd_send_sticker_delete() and mpd_response_finish().
*
* @param connection the connection to MPD
* @param type the object type, e.g. "song"
* @param uri the URI of the object
* @param name the name of the sticker
* @return true on success, false on error
*
* @since libmpdclient 2.1
*/
mpd_run_sticker_delete :: (connection: *mpd_connection, type: *u8, uri: *u8, name: *u8) -> bool #foreign libmpdclient;

/**
* Queries a sticker value.  Call mpd_recv_sticker() to receive the response.
*
* @param connection the connection to MPD
* @param type the object type, e.g. "song"
* @param uri the URI of the object
* @param name the name of the sticker
* @return true on success, false on error
*
* @since libmpdclient 2.1
*/
mpd_send_sticker_get :: (connection: *mpd_connection, type: *u8, uri: *u8, name: *u8) -> bool #foreign libmpdclient;

/**
* Obtains a list of all stickers of the specified object.  Call
* mpd_recv_sticker() to receive each response item.
*
* @param connection the connection to MPD
* @param type the object type, e.g. "song"
* @param uri the URI of the object
* @return true on success, false on error
*
* @since libmpdclient 2.1
*/
mpd_send_sticker_list :: (connection: *mpd_connection, type: *u8, uri: *u8) -> bool #foreign libmpdclient;

/**
* Searches for stickers with the specified name. Call mpd_recv_sticker() to
* receive each response item.
*
* @param connection the connection to MPD
* @param type the object type, e.g. "song"
* @param base_uri the base URI to start the search, e.g. a directory;
* NULL to search for all objects of the specified type
* @param name the name of the sticker
* @return true on success, false on error
*
* @since libmpdclient 2.1
*/
mpd_send_sticker_find :: (connection: *mpd_connection, type: *u8, base_uri: *u8, name: *u8) -> bool #foreign libmpdclient;

/**
* Parse a sticker input line in the form "name=value".
*
* @param input the input value, the value from a received pair named
* "sticker"
* @param name_length_r the length of the name (starting at the
* beginning of the input string) is returned here
* @return a pointer to the sticker value, or NULL on error
*
* @since libmpdclient 2.1
*/
mpd_parse_sticker :: (input: *u8, name_length_r: *size_t) -> *u8 #foreign libmpdclient;

/**
* Receives the next sticker.  You have to free the return value with
* mpd_return_sticker().
*
* @param connection the connection to MPD
* @return a #mpd_pair object on success, NULL on end of response or
* error
*
* @since libmpdclient 2.1
*/
mpd_recv_sticker :: (connection: *mpd_connection) -> *mpd_pair #foreign libmpdclient;

/**
* Free the pair returned by mpd_recv_sticker().
*
* @since libmpdclient 2.1
*/
mpd_return_sticker :: (connection: *mpd_connection, pair: *mpd_pair) -> void #foreign libmpdclient;

#scope_file


#if OS == .LINUX {
    #import "POSIX";
    libmpdclient :: #foreign_library "linux/libmpdclient";
}
