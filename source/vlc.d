module vlc;

/*****************************************************************************
 * libvlc.h:  libvlc external API
 *****************************************************************************
 * Copyright (C) 1998-2009 VLC authors and VideoLAN
 * $Id: b12d900469fa6438c41421f2ac7697b93ffc8a35 $
 *
 * Authors: Clément Stenac <zorglub@videolan.org>
 *          Jean-Paul Saman <jpsaman@videolan.org>
 *          Pierre d'Herbemont <pdherbemont@videolan.org>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

import core.stdc.config;
import core.stdc.stdint;
import core.stdc.stdio;

extern (C):

/**
 * \defgroup libvlc LibVLC
 * LibVLC is the external programming interface of the VLC media player.
 * It is used to embed VLC into other applications or frameworks.
 * @{
 * \file
 * LibVLC core external API
 */

enum VLC_LIBVLC_H = 1;

/* Avoid unhelpful warnings from libvlc with our deprecated APIs */

/** \defgroup libvlc_core LibVLC core
 * \ingroup libvlc
 * Before it can do anything useful, LibVLC must be initialized.
 * You can create one (or more) instance(s) of LibVLC in a given process,
 * with libvlc_new() and destroy them with libvlc_release().
 *
 * \version Unless otherwise stated, these functions are available
 * from LibVLC versions numbered 1.1.0 or more.
 * Earlier versions (0.9.x and 1.0.x) are <b>not</b> compatible.
 * @{
 */

/** This structure is opaque. It represents a libvlc instance */
struct libvlc_instance_t;

alias libvlc_time_t = c_long;

/** \defgroup libvlc_error LibVLC error handling
 * @{
 */

/**
 * A human-readable error message for the last LibVLC error in the calling
 * thread. The resulting string is valid until another error occurs (at least
 * until the next LibVLC call).
 *
 * @warning
 * This will be NULL if there was no error.
 */
const(char)* libvlc_errmsg ();

/**
 * Clears the LibVLC error status for the current thread. This is optional.
 * By default, the error status is automatically overridden when a new error
 * occurs, and destroyed when the thread exits.
 */
void libvlc_clearerr ();

/**
 * Sets the LibVLC error status and message for the current thread.
 * Any previous error is overridden.
 * \param fmt the format string
 * \param ap the arguments
 * \return a nul terminated string in any case
 */
const(char)* libvlc_vprinterr (const(char)* fmt, ...);

/**
 * Sets the LibVLC error status and message for the current thread.
 * Any previous error is overridden.
 * \param fmt the format string
 * \param args the arguments
 * \return a nul terminated string in any case
 */
const(char)* libvlc_printerr (const(char)* fmt, ...);

/**@} */

/**
 * Create and initialize a libvlc instance.
 * This functions accept a list of "command line" arguments similar to the
 * main(). These arguments affect the LibVLC instance default configuration.
 *
 * \note
 * LibVLC may create threads. Therefore, any thread-unsafe process
 * initialization must be performed before calling libvlc_new(). In particular
 * and where applicable:
 * - setlocale() and textdomain(),
 * - setenv(), unsetenv() and putenv(),
 * - with the X11 display system, XInitThreads()
 *   (see also libvlc_media_player_set_xwindow()) and
 * - on Microsoft Windows, SetErrorMode().
 * - sigprocmask() shall never be invoked; pthread_sigmask() can be used.
 *
 * On POSIX systems, the SIGCHLD signal <b>must not</b> be ignored, i.e. the
 * signal handler must set to SIG_DFL or a function pointer, not SIG_IGN.
 * Also while LibVLC is active, the wait() function shall not be called, and
 * any call to waitpid() shall use a strictly positive value for the first
 * parameter (i.e. the PID). Failure to follow those rules may lead to a
 * deadlock or a busy loop.
 * Also on POSIX systems, it is recommended that the SIGPIPE signal be blocked,
 * even if it is not, in principles, necessary, e.g.:
 * @code
   sigset_t set;

   signal(SIGCHLD, SIG_DFL);
   sigemptyset(&set);
   sigaddset(&set, SIGPIPE);
   pthread_sigmask(SIG_BLOCK, &set, NULL);
 * @endcode
 *
 * On Microsoft Windows Vista/2008, the process error mode
 * SEM_FAILCRITICALERRORS flag <b>must</b> be set before using LibVLC.
 * On later versions, that is optional and unnecessary.
 * Also on Microsoft Windows (Vista and any later version), setting the default
 * DLL directories to SYSTEM32 exclusively is strongly recommended for
 * security reasons:
 * @code
   SetErrorMode(SEM_FAILCRITICALERRORS);
   SetDefaultDllDirectories(LOAD_LIBRARY_SEARCH_SYSTEM32);
 * @endcode
 *
 * \version
 * Arguments are meant to be passed from the command line to LibVLC, just like
 * VLC media player does. The list of valid arguments depends on the LibVLC
 * version, the operating system and platform, and set of available LibVLC
 * plugins. Invalid or unsupported arguments will cause the function to fail
 * (i.e. return NULL). Also, some arguments may alter the behaviour or
 * otherwise interfere with other LibVLC functions.
 *
 * \warning
 * There is absolutely no warranty or promise of forward, backward and
 * cross-platform compatibility with regards to libvlc_new() arguments.
 * We recommend that you do not use them, other than when debugging.
 *
 * \param argc the number of arguments (should be 0)
 * \param argv list of arguments (should be NULL)
 * \return the libvlc instance or NULL in case of error
 */
libvlc_instance_t* libvlc_new (int argc, const(char*)* argv);

/**
 * Decrement the reference count of a libvlc instance, and destroy it
 * if it reaches zero.
 *
 * \param p_instance the instance to destroy
 */
void libvlc_release (libvlc_instance_t* p_instance);

/**
 * Increments the reference count of a libvlc instance.
 * The initial reference count is 1 after libvlc_new() returns.
 *
 * \param p_instance the instance to reference
 */
void libvlc_retain (libvlc_instance_t* p_instance);

/**
 * Try to start a user interface for the libvlc instance.
 *
 * \param p_instance the instance
 * \param name interface name, or NULL for default
 * \return 0 on success, -1 on error.
 */
int libvlc_add_intf (libvlc_instance_t* p_instance, const(char)* name);

/**
 * Registers a callback for the LibVLC exit event. This is mostly useful if
 * the VLC playlist and/or at least one interface are started with
 * libvlc_playlist_play() or libvlc_add_intf() respectively.
 * Typically, this function will wake up your application main loop (from
 * another thread).
 *
 * \note This function should be called before the playlist or interface are
 * started. Otherwise, there is a small race condition: the exit event could
 * be raised before the handler is registered.
 *
 * \param p_instance LibVLC instance
 * \param cb callback to invoke when LibVLC wants to exit,
 *           or NULL to disable the exit handler (as by default)
 * \param opaque data pointer for the callback
 * \warning This function and libvlc_wait() cannot be used at the same time.
 */
void libvlc_set_exit_handler (
    libvlc_instance_t* p_instance,
    void function (void*) cb,
    void* opaque);

/**
 * Sets the application name. LibVLC passes this as the user agent string
 * when a protocol requires it.
 *
 * \param p_instance LibVLC instance
 * \param name human-readable application name, e.g. "FooBar player 1.2.3"
 * \param http HTTP User Agent, e.g. "FooBar/1.2.3 Python/2.6.0"
 * \version LibVLC 1.1.1 or later
 */
void libvlc_set_user_agent (
    libvlc_instance_t* p_instance,
    const(char)* name,
    const(char)* http);

/**
 * Sets some meta-information about the application.
 * See also libvlc_set_user_agent().
 *
 * \param p_instance LibVLC instance
 * \param id Java-style application identifier, e.g. "com.acme.foobar"
 * \param version application version numbers, e.g. "1.2.3"
 * \param icon application icon name, e.g. "foobar"
 * \version LibVLC 2.1.0 or later.
 */
void libvlc_set_app_id (
    libvlc_instance_t* p_instance,
    const(char)* id,
    const(char)* version_,
    const(char)* icon);

/**
 * Retrieve libvlc version.
 *
 * Example: "1.1.0-git The Luggage"
 *
 * \return a string containing the libvlc version
 */
const(char)* libvlc_get_version ();

/**
 * Retrieve libvlc compiler version.
 *
 * Example: "gcc version 4.2.3 (Ubuntu 4.2.3-2ubuntu6)"
 *
 * \return a string containing the libvlc compiler version
 */
const(char)* libvlc_get_compiler ();

/**
 * Retrieve libvlc changeset.
 *
 * Example: "aa9bce0bc4"
 *
 * \return a string containing the libvlc changeset
 */
const(char)* libvlc_get_changeset ();

/**
 * Frees an heap allocation returned by a LibVLC function.
 * If you know you're using the same underlying C run-time as the LibVLC
 * implementation, then you can call ANSI C free() directly instead.
 *
 * \param ptr the pointer
 */
void libvlc_free (void* ptr);

/** \defgroup libvlc_event LibVLC asynchronous events
 * LibVLC emits asynchronous events.
 *
 * Several LibVLC objects (such @ref libvlc_instance_t as
 * @ref libvlc_media_player_t) generate events asynchronously. Each of them
 * provides @ref libvlc_event_manager_t event manager. You can subscribe to
 * events with libvlc_event_attach() and unsubscribe with
 * libvlc_event_detach().
 * @{
 */

/**
 * Event manager that belongs to a libvlc object, and from whom events can
 * be received.
 */
struct libvlc_event_manager_t;

/**
 * Type of a LibVLC event.
 */
alias libvlc_event_type_t = int;

/**
 * Callback function notification
 * \param p_event the event triggering the callback
 */
alias libvlc_callback_t = void function (const(libvlc_event_t)* p_event, void* p_data);

/**
 * Register for an event notification.
 *
 * \param p_event_manager the event manager to which you want to attach to.
 *        Generally it is obtained by vlc_my_object_event_manager() where
 *        my_object is the object you want to listen to.
 * \param i_event_type the desired event to which we want to listen
 * \param f_callback the function to call when i_event_type occurs
 * \param user_data user provided data to carry with the event
 * \return 0 on success, ENOMEM on error
 */
int libvlc_event_attach (
    libvlc_event_manager_t* p_event_manager,
    libvlc_event_type_t i_event_type,
    libvlc_callback_t f_callback,
    void* user_data);

/**
 * Unregister an event notification.
 *
 * \param p_event_manager the event manager
 * \param i_event_type the desired event to which we want to unregister
 * \param f_callback the function to call when i_event_type occurs
 * \param p_user_data user provided data to carry with the event
 */
void libvlc_event_detach (
    libvlc_event_manager_t* p_event_manager,
    libvlc_event_type_t i_event_type,
    libvlc_callback_t f_callback,
    void* p_user_data);

/**
 * Get an event's type name.
 *
 * \param event_type the desired event
 */
const(char)* libvlc_event_type_name (libvlc_event_type_t event_type);

/** @} */

/** \defgroup libvlc_log LibVLC logging
 * libvlc_log_* functions provide access to the LibVLC messages log.
 * This is used for logging and debugging.
 * @{
 */

/**
 * Logging messages level.
 * \note Future LibVLC versions may define new levels.
 */
enum libvlc_log_level
{
    LIBVLC_DEBUG = 0, /**< Debug message */
    LIBVLC_NOTICE = 2, /**< Important informational message */
    LIBVLC_WARNING = 3, /**< Warning (potential error) message */
    LIBVLC_ERROR = 4 /**< Error message */
}

struct vlc_log_t;
alias libvlc_log_t = vlc_log_t;

/**
 * Gets log message debug infos.
 *
 * This function retrieves self-debug information about a log message:
 * - the name of the VLC module emitting the message,
 * - the name of the source code module (i.e. file) and
 * - the line number within the source code module.
 *
 * The returned module name and file name will be NULL if unknown.
 * The returned line number will similarly be zero if unknown.
 *
 * \param ctx message context (as passed to the @ref libvlc_log_cb callback)
 * \param module module name storage (or NULL) [OUT]
 * \param file source code file name storage (or NULL) [OUT]
 * \param line source code file line number storage (or NULL) [OUT]
 * \warning The returned module name and source code file name, if non-NULL,
 * are only valid until the logging callback returns.
 *
 * \version LibVLC 2.1.0 or later
 */
void libvlc_log_get_context (
    const(libvlc_log_t)* ctx,
    const(char*)* module_,
    const(char*)* file,
    uint* line);

/**
 * Gets log message info.
 *
 * This function retrieves meta-information about a log message:
 * - the type name of the VLC object emitting the message,
 * - the object header if any, and
 * - a temporaly-unique object identifier.
 *
 * This information is mainly meant for <b>manual</b> troubleshooting.
 *
 * The returned type name may be "generic" if unknown, but it cannot be NULL.
 * The returned header will be NULL if unset; in current versions, the header
 * is used to distinguish for VLM inputs.
 * The returned object ID will be zero if the message is not associated with
 * any VLC object.
 *
 * \param ctx message context (as passed to the @ref libvlc_log_cb callback)
 * \param name object name storage (or NULL) [OUT]
 * \param header object header (or NULL) [OUT]
 * \param line source code file line number storage (or NULL) [OUT]
 * \warning The returned module name and source code file name, if non-NULL,
 * are only valid until the logging callback returns.
 *
 * \version LibVLC 2.1.0 or later
 */
void libvlc_log_get_object (
    const(libvlc_log_t)* ctx,
    const(char*)* name,
    const(char*)* header,
    uintptr_t* id);

/**
 * Callback prototype for LibVLC log message handler.
 *
 * \param data data pointer as given to libvlc_log_set()
 * \param level message level (@ref libvlc_log_level)
 * \param ctx message context (meta-information about the message)
 * \param fmt printf() format string (as defined by ISO C11)
 * \param args variable argument list for the format
 * \note Log message handlers <b>must</b> be thread-safe.
 * \warning The message context pointer, the format string parameters and the
 *          variable arguments are only valid until the callback returns.
 */
alias libvlc_log_cb = void function (
    void* data,
    int level,
    const(libvlc_log_t)* ctx,
    const(char)* fmt,
    ...);

/**
 * Unsets the logging callback.
 *
 * This function deregisters the logging callback for a LibVLC instance.
 * This is rarely needed as the callback is implicitly unset when the instance
 * is destroyed.
 *
 * \note This function will wait for any pending callbacks invocation to
 * complete (causing a deadlock if called from within the callback).
 *
 * \param p_instance libvlc instance
 * \version LibVLC 2.1.0 or later
 */
void libvlc_log_unset (libvlc_instance_t* p_instance);

/**
 * Sets the logging callback for a LibVLC instance.
 *
 * This function is thread-safe: it will wait for any pending callbacks
 * invocation to complete.
 *
 * \param cb callback function pointer
 * \param data opaque data pointer for the callback function
 *
 * \note Some log messages (especially debug) are emitted by LibVLC while
 * is being initialized. These messages cannot be captured with this interface.
 *
 * \warning A deadlock may occur if this function is called from the callback.
 *
 * \param p_instance libvlc instance
 * \version LibVLC 2.1.0 or later
 */
void libvlc_log_set (
    libvlc_instance_t* p_instance,
    libvlc_log_cb cb,
    void* data);

/**
 * Sets up logging to a file.
 * \param p_instance libvlc instance
 * \param stream FILE pointer opened for writing
 *         (the FILE pointer must remain valid until libvlc_log_unset())
 * \version LibVLC 2.1.0 or later
 */
void libvlc_log_set_file (libvlc_instance_t* p_instance, FILE* stream);

/** @} */

/**
 * Description of a module.
 */
struct libvlc_module_description_t
{
    char* psz_name;
    char* psz_shortname;
    char* psz_longname;
    char* psz_help;
    libvlc_module_description_t* p_next;
}

/**
 * Release a list of module descriptions.
 *
 * \param p_list the list to be released
 */
void libvlc_module_description_list_release (
    libvlc_module_description_t* p_list);

/**
 * Returns a list of audio filters that are available.
 *
 * \param p_instance libvlc instance
 *
 * \return a list of module descriptions. It should be freed with libvlc_module_description_list_release().
 *         In case of an error, NULL is returned.
 *
 * \see libvlc_module_description_t
 * \see libvlc_module_description_list_release
 */
libvlc_module_description_t* libvlc_audio_filter_list_get (
    libvlc_instance_t* p_instance);

/**
 * Returns a list of video filters that are available.
 *
 * \param p_instance libvlc instance
 *
 * \return a list of module descriptions. It should be freed with libvlc_module_description_list_release().
 *         In case of an error, NULL is returned.
 *
 * \see libvlc_module_description_t
 * \see libvlc_module_description_list_release
 */
libvlc_module_description_t* libvlc_video_filter_list_get (
    libvlc_instance_t* p_instance);

/** @} */

/** \defgroup libvlc_clock LibVLC time
 * These functions provide access to the LibVLC time/clock.
 * @{
 */

/**
 * Return the current time as defined by LibVLC. The unit is the microsecond.
 * Time increases monotonically (regardless of time zone changes and RTC
 * adjustements).
 * The origin is arbitrary but consistent across the whole system
 * (e.g. the system uptim, the time since the system was booted).
 * \note On systems that support it, the POSIX monotonic clock is used.
 */
long libvlc_clock ();

/**
 * Return the delay (in microseconds) until a certain timestamp.
 * \param pts timestamp
 * \return negative if timestamp is in the past,
 * positive if it is in the future
 */
long libvlc_delay (long pts);

/** @} */

/** @} */
/*****************************************************************************
 * libvlc_renderer_discoverer.h:  libvlc external API
 *****************************************************************************
 * Copyright © 2016 VLC authors and VideoLAN
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

enum VLC_LIBVLC_RENDERER_DISCOVERER_H = 1;

/**
 * @defgroup libvlc_renderer_discoverer LibVLC renderer discoverer
 * @ingroup libvlc
 * LibVLC renderer discoverer finds available renderers available on the local
 * network
 * @{
 * @file
 * LibVLC renderer discoverer external API
 */

struct libvlc_renderer_discoverer_t;

/**
 * Renderer discoverer description
 *
 * \see libvlc_renderer_discoverer_list_get()
 */
struct libvlc_rd_description_t
{
    char* psz_name;
    char* psz_longname;
}

/** The renderer can render audio */
enum LIBVLC_RENDERER_CAN_AUDIO = 0x0001;
/** The renderer can render video */
enum LIBVLC_RENDERER_CAN_VIDEO = 0x0002;

/**
 * Renderer item
 *
 * This struct is passed by a @ref libvlc_event_t when a new renderer is added
 * or deleted.
 *
 * An item is valid until the @ref libvlc_RendererDiscovererItemDeleted event
 * is called with the same pointer.
 *
 * \see libvlc_renderer_discoverer_event_manager()
 */
struct libvlc_renderer_item_t;

/**
 * Hold a renderer item, i.e. creates a new reference
 *
 * This functions need to called from the libvlc_RendererDiscovererItemAdded
 * callback if the libvlc user wants to use this item after. (for display or
 * for passing it to the mediaplayer for example).
 *
 * \version LibVLC 3.0.0 or later
 *
 * \return the current item
 */
libvlc_renderer_item_t* libvlc_renderer_item_hold (
    libvlc_renderer_item_t* p_item);

/**
 * Releases a renderer item, i.e. decrements its reference counter
 *
 * \version LibVLC 3.0.0 or later
 */
void libvlc_renderer_item_release (libvlc_renderer_item_t* p_item);

/**
 * Get the human readable name of a renderer item
 *
 * \version LibVLC 3.0.0 or later
 *
 * \return the name of the item (can't be NULL, must *not* be freed)
 */
const(char)* libvlc_renderer_item_name (const(libvlc_renderer_item_t)* p_item);

/**
 * Get the type (not translated) of a renderer item. For now, the type can only
 * be "chromecast" ("upnp", "airplay" may come later).
 *
 * \version LibVLC 3.0.0 or later
 *
 * \return the type of the item (can't be NULL, must *not* be freed)
 */
const(char)* libvlc_renderer_item_type (const(libvlc_renderer_item_t)* p_item);

/**
 * Get the icon uri of a renderer item
 *
 * \version LibVLC 3.0.0 or later
 *
 * \return the uri of the item's icon (can be NULL, must *not* be freed)
 */
const(char)* libvlc_renderer_item_icon_uri (
    const(libvlc_renderer_item_t)* p_item);

/**
 * Get the flags of a renderer item
 *
 * \see LIBVLC_RENDERER_CAN_AUDIO
 * \see LIBVLC_RENDERER_CAN_VIDEO
 *
 * \version LibVLC 3.0.0 or later
 *
 * \return bitwise flag: capabilities of the renderer, see
 */
int libvlc_renderer_item_flags (const(libvlc_renderer_item_t)* p_item);

/**
 * Create a renderer discoverer object by name
 *
 * After this object is created, you should attach to events in order to be
 * notified of the discoverer events.
 *
 * You need to call libvlc_renderer_discoverer_start() in order to start the
 * discovery.
 *
 * \see libvlc_renderer_discoverer_event_manager()
 * \see libvlc_renderer_discoverer_start()
 *
 * \version LibVLC 3.0.0 or later
 *
 * \param p_inst libvlc instance
 * \param psz_name service name; use libvlc_renderer_discoverer_list_get() to
 * get a list of the discoverer names available in this libVLC instance
 * \return media discover object or NULL in case of error
 */
libvlc_renderer_discoverer_t* libvlc_renderer_discoverer_new (
    libvlc_instance_t* p_inst,
    const(char)* psz_name);

/**
 * Release a renderer discoverer object
 *
 * \version LibVLC 3.0.0 or later
 *
 * \param p_rd renderer discoverer object
 */
void libvlc_renderer_discoverer_release (libvlc_renderer_discoverer_t* p_rd);

/**
 * Start renderer discovery
 *
 * To stop it, call libvlc_renderer_discoverer_stop() or
 * libvlc_renderer_discoverer_release() directly.
 *
 * \see libvlc_renderer_discoverer_stop()
 *
 * \version LibVLC 3.0.0 or later
 *
 * \param p_rd renderer discoverer object
 * \return -1 in case of error, 0 otherwise
 */
int libvlc_renderer_discoverer_start (libvlc_renderer_discoverer_t* p_rd);

/**
 * Stop renderer discovery.
 *
 * \see libvlc_renderer_discoverer_start()
 *
 * \version LibVLC 3.0.0 or later
 *
 * \param p_rd renderer discoverer object
 */
void libvlc_renderer_discoverer_stop (libvlc_renderer_discoverer_t* p_rd);

/**
 * Get the event manager of the renderer discoverer
 *
 * The possible events to attach are @ref libvlc_RendererDiscovererItemAdded
 * and @ref libvlc_RendererDiscovererItemDeleted.
 *
 * The @ref libvlc_renderer_item_t struct passed to event callbacks is owned by
 * VLC, users should take care of holding/releasing this struct for their
 * internal usage.
 *
 * \see libvlc_event_t.u.renderer_discoverer_item_added.item
 * \see libvlc_event_t.u.renderer_discoverer_item_removed.item
 *
 * \version LibVLC 3.0.0 or later
 *
 * \return a valid event manager (can't fail)
 */
libvlc_event_manager_t* libvlc_renderer_discoverer_event_manager (
    libvlc_renderer_discoverer_t* p_rd);

/**
 * Get media discoverer services
 *
 * \see libvlc_renderer_list_release()
 *
 * \version LibVLC 3.0.0 and later
 *
 * \param p_inst libvlc instance
 * \param ppp_services address to store an allocated array of renderer
 * discoverer services (must be freed with libvlc_renderer_list_release() by
 * the caller) [OUT]
 *
 * \return the number of media discoverer services (0 on error)
 */
size_t libvlc_renderer_discoverer_list_get (
    libvlc_instance_t* p_inst,
    libvlc_rd_description_t*** ppp_services);

/**
 * Release an array of media discoverer services
 *
 * \see libvlc_renderer_discoverer_list_get()
 *
 * \version LibVLC 3.0.0 and later
 *
 * \param pp_services array to release
 * \param i_count number of elements in the array
 */
void libvlc_renderer_discoverer_list_release (
    libvlc_rd_description_t** pp_services,
    size_t i_count);

/** @} */

/*****************************************************************************
 * libvlc_media.h:  libvlc external API
 *****************************************************************************
 * Copyright (C) 1998-2009 VLC authors and VideoLAN
 * $Id: 383f366b6940f7b3d89f5945e015793833ea541f $
 *
 * Authors: Clément Stenac <zorglub@videolan.org>
 *          Jean-Paul Saman <jpsaman@videolan.org>
 *          Pierre d'Herbemont <pdherbemont@videolan.org>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

enum VLC_LIBVLC_MEDIA_H = 1;

/** \defgroup libvlc_media LibVLC media
 * \ingroup libvlc
 * @ref libvlc_media_t is an abstract representation of a playable media.
 * It consists of a media location and various optional meta data.
 * @{
 * \file
 * LibVLC media item/descriptor external API
 */

struct libvlc_media_t;

/** Meta data types */
enum libvlc_meta_t
{
    libvlc_meta_Title = 0,
    libvlc_meta_Artist = 1,
    libvlc_meta_Genre = 2,
    libvlc_meta_Copyright = 3,
    libvlc_meta_Album = 4,
    libvlc_meta_TrackNumber = 5,
    libvlc_meta_Description = 6,
    libvlc_meta_Rating = 7,
    libvlc_meta_Date = 8,
    libvlc_meta_Setting = 9,
    libvlc_meta_URL = 10,
    libvlc_meta_Language = 11,
    libvlc_meta_NowPlaying = 12,
    libvlc_meta_Publisher = 13,
    libvlc_meta_EncodedBy = 14,
    libvlc_meta_ArtworkURL = 15,
    libvlc_meta_TrackID = 16,
    libvlc_meta_TrackTotal = 17,
    libvlc_meta_Director = 18,
    libvlc_meta_Season = 19,
    libvlc_meta_Episode = 20,
    libvlc_meta_ShowName = 21,
    libvlc_meta_Actors = 22,
    libvlc_meta_AlbumArtist = 23,
    libvlc_meta_DiscNumber = 24,
    libvlc_meta_DiscTotal = 25
    /* Add new meta types HERE */
}

/**
 * Note the order of libvlc_state_t enum must match exactly the order of
 * \see mediacontrol_PlayerStatus, \see input_state_e enums,
 * and VideoLAN.LibVLC.State (at bindings/cil/src/media.cs).
 *
 * Expected states by web plugins are:
 * IDLE/CLOSE=0, OPENING=1, PLAYING=3, PAUSED=4,
 * STOPPING=5, ENDED=6, ERROR=7
 */
enum libvlc_state_t
{
    libvlc_NothingSpecial = 0,
    libvlc_Opening = 1,
    libvlc_Buffering = 2, /* XXX: Deprecated value. Check the
     * libvlc_MediaPlayerBuffering event to know the
     * buffering state of a libvlc_media_player */
    libvlc_Playing = 3,
    libvlc_Paused = 4,
    libvlc_Stopped = 5,
    libvlc_Ended = 6,
    libvlc_Error = 7
}

enum
{
    libvlc_media_option_trusted = 2,
    libvlc_media_option_unique = 256
}

enum libvlc_track_type_t
{
    libvlc_track_unknown = -1,
    libvlc_track_audio = 0,
    libvlc_track_video = 1,
    libvlc_track_text = 2
}

struct libvlc_media_stats_t
{
    /* Input */
    int i_read_bytes;
    float f_input_bitrate;

    /* Demux */
    int i_demux_read_bytes;
    float f_demux_bitrate;
    int i_demux_corrupted;
    int i_demux_discontinuity;

    /* Decoders */
    int i_decoded_video;
    int i_decoded_audio;

    /* Video Output */
    int i_displayed_pictures;
    int i_lost_pictures;

    /* Audio output */
    int i_played_abuffers;
    int i_lost_abuffers;

    /* Stream output */
    int i_sent_packets;
    int i_sent_bytes;
    float f_send_bitrate;
}

struct libvlc_media_track_info_t
{
    /* Codec fourcc */
    uint i_codec;
    int i_id;
    libvlc_track_type_t i_type;

    /* Codec specific */
    int i_profile;
    int i_level;

    /* Audio specific */

    /* Video specific */
    union _Anonymous_0
    {
        struct _Anonymous_1
        {
            uint i_channels;
            uint i_rate;
        }

        _Anonymous_1 audio;

        struct _Anonymous_2
        {
            uint i_height;
            uint i_width;
        }

        _Anonymous_2 video;
    }

    _Anonymous_0 u;
}

struct libvlc_audio_track_t
{
    uint i_channels;
    uint i_rate;
}

enum libvlc_video_orient_t
{
    libvlc_video_orient_top_left = 0, /**< Normal. Top line represents top, left column left. */
    libvlc_video_orient_top_right = 1, /**< Flipped horizontally */
    libvlc_video_orient_bottom_left = 2, /**< Flipped vertically */
    libvlc_video_orient_bottom_right = 3, /**< Rotated 180 degrees */
    libvlc_video_orient_left_top = 4, /**< Transposed */
    libvlc_video_orient_left_bottom = 5, /**< Rotated 90 degrees clockwise (or 270 anti-clockwise) */
    libvlc_video_orient_right_top = 6, /**< Rotated 90 degrees anti-clockwise */
    libvlc_video_orient_right_bottom = 7 /**< Anti-transposed */
}

enum libvlc_video_projection_t
{
    libvlc_video_projection_rectangular = 0,
    libvlc_video_projection_equirectangular = 1, /**< 360 spherical */

    libvlc_video_projection_cubemap_layout_standard = 256
}

/**
 * Viewpoint
 *
 * \warning allocate using libvlc_video_new_viewpoint()
 */
struct libvlc_video_viewpoint_t
{
    float f_yaw; /**< view point yaw in degrees  ]-180;180] */
    float f_pitch; /**< view point pitch in degrees  ]-90;90] */
    float f_roll; /**< view point roll in degrees ]-180;180] */
    float f_field_of_view; /**< field of view in degrees ]0;180[ (default 80.)*/
}

struct libvlc_video_track_t
{
    uint i_height;
    uint i_width;
    uint i_sar_num;
    uint i_sar_den;
    uint i_frame_rate_num;
    uint i_frame_rate_den;

    libvlc_video_orient_t i_orientation;
    libvlc_video_projection_t i_projection;
    libvlc_video_viewpoint_t pose; /**< Initial view point */
}

struct libvlc_subtitle_track_t
{
    char* psz_encoding;
}

struct libvlc_media_track_t
{
    /* Codec fourcc */
    uint i_codec;
    uint i_original_fourcc;
    int i_id;
    libvlc_track_type_t i_type;

    /* Codec specific */
    int i_profile;
    int i_level;

    union
    {
        libvlc_audio_track_t* audio;
        libvlc_video_track_t* video;
        libvlc_subtitle_track_t* subtitle;
    }

    uint i_bitrate;
    char* psz_language;
    char* psz_description;
}

/**
 * Media type
 *
 * \see libvlc_media_get_type
 */
enum libvlc_media_type_t
{
    libvlc_media_type_unknown = 0,
    libvlc_media_type_file = 1,
    libvlc_media_type_directory = 2,
    libvlc_media_type_disc = 3,
    libvlc_media_type_stream = 4,
    libvlc_media_type_playlist = 5
}

/**
 * Parse flags used by libvlc_media_parse_with_options()
 *
 * \see libvlc_media_parse_with_options
 */
enum libvlc_media_parse_flag_t
{
    /**
     * Parse media if it's a local file
     */
    libvlc_media_parse_local = 0,
    /**
     * Parse media even if it's a network file
     */
    libvlc_media_parse_network = 1,
    /**
     * Fetch meta and covert art using local resources
     */
    libvlc_media_fetch_local = 2,
    /**
     * Fetch meta and covert art using network resources
     */
    libvlc_media_fetch_network = 4,
    /**
     * Interact with the user (via libvlc_dialog_cbs) when preparsing this item
     * (and not its sub items). Set this flag in order to receive a callback
     * when the input is asking for credentials.
     */
    libvlc_media_do_interact = 8
}

/**
 * Parse status used sent by libvlc_media_parse_with_options() or returned by
 * libvlc_media_get_parsed_status()
 *
 * \see libvlc_media_parse_with_options
 * \see libvlc_media_get_parsed_status
 */
enum libvlc_media_parsed_status_t
{
    libvlc_media_parsed_status_skipped = 1,
    libvlc_media_parsed_status_failed = 2,
    libvlc_media_parsed_status_timeout = 3,
    libvlc_media_parsed_status_done = 4
}

/**
 * Type of a media slave: subtitle or audio.
 */
enum libvlc_media_slave_type_t
{
    libvlc_media_slave_type_subtitle = 0,
    libvlc_media_slave_type_audio = 1
}

/**
 * A slave of a libvlc_media_t
 * \see libvlc_media_slaves_get
 */
struct libvlc_media_slave_t
{
    char* psz_uri;
    libvlc_media_slave_type_t i_type;
    uint i_priority;
}

/**
 * Callback prototype to open a custom bitstream input media.
 *
 * The same media item can be opened multiple times. Each time, this callback
 * is invoked. It should allocate and initialize any instance-specific
 * resources, then store them in *datap. The instance resources can be freed
 * in the @ref libvlc_media_close_cb callback.
 *
 * \param opaque private pointer as passed to libvlc_media_new_callbacks()
 * \param datap storage space for a private data pointer [OUT]
 * \param sizep byte length of the bitstream or UINT64_MAX if unknown [OUT]
 *
 * \note For convenience, *datap is initially NULL and *sizep is initially 0.
 *
 * \return 0 on success, non-zero on error. In case of failure, the other
 * callbacks will not be invoked and any value stored in *datap and *sizep is
 * discarded.
 */
alias libvlc_media_open_cb = int function (
    void* opaque,
    void** datap,
    ulong* sizep);

/**
 * Callback prototype to read data from a custom bitstream input media.
 *
 * \param opaque private pointer as set by the @ref libvlc_media_open_cb
 *               callback
 * \param buf start address of the buffer to read data into
 * \param len bytes length of the buffer
 *
 * \return strictly positive number of bytes read, 0 on end-of-stream,
 *         or -1 on non-recoverable error
 *
 * \note If no data is immediately available, then the callback should sleep.
 * \warning The application is responsible for avoiding deadlock situations.
 * In particular, the callback should return an error if playback is stopped;
 * if it does not return, then libvlc_media_player_stop() will never return.
 */
alias libvlc_media_read_cb = c_long function (
    void* opaque,
    ubyte* buf,
    size_t len);

/**
 * Callback prototype to seek a custom bitstream input media.
 *
 * \param opaque private pointer as set by the @ref libvlc_media_open_cb
 *               callback
 * \param offset absolute byte offset to seek to
 * \return 0 on success, -1 on error.
 */
alias libvlc_media_seek_cb = int function (void* opaque, ulong offset);

/**
 * Callback prototype to close a custom bitstream input media.
 *
 * \param opaque private pointer as set by the @ref libvlc_media_open_cb
 *               callback
 */
alias libvlc_media_close_cb = void function (void* opaque);

/**
 * Create a media with a certain given media resource location,
 * for instance a valid URL.
 *
 * \note To refer to a local file with this function,
 * the file://... URI syntax <b>must</b> be used (see IETF RFC3986).
 * We recommend using libvlc_media_new_path() instead when dealing with
 * local files.
 *
 * \see libvlc_media_release
 *
 * \param p_instance the instance
 * \param psz_mrl the media location
 * \return the newly created media or NULL on error
 */
libvlc_media_t* libvlc_media_new_location (
    libvlc_instance_t* p_instance,
    const(char)* psz_mrl);

/**
 * Create a media for a certain file path.
 *
 * \see libvlc_media_release
 *
 * \param p_instance the instance
 * \param path local filesystem path
 * \return the newly created media or NULL on error
 */
libvlc_media_t* libvlc_media_new_path (
    libvlc_instance_t* p_instance,
    const(char)* path);

/**
 * Create a media for an already open file descriptor.
 * The file descriptor shall be open for reading (or reading and writing).
 *
 * Regular file descriptors, pipe read descriptors and character device
 * descriptors (including TTYs) are supported on all platforms.
 * Block device descriptors are supported where available.
 * Directory descriptors are supported on systems that provide fdopendir().
 * Sockets are supported on all platforms where they are file descriptors,
 * i.e. all except Windows.
 *
 * \note This library will <b>not</b> automatically close the file descriptor
 * under any circumstance. Nevertheless, a file descriptor can usually only be
 * rendered once in a media player. To render it a second time, the file
 * descriptor should probably be rewound to the beginning with lseek().
 *
 * \see libvlc_media_release
 *
 * \version LibVLC 1.1.5 and later.
 *
 * \param p_instance the instance
 * \param fd open file descriptor
 * \return the newly created media or NULL on error
 */
libvlc_media_t* libvlc_media_new_fd (libvlc_instance_t* p_instance, int fd);

/**
 * Create a media with custom callbacks to read the data from.
 *
 * \param instance LibVLC instance
 * \param open_cb callback to open the custom bitstream input media
 * \param read_cb callback to read data (must not be NULL)
 * \param seek_cb callback to seek, or NULL if seeking is not supported
 * \param close_cb callback to close the media, or NULL if unnecessary
 * \param opaque data pointer for the open callback
 *
 * \return the newly created media or NULL on error
 *
 * \note If open_cb is NULL, the opaque pointer will be passed to read_cb,
 * seek_cb and close_cb, and the stream size will be treated as unknown.
 *
 * \note The callbacks may be called asynchronously (from another thread).
 * A single stream instance need not be reentrant. However the open_cb needs to
 * be reentrant if the media is used by multiple player instances.
 *
 * \warning The callbacks may be used until all or any player instances
 * that were supplied the media item are stopped.
 *
 * \see libvlc_media_release
 *
 * \version LibVLC 3.0.0 and later.
 */
libvlc_media_t* libvlc_media_new_callbacks (
    libvlc_instance_t* instance,
    libvlc_media_open_cb open_cb,
    libvlc_media_read_cb read_cb,
    libvlc_media_seek_cb seek_cb,
    libvlc_media_close_cb close_cb,
    void* opaque);

/**
 * Create a media as an empty node with a given name.
 *
 * \see libvlc_media_release
 *
 * \param p_instance the instance
 * \param psz_name the name of the node
 * \return the new empty media or NULL on error
 */
libvlc_media_t* libvlc_media_new_as_node (
    libvlc_instance_t* p_instance,
    const(char)* psz_name);

/**
 * Add an option to the media.
 *
 * This option will be used to determine how the media_player will
 * read the media. This allows to use VLC's advanced
 * reading/streaming options on a per-media basis.
 *
 * \note The options are listed in 'vlc --long-help' from the command line,
 * e.g. "-sout-all". Keep in mind that available options and their semantics
 * vary across LibVLC versions and builds.
 * \warning Not all options affects libvlc_media_t objects:
 * Specifically, due to architectural issues most audio and video options,
 * such as text renderer options, have no effects on an individual media.
 * These options must be set through libvlc_new() instead.
 *
 * \param p_md the media descriptor
 * \param psz_options the options (as a string)
 */
void libvlc_media_add_option (libvlc_media_t* p_md, const(char)* psz_options);

/**
 * Add an option to the media with configurable flags.
 *
 * This option will be used to determine how the media_player will
 * read the media. This allows to use VLC's advanced
 * reading/streaming options on a per-media basis.
 *
 * The options are detailed in vlc --long-help, for instance
 * "--sout-all". Note that all options are not usable on medias:
 * specifically, due to architectural issues, video-related options
 * such as text renderer options cannot be set on a single media. They
 * must be set on the whole libvlc instance instead.
 *
 * \param p_md the media descriptor
 * \param psz_options the options (as a string)
 * \param i_flags the flags for this option
 */
void libvlc_media_add_option_flag (
    libvlc_media_t* p_md,
    const(char)* psz_options,
    uint i_flags);

/**
 * Retain a reference to a media descriptor object (libvlc_media_t). Use
 * libvlc_media_release() to decrement the reference count of a
 * media descriptor object.
 *
 * \param p_md the media descriptor
 */
void libvlc_media_retain (libvlc_media_t* p_md);

/**
 * Decrement the reference count of a media descriptor object. If the
 * reference count is 0, then libvlc_media_release() will release the
 * media descriptor object. It will send out an libvlc_MediaFreed event
 * to all listeners. If the media descriptor object has been released it
 * should not be used again.
 *
 * \param p_md the media descriptor
 */
void libvlc_media_release (libvlc_media_t* p_md);

/**
 * Get the media resource locator (mrl) from a media descriptor object
 *
 * \param p_md a media descriptor object
 * \return string with mrl of media descriptor object
 */
char* libvlc_media_get_mrl (libvlc_media_t* p_md);

/**
 * Duplicate a media descriptor object.
 *
 * \param p_md a media descriptor object.
 */
libvlc_media_t* libvlc_media_duplicate (libvlc_media_t* p_md);

/**
 * Read the meta of the media.
 *
 * If the media has not yet been parsed this will return NULL.
 *
 * \see libvlc_media_parse
 * \see libvlc_media_parse_with_options
 * \see libvlc_MediaMetaChanged
 *
 * \param p_md the media descriptor
 * \param e_meta the meta to read
 * \return the media's meta
 */
char* libvlc_media_get_meta (libvlc_media_t* p_md, libvlc_meta_t e_meta);

/**
 * Set the meta of the media (this function will not save the meta, call
 * libvlc_media_save_meta in order to save the meta)
 *
 * \param p_md the media descriptor
 * \param e_meta the meta to write
 * \param psz_value the media's meta
 */
void libvlc_media_set_meta (
    libvlc_media_t* p_md,
    libvlc_meta_t e_meta,
    const(char)* psz_value);

/**
 * Save the meta previously set
 *
 * \param p_md the media desriptor
 * \return true if the write operation was successful
 */
int libvlc_media_save_meta (libvlc_media_t* p_md);

/**
 * Get current state of media descriptor object. Possible media states are
 * libvlc_NothingSpecial=0, libvlc_Opening, libvlc_Playing, libvlc_Paused,
 * libvlc_Stopped, libvlc_Ended, libvlc_Error.
 *
 * \see libvlc_state_t
 * \param p_md a media descriptor object
 * \return state of media descriptor object
 */
libvlc_state_t libvlc_media_get_state (libvlc_media_t* p_md);

/**
 * Get the current statistics about the media
 * \param p_md: media descriptor object
 * \param p_stats: structure that contain the statistics about the media
 *                 (this structure must be allocated by the caller)
 * \return true if the statistics are available, false otherwise
 *
 * \libvlc_return_bool
 */
int libvlc_media_get_stats (
    libvlc_media_t* p_md,
    libvlc_media_stats_t* p_stats);

/* The following method uses libvlc_media_list_t, however, media_list usage is optionnal
 * and this is here for convenience */

/**
 * Get subitems of media descriptor object. This will increment
 * the reference count of supplied media descriptor object. Use
 * libvlc_media_list_release() to decrement the reference counting.
 *
 * \param p_md media descriptor object
 * \return list of media descriptor subitems or NULL
 */
struct libvlc_media_list_t;
libvlc_media_list_t* libvlc_media_subitems (libvlc_media_t* p_md);

/**
 * Get event manager from media descriptor object.
 * NOTE: this function doesn't increment reference counting.
 *
 * \param p_md a media descriptor object
 * \return event manager object
 */
libvlc_event_manager_t* libvlc_media_event_manager (libvlc_media_t* p_md);

/**
 * Get duration (in ms) of media descriptor object item.
 *
 * \param p_md media descriptor object
 * \return duration of media item or -1 on error
 */
libvlc_time_t libvlc_media_get_duration (libvlc_media_t* p_md);

/**
 * Parse the media asynchronously with options.
 *
 * This fetches (local or network) art, meta data and/or tracks information.
 * This method is the extended version of libvlc_media_parse_with_options().
 *
 * To track when this is over you can listen to libvlc_MediaParsedChanged
 * event. However if this functions returns an error, you will not receive any
 * events.
 *
 * It uses a flag to specify parse options (see libvlc_media_parse_flag_t). All
 * these flags can be combined. By default, media is parsed if it's a local
 * file.
 *
 * \note Parsing can be aborted with libvlc_media_parse_stop().
 *
 * \see libvlc_MediaParsedChanged
 * \see libvlc_media_get_meta
 * \see libvlc_media_tracks_get
 * \see libvlc_media_get_parsed_status
 * \see libvlc_media_parse_flag_t
 *
 * \param p_md media descriptor object
 * \param parse_flag parse options:
 * \param timeout maximum time allowed to preparse the media. If -1, the
 * default "preparse-timeout" option will be used as a timeout. If 0, it will
 * wait indefinitely. If > 0, the timeout will be used (in milliseconds).
 * \return -1 in case of error, 0 otherwise
 * \version LibVLC 3.0.0 or later
 */
int libvlc_media_parse_with_options (
    libvlc_media_t* p_md,
    libvlc_media_parse_flag_t parse_flag,
    int timeout);

/**
 * Stop the parsing of the media
 *
 * When the media parsing is stopped, the libvlc_MediaParsedChanged event will
 * be sent with the libvlc_media_parsed_status_timeout status.
 *
 * \see libvlc_media_parse_with_options
 *
 * \param p_md media descriptor object
 * \version LibVLC 3.0.0 or later
 */
void libvlc_media_parse_stop (libvlc_media_t* p_md);

/**
 * Get Parsed status for media descriptor object.
 *
 * \see libvlc_MediaParsedChanged
 * \see libvlc_media_parsed_status_t
 *
 * \param p_md media descriptor object
 * \return a value of the libvlc_media_parsed_status_t enum
 * \version LibVLC 3.0.0 or later
 */
libvlc_media_parsed_status_t libvlc_media_get_parsed_status (
    libvlc_media_t* p_md);

/**
 * Sets media descriptor's user_data. user_data is specialized data
 * accessed by the host application, VLC.framework uses it as a pointer to
 * an native object that references a libvlc_media_t pointer
 *
 * \param p_md media descriptor object
 * \param p_new_user_data pointer to user data
 */
void libvlc_media_set_user_data (libvlc_media_t* p_md, void* p_new_user_data);

/**
 * Get media descriptor's user_data. user_data is specialized data
 * accessed by the host application, VLC.framework uses it as a pointer to
 * an native object that references a libvlc_media_t pointer
 *
 * \param p_md media descriptor object
 */
void* libvlc_media_get_user_data (libvlc_media_t* p_md);

/**
 * Get media descriptor's elementary streams description
 *
 * Note, you need to call libvlc_media_parse() or play the media at least once
 * before calling this function.
 * Not doing this will result in an empty array.
 *
 * \version LibVLC 2.1.0 and later.
 *
 * \param p_md media descriptor object
 * \param tracks address to store an allocated array of Elementary Streams
 *        descriptions (must be freed with libvlc_media_tracks_release
          by the caller) [OUT]
 *
 * \return the number of Elementary Streams (zero on error)
 */
uint libvlc_media_tracks_get (
    libvlc_media_t* p_md,
    libvlc_media_track_t*** tracks);

/**
 * Get codec description from media elementary stream
 *
 * \version LibVLC 3.0.0 and later.
 *
 * \see libvlc_media_track_t
 *
 * \param i_type i_type from libvlc_media_track_t
 * \param i_codec i_codec or i_original_fourcc from libvlc_media_track_t
 *
 * \return codec description
 */
const(char)* libvlc_media_get_codec_description (
    libvlc_track_type_t i_type,
    uint i_codec);

/**
 * Release media descriptor's elementary streams description array
 *
 * \version LibVLC 2.1.0 and later.
 *
 * \param p_tracks tracks info array to release
 * \param i_count number of elements in the array
 */
void libvlc_media_tracks_release (
    libvlc_media_track_t** p_tracks,
    uint i_count);

/**
 * Get the media type of the media descriptor object
 *
 * \version LibVLC 3.0.0 and later.
 *
 * \see libvlc_media_type_t
 *
 * \param p_md media descriptor object
 *
 * \return media type
 */
libvlc_media_type_t libvlc_media_get_type (libvlc_media_t* p_md);

/**
 * Add a slave to the current media.
 *
 * A slave is an external input source that may contains an additional subtitle
 * track (like a .srt) or an additional audio track (like a .ac3).
 *
 * \note This function must be called before the media is parsed (via
 * libvlc_media_parse_with_options()) or before the media is played (via
 * libvlc_media_player_play())
 *
 * \version LibVLC 3.0.0 and later.
 *
 * \param p_md media descriptor object
 * \param i_type subtitle or audio
 * \param i_priority from 0 (low priority) to 4 (high priority)
 * \param psz_uri Uri of the slave (should contain a valid scheme).
 *
 * \return 0 on success, -1 on error.
 */
int libvlc_media_slaves_add (
    libvlc_media_t* p_md,
    libvlc_media_slave_type_t i_type,
    uint i_priority,
    const(char)* psz_uri);

/**
 * Clear all slaves previously added by libvlc_media_slaves_add() or
 * internally.
 *
 * \version LibVLC 3.0.0 and later.
 *
 * \param p_md media descriptor object
 */
void libvlc_media_slaves_clear (libvlc_media_t* p_md);

/**
 * Get a media descriptor's slave list
 *
 * The list will contain slaves parsed by VLC or previously added by
 * libvlc_media_slaves_add(). The typical use case of this function is to save
 * a list of slave in a database for a later use.
 *
 * \version LibVLC 3.0.0 and later.
 *
 * \see libvlc_media_slaves_add
 *
 * \param p_md media descriptor object
 * \param ppp_slaves address to store an allocated array of slaves (must be
 * freed with libvlc_media_slaves_release()) [OUT]
 *
 * \return the number of slaves (zero on error)
 */
uint libvlc_media_slaves_get (
    libvlc_media_t* p_md,
    libvlc_media_slave_t*** ppp_slaves);

/**
 * Release a media descriptor's slave list
 *
 * \version LibVLC 3.0.0 and later.
 *
 * \param pp_slaves slave array to release
 * \param i_count number of elements in the array
 */
void libvlc_media_slaves_release (
    libvlc_media_slave_t** pp_slaves,
    uint i_count);

/** @}*/

/* VLC_LIBVLC_MEDIA_H */
/*****************************************************************************
 * libvlc_media_player.h:  libvlc_media_player external API
 *****************************************************************************
 * Copyright (C) 1998-2015 VLC authors and VideoLAN
 * $Id: c431c235e92ced9e6e7d7712eb7ff0e73dc4f933 $
 *
 * Authors: Clément Stenac <zorglub@videolan.org>
 *          Jean-Paul Saman <jpsaman@videolan.org>
 *          Pierre d'Herbemont <pdherbemont@videolan.org>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

enum VLC_LIBVLC_MEDIA_PLAYER_H = 1;

/** \defgroup libvlc_media_player LibVLC media player
 * \ingroup libvlc
 * A LibVLC media player plays one media (usually in a custom drawable).
 * @{
 * \file
 * LibVLC simple media player external API
 */

struct libvlc_media_player_t;

/**
 * Description for video, audio tracks and subtitles. It contains
 * id, name (description string) and pointer to next record.
 */
struct libvlc_track_description_t
{
    int i_id;
    char* psz_name;
    libvlc_track_description_t* p_next;
}

/**
 * Description for titles
 */
enum
{
    libvlc_title_menu = 1,
    libvlc_title_interactive = 2
}

struct libvlc_title_description_t
{
    long i_duration; /**< duration in milliseconds */
    char* psz_name; /**< title name */
    uint i_flags; /**< info if item was recognized as a menu, interactive or plain content by the demuxer */
}

/**
 * Description for chapters
 */
struct libvlc_chapter_description_t
{
    long i_time_offset; /**< time-offset of the chapter in milliseconds */
    long i_duration; /**< duration of the chapter in milliseconds */
    char* psz_name; /**< chapter name */
}

/**
 * Description for audio output. It contains
 * name, description and pointer to next record.
 */
struct libvlc_audio_output_t
{
    char* psz_name;
    char* psz_description;
    libvlc_audio_output_t* p_next;
}

/**
 * Description for audio output device.
 */
struct libvlc_audio_output_device_t
{
    libvlc_audio_output_device_t* p_next; /**< Next entry in list */
    char* psz_device; /**< Device identifier string */
    char* psz_description; /**< User-friendly device description */
    /* More fields may be added here in later versions */
}

/**
 * Marq options definition
 */
enum libvlc_video_marquee_option_t
{
    libvlc_marquee_Enable = 0,
    libvlc_marquee_Text = 1, /** string argument */
    libvlc_marquee_Color = 2,
    libvlc_marquee_Opacity = 3,
    libvlc_marquee_Position = 4,
    libvlc_marquee_Refresh = 5,
    libvlc_marquee_Size = 6,
    libvlc_marquee_Timeout = 7,
    libvlc_marquee_X = 8,
    libvlc_marquee_Y = 9
}

/**
 * Navigation mode
 */
enum libvlc_navigate_mode_t
{
    libvlc_navigate_activate = 0,
    libvlc_navigate_up = 1,
    libvlc_navigate_down = 2,
    libvlc_navigate_left = 3,
    libvlc_navigate_right = 4,
    libvlc_navigate_popup = 5
}

/**
 * Enumeration of values used to set position (e.g. of video title).
 */
enum libvlc_position_t
{
    libvlc_position_disable = -1,
    libvlc_position_center = 0,
    libvlc_position_left = 1,
    libvlc_position_right = 2,
    libvlc_position_top = 3,
    libvlc_position_top_left = 4,
    libvlc_position_top_right = 5,
    libvlc_position_bottom = 6,
    libvlc_position_bottom_left = 7,
    libvlc_position_bottom_right = 8
}

/**
 * Enumeration of teletext keys than can be passed via
 * libvlc_video_set_teletext()
 */
enum libvlc_teletext_key_t
{
    libvlc_teletext_key_red = 7471104,
    libvlc_teletext_key_green = 6750208,
    libvlc_teletext_key_yellow = 7929856,
    libvlc_teletext_key_blue = 6422528,
    libvlc_teletext_key_index = 6881280
}

/**
 * Opaque equalizer handle.
 *
 * Equalizer settings can be applied to a media player.
 */
struct libvlc_equalizer_t;

/**
 * Create an empty Media Player object
 *
 * \param p_libvlc_instance the libvlc instance in which the Media Player
 *        should be created.
 * \return a new media player object, or NULL on error.
 */
libvlc_media_player_t* libvlc_media_player_new (libvlc_instance_t* p_libvlc_instance);

/**
 * Create a Media Player object from a Media
 *
 * \param p_md the media. Afterwards the p_md can be safely
 *        destroyed.
 * \return a new media player object, or NULL on error.
 */
libvlc_media_player_t* libvlc_media_player_new_from_media (libvlc_media_t* p_md);

/**
 * Release a media_player after use
 * Decrement the reference count of a media player object. If the
 * reference count is 0, then libvlc_media_player_release() will
 * release the media player object. If the media player object
 * has been released, then it should not be used again.
 *
 * \param p_mi the Media Player to free
 */
void libvlc_media_player_release (libvlc_media_player_t* p_mi);

/**
 * Retain a reference to a media player object. Use
 * libvlc_media_player_release() to decrement reference count.
 *
 * \param p_mi media player object
 */
void libvlc_media_player_retain (libvlc_media_player_t* p_mi);

/**
 * Set the media that will be used by the media_player. If any,
 * previous md will be released.
 *
 * \param p_mi the Media Player
 * \param p_md the Media. Afterwards the p_md can be safely
 *        destroyed.
 */
void libvlc_media_player_set_media (
    libvlc_media_player_t* p_mi,
    libvlc_media_t* p_md);

/**
 * Get the media used by the media_player.
 *
 * \param p_mi the Media Player
 * \return the media associated with p_mi, or NULL if no
 *         media is associated
 */
libvlc_media_t* libvlc_media_player_get_media (libvlc_media_player_t* p_mi);

/**
 * Get the Event Manager from which the media player send event.
 *
 * \param p_mi the Media Player
 * \return the event manager associated with p_mi
 */
libvlc_event_manager_t* libvlc_media_player_event_manager (libvlc_media_player_t* p_mi);

/**
 * is_playing
 *
 * \param p_mi the Media Player
 * \return 1 if the media player is playing, 0 otherwise
 *
 * \libvlc_return_bool
 */
int libvlc_media_player_is_playing (libvlc_media_player_t* p_mi);

/**
 * Play
 *
 * \param p_mi the Media Player
 * \return 0 if playback started (and was already started), or -1 on error.
 */
int libvlc_media_player_play (libvlc_media_player_t* p_mi);

/**
 * Pause or resume (no effect if there is no media)
 *
 * \param mp the Media Player
 * \param do_pause play/resume if zero, pause if non-zero
 * \version LibVLC 1.1.1 or later
 */
void libvlc_media_player_set_pause (libvlc_media_player_t* mp, int do_pause);

/**
 * Toggle pause (no effect if there is no media)
 *
 * \param p_mi the Media Player
 */
void libvlc_media_player_pause (libvlc_media_player_t* p_mi);

/**
 * Stop (no effect if there is no media)
 *
 * \param p_mi the Media Player
 */
void libvlc_media_player_stop (libvlc_media_player_t* p_mi);

/**
 * Set a renderer to the media player
 *
 * \note must be called before the first call of libvlc_media_player_play() to
 * take effect.
 *
 * \see libvlc_renderer_discoverer_new
 *
 * \param p_mi the Media Player
 * \param p_item an item discovered by libvlc_renderer_discoverer_start()
 * \return 0 on success, -1 on error.
 * \version LibVLC 3.0.0 or later
 */
int libvlc_media_player_set_renderer (
    libvlc_media_player_t* p_mi,
    libvlc_renderer_item_t* p_item);

/**
 * Callback prototype to allocate and lock a picture buffer.
 *
 * Whenever a new video frame needs to be decoded, the lock callback is
 * invoked. Depending on the video chroma, one or three pixel planes of
 * adequate dimensions must be returned via the second parameter. Those
 * planes must be aligned on 32-bytes boundaries.
 *
 * \param opaque private pointer as passed to libvlc_video_set_callbacks() [IN]
 * \param planes start address of the pixel planes (LibVLC allocates the array
 *             of void pointers, this callback must initialize the array) [OUT]
 * \return a private pointer for the display and unlock callbacks to identify
 *         the picture buffers
 */
alias libvlc_video_lock_cb = void* function (void* opaque, void** planes);

/**
 * Callback prototype to unlock a picture buffer.
 *
 * When the video frame decoding is complete, the unlock callback is invoked.
 * This callback might not be needed at all. It is only an indication that the
 * application can now read the pixel values if it needs to.
 *
 * \note A picture buffer is unlocked after the picture is decoded,
 * but before the picture is displayed.
 *
 * \param opaque private pointer as passed to libvlc_video_set_callbacks() [IN]
 * \param picture private pointer returned from the @ref libvlc_video_lock_cb
 *                callback [IN]
 * \param planes pixel planes as defined by the @ref libvlc_video_lock_cb
 *               callback (this parameter is only for convenience) [IN]
 */
alias libvlc_video_unlock_cb = void function (
    void* opaque,
    void* picture,
    void** planes);

/**
 * Callback prototype to display a picture.
 *
 * When the video frame needs to be shown, as determined by the media playback
 * clock, the display callback is invoked.
 *
 * \param opaque private pointer as passed to libvlc_video_set_callbacks() [IN]
 * \param picture private pointer returned from the @ref libvlc_video_lock_cb
 *                callback [IN]
 */
alias libvlc_video_display_cb = void function (void* opaque, void* picture);

/**
 * Callback prototype to configure picture buffers format.
 * This callback gets the format of the video as output by the video decoder
 * and the chain of video filters (if any). It can opt to change any parameter
 * as it needs. In that case, LibVLC will attempt to convert the video format
 * (rescaling and chroma conversion) but these operations can be CPU intensive.
 *
 * \param opaque pointer to the private pointer passed to
 *               libvlc_video_set_callbacks() [IN/OUT]
 * \param chroma pointer to the 4 bytes video format identifier [IN/OUT]
 * \param width pointer to the pixel width [IN/OUT]
 * \param height pointer to the pixel height [IN/OUT]
 * \param pitches table of scanline pitches in bytes for each pixel plane
 *                (the table is allocated by LibVLC) [OUT]
 * \param lines table of scanlines count for each plane [OUT]
 * \return the number of picture buffers allocated, 0 indicates failure
 *
 * \note
 * For each pixels plane, the scanline pitch must be bigger than or equal to
 * the number of bytes per pixel multiplied by the pixel width.
 * Similarly, the number of scanlines must be bigger than of equal to
 * the pixel height.
 * Furthermore, we recommend that pitches and lines be multiple of 32
 * to not break assumptions that might be held by optimized code
 * in the video decoders, video filters and/or video converters.
 */
alias libvlc_video_format_cb = uint function (
    void** opaque,
    char* chroma,
    uint* width,
    uint* height,
    uint* pitches,
    uint* lines);

/**
 * Callback prototype to configure picture buffers format.
 *
 * \param opaque private pointer as passed to libvlc_video_set_callbacks()
 *               (and possibly modified by @ref libvlc_video_format_cb) [IN]
 */
alias libvlc_video_cleanup_cb = void function (void* opaque);

/**
 * Set callbacks and private data to render decoded video to a custom area
 * in memory.
 * Use libvlc_video_set_format() or libvlc_video_set_format_callbacks()
 * to configure the decoded format.
 *
 * \warning Rendering video into custom memory buffers is considerably less
 * efficient than rendering in a custom window as normal.
 *
 * For optimal perfomances, VLC media player renders into a custom window, and
 * does not use this function and associated callbacks. It is <b>highly
 * recommended</b> that other LibVLC-based application do likewise.
 * To embed video in a window, use libvlc_media_player_set_xid() or equivalent
 * depending on the operating system.
 *
 * If window embedding does not fit the application use case, then a custom
 * LibVLC video output display plugin is required to maintain optimal video
 * rendering performances.
 *
 * The following limitations affect performance:
 * - Hardware video decoding acceleration will either be disabled completely,
 *   or require (relatively slow) copy from video/DSP memory to main memory.
 * - Sub-pictures (subtitles, on-screen display, etc.) must be blent into the
 *   main picture by the CPU instead of the GPU.
 * - Depending on the video format, pixel format conversion, picture scaling,
 *   cropping and/or picture re-orientation, must be performed by the CPU
 *   instead of the GPU.
 * - Memory copying is required between LibVLC reference picture buffers and
 *   application buffers (between lock and unlock callbacks).
 *
 * \param mp the media player
 * \param lock callback to lock video memory (must not be NULL)
 * \param unlock callback to unlock video memory (or NULL if not needed)
 * \param display callback to display video (or NULL if not needed)
 * \param opaque private pointer for the three callbacks (as first parameter)
 * \version LibVLC 1.1.1 or later
 */
void libvlc_video_set_callbacks (
    libvlc_media_player_t* mp,
    libvlc_video_lock_cb lock,
    libvlc_video_unlock_cb unlock,
    libvlc_video_display_cb display,
    void* opaque);

/**
 * Set decoded video chroma and dimensions.
 * This only works in combination with libvlc_video_set_callbacks(),
 * and is mutually exclusive with libvlc_video_set_format_callbacks().
 *
 * \param mp the media player
 * \param chroma a four-characters string identifying the chroma
 *               (e.g. "RV32" or "YUYV")
 * \param width pixel width
 * \param height pixel height
 * \param pitch line pitch (in bytes)
 * \version LibVLC 1.1.1 or later
 * \bug All pixel planes are expected to have the same pitch.
 * To use the YCbCr color space with chrominance subsampling,
 * consider using libvlc_video_set_format_callbacks() instead.
 */
void libvlc_video_set_format (
    libvlc_media_player_t* mp,
    const(char)* chroma,
    uint width,
    uint height,
    uint pitch);

/**
 * Set decoded video chroma and dimensions. This only works in combination with
 * libvlc_video_set_callbacks().
 *
 * \param mp the media player
 * \param setup callback to select the video format (cannot be NULL)
 * \param cleanup callback to release any allocated resources (or NULL)
 * \version LibVLC 2.0.0 or later
 */
void libvlc_video_set_format_callbacks (
    libvlc_media_player_t* mp,
    libvlc_video_format_cb setup,
    libvlc_video_cleanup_cb cleanup);

/**
 * Set the NSView handler where the media player should render its video output.
 *
 * Use the vout called "macosx".
 *
 * The drawable is an NSObject that follow the VLCOpenGLVideoViewEmbedding
 * protocol:
 *
 * @code{.m}
 * \@protocol VLCOpenGLVideoViewEmbedding <NSObject>
 * - (void)addVoutSubview:(NSView *)view;
 * - (void)removeVoutSubview:(NSView *)view;
 * \@end
 * @endcode
 *
 * Or it can be an NSView object.
 *
 * If you want to use it along with Qt see the QMacCocoaViewContainer. Then
 * the following code should work:
 * @code{.mm}
 * {
 *     NSView *video = [[NSView alloc] init];
 *     QMacCocoaViewContainer *container = new QMacCocoaViewContainer(video, parent);
 *     libvlc_media_player_set_nsobject(mp, video);
 *     [video release];
 * }
 * @endcode
 *
 * You can find a live example in VLCVideoView in VLCKit.framework.
 *
 * \param p_mi the Media Player
 * \param drawable the drawable that is either an NSView or an object following
 * the VLCOpenGLVideoViewEmbedding protocol.
 */
void libvlc_media_player_set_nsobject (libvlc_media_player_t* p_mi, void* drawable);

/**
 * Get the NSView handler previously set with libvlc_media_player_set_nsobject().
 *
 * \param p_mi the Media Player
 * \return the NSView handler or 0 if none where set
 */
void* libvlc_media_player_get_nsobject (libvlc_media_player_t* p_mi);

/**
 * Set an X Window System drawable where the media player should render its
 * video output. The call takes effect when the playback starts. If it is
 * already started, it might need to be stopped before changes apply.
 * If LibVLC was built without X11 output support, then this function has no
 * effects.
 *
 * By default, LibVLC will capture input events on the video rendering area.
 * Use libvlc_video_set_mouse_input() and libvlc_video_set_key_input() to
 * disable that and deliver events to the parent window / to the application
 * instead. By design, the X11 protocol delivers input events to only one
 * recipient.
 *
 * \warning
 * The application must call the XInitThreads() function from Xlib before
 * libvlc_new(), and before any call to XOpenDisplay() directly or via any
 * other library. Failure to call XInitThreads() will seriously impede LibVLC
 * performance. Calling XOpenDisplay() before XInitThreads() will eventually
 * crash the process. That is a limitation of Xlib.
 *
 * \param p_mi media player
 * \param drawable X11 window ID
 *
 * \note
 * The specified identifier must correspond to an existing Input/Output class
 * X11 window. Pixmaps are <b>not</b> currently supported. The default X11
 * server is assumed, i.e. that specified in the DISPLAY environment variable.
 *
 * \warning
 * LibVLC can deal with invalid X11 handle errors, however some display drivers
 * (EGL, GLX, VA and/or VDPAU) can unfortunately not. Thus the window handle
 * must remain valid until playback is stopped, otherwise the process may
 * abort or crash.
 *
 * \bug
 * No more than one window handle per media player instance can be specified.
 * If the media has multiple simultaneously active video tracks, extra tracks
 * will be rendered into external windows beyond the control of the
 * application.
 */
void libvlc_media_player_set_xwindow (
    libvlc_media_player_t* p_mi,
    uint drawable);

/**
 * Get the X Window System window identifier previously set with
 * libvlc_media_player_set_xwindow(). Note that this will return the identifier
 * even if VLC is not currently using it (for instance if it is playing an
 * audio-only input).
 *
 * \param p_mi the Media Player
 * \return an X window ID, or 0 if none where set.
 */
uint libvlc_media_player_get_xwindow (libvlc_media_player_t* p_mi);

/**
 * Set a Win32/Win64 API window handle (HWND) where the media player should
 * render its video output. If LibVLC was built without Win32/Win64 API output
 * support, then this has no effects.
 *
 * \param p_mi the Media Player
 * \param drawable windows handle of the drawable
 */
void libvlc_media_player_set_hwnd (libvlc_media_player_t* p_mi, void* drawable);

/**
 * Get the Windows API window handle (HWND) previously set with
 * libvlc_media_player_set_hwnd(). The handle will be returned even if LibVLC
 * is not currently outputting any video to it.
 *
 * \param p_mi the Media Player
 * \return a window handle or NULL if there are none.
 */
void* libvlc_media_player_get_hwnd (libvlc_media_player_t* p_mi);

/**
 * Set the android context.
 *
 * \version LibVLC 3.0.0 and later.
 *
 * \param p_mi the media player
 * \param p_awindow_handler org.videolan.libvlc.AWindow jobject owned by the
 *        org.videolan.libvlc.MediaPlayer class from the libvlc-android project.
 */
void libvlc_media_player_set_android_context (
    libvlc_media_player_t* p_mi,
    void* p_awindow_handler);

/**
 * Set the EFL Evas Object.
 *
 * \version LibVLC 3.0.0 and later.
 *
 * \param p_mi the media player
 * \param p_evas_object a valid EFL Evas Object (Evas_Object)
 * \return -1 if an error was detected, 0 otherwise.
 */
int libvlc_media_player_set_evas_object (
    libvlc_media_player_t* p_mi,
    void* p_evas_object);

/**
 * Callback prototype for audio playback.
 *
 * The LibVLC media player decodes and post-processes the audio signal
 * asynchronously (in an internal thread). Whenever audio samples are ready
 * to be queued to the output, this callback is invoked.
 *
 * The number of samples provided per invocation may depend on the file format,
 * the audio coding algorithm, the decoder plug-in, the post-processing
 * filters and timing. Application must not assume a certain number of samples.
 *
 * The exact format of audio samples is determined by libvlc_audio_set_format()
 * or libvlc_audio_set_format_callbacks() as is the channels layout.
 *
 * Note that the number of samples is per channel. For instance, if the audio
 * track sampling rate is 48000 Hz, then 1200 samples represent 25 milliseconds
 * of audio signal - regardless of the number of audio channels.
 *
 * \param data data pointer as passed to libvlc_audio_set_callbacks() [IN]
 * \param samples pointer to a table of audio samples to play back [IN]
 * \param count number of audio samples to play back
 * \param pts expected play time stamp (see libvlc_delay())
 */
alias libvlc_audio_play_cb = void function (
    void* data,
    const(void)* samples,
    uint count,
    long pts);

/**
 * Callback prototype for audio pause.
 *
 * LibVLC invokes this callback to pause audio playback.
 *
 * \note The pause callback is never called if the audio is already paused.
 * \param data data pointer as passed to libvlc_audio_set_callbacks() [IN]
 * \param pts time stamp of the pause request (should be elapsed already)
 */
alias libvlc_audio_pause_cb = void function (void* data, long pts);

/**
 * Callback prototype for audio resumption.
 *
 * LibVLC invokes this callback to resume audio playback after it was
 * previously paused.
 *
 * \note The resume callback is never called if the audio is not paused.
 * \param data data pointer as passed to libvlc_audio_set_callbacks() [IN]
 * \param pts time stamp of the resumption request (should be elapsed already)
 */
alias libvlc_audio_resume_cb = void function (void* data, long pts);

/**
 * Callback prototype for audio buffer flush.
 *
 * LibVLC invokes this callback if it needs to discard all pending buffers and
 * stop playback as soon as possible. This typically occurs when the media is
 * stopped.
 *
 * \param data data pointer as passed to libvlc_audio_set_callbacks() [IN]
 */
alias libvlc_audio_flush_cb = void function (void* data, long pts);

/**
 * Callback prototype for audio buffer drain.
 *
 * LibVLC may invoke this callback when the decoded audio track is ending.
 * There will be no further decoded samples for the track, but playback should
 * nevertheless continue until all already pending buffers are rendered.
 *
 * \param data data pointer as passed to libvlc_audio_set_callbacks() [IN]
 */
alias libvlc_audio_drain_cb = void function (void* data);

/**
 * Callback prototype for audio volume change.
 * \param data data pointer as passed to libvlc_audio_set_callbacks() [IN]
 * \param volume software volume (1. = nominal, 0. = mute)
 * \param mute muted flag
 */
alias libvlc_audio_set_volume_cb = void function (
    void* data,
    float volume,
    bool mute);

/**
 * Sets callbacks and private data for decoded audio.
 *
 * Use libvlc_audio_set_format() or libvlc_audio_set_format_callbacks()
 * to configure the decoded audio format.
 *
 * \note The audio callbacks override any other audio output mechanism.
 * If the callbacks are set, LibVLC will <b>not</b> output audio in any way.
 *
 * \param mp the media player
 * \param play callback to play audio samples (must not be NULL)
 * \param pause callback to pause playback (or NULL to ignore)
 * \param resume callback to resume playback (or NULL to ignore)
 * \param flush callback to flush audio buffers (or NULL to ignore)
 * \param drain callback to drain audio buffers (or NULL to ignore)
 * \param opaque private pointer for the audio callbacks (as first parameter)
 * \version LibVLC 2.0.0 or later
 */
void libvlc_audio_set_callbacks (
    libvlc_media_player_t* mp,
    libvlc_audio_play_cb play,
    libvlc_audio_pause_cb pause,
    libvlc_audio_resume_cb resume,
    libvlc_audio_flush_cb flush,
    libvlc_audio_drain_cb drain,
    void* opaque);

/**
 * Set callbacks and private data for decoded audio. This only works in
 * combination with libvlc_audio_set_callbacks().
 * Use libvlc_audio_set_format() or libvlc_audio_set_format_callbacks()
 * to configure the decoded audio format.
 *
 * \param mp the media player
 * \param set_volume callback to apply audio volume,
 *                   or NULL to apply volume in software
 * \version LibVLC 2.0.0 or later
 */
void libvlc_audio_set_volume_callback (
    libvlc_media_player_t* mp,
    libvlc_audio_set_volume_cb set_volume);

/**
 * Callback prototype to setup the audio playback.
 *
 * This is called when the media player needs to create a new audio output.
 * \param opaque pointer to the data pointer passed to
 *               libvlc_audio_set_callbacks() [IN/OUT]
 * \param format 4 bytes sample format [IN/OUT]
 * \param rate sample rate [IN/OUT]
 * \param channels channels count [IN/OUT]
 * \return 0 on success, anything else to skip audio playback
 */
alias libvlc_audio_setup_cb = int function (
    void** data,
    char* format,
    uint* rate,
    uint* channels);

/**
 * Callback prototype for audio playback cleanup.
 *
 * This is called when the media player no longer needs an audio output.
 * \param opaque data pointer as passed to libvlc_audio_set_callbacks() [IN]
 */
alias libvlc_audio_cleanup_cb = void function (void* data);

/**
 * Sets decoded audio format via callbacks.
 *
 * This only works in combination with libvlc_audio_set_callbacks().
 *
 * \param mp the media player
 * \param setup callback to select the audio format (cannot be NULL)
 * \param cleanup callback to release any allocated resources (or NULL)
 * \version LibVLC 2.0.0 or later
 */
void libvlc_audio_set_format_callbacks (
    libvlc_media_player_t* mp,
    libvlc_audio_setup_cb setup,
    libvlc_audio_cleanup_cb cleanup);

/**
 * Sets a fixed decoded audio format.
 *
 * This only works in combination with libvlc_audio_set_callbacks(),
 * and is mutually exclusive with libvlc_audio_set_format_callbacks().
 *
 * \param mp the media player
 * \param format a four-characters string identifying the sample format
 *               (e.g. "S16N" or "f32l")
 * \param rate sample rate (expressed in Hz)
 * \param channels channels count
 * \version LibVLC 2.0.0 or later
 */
void libvlc_audio_set_format (
    libvlc_media_player_t* mp,
    const(char)* format,
    uint rate,
    uint channels);

/** \bug This might go away ... to be replaced by a broader system */

/**
 * Get the current movie length (in ms).
 *
 * \param p_mi the Media Player
 * \return the movie length (in ms), or -1 if there is no media.
 */
libvlc_time_t libvlc_media_player_get_length (libvlc_media_player_t* p_mi);

/**
 * Get the current movie time (in ms).
 *
 * \param p_mi the Media Player
 * \return the movie time (in ms), or -1 if there is no media.
 */
libvlc_time_t libvlc_media_player_get_time (libvlc_media_player_t* p_mi);

/**
 * Set the movie time (in ms). This has no effect if no media is being played.
 * Not all formats and protocols support this.
 *
 * \param p_mi the Media Player
 * \param i_time the movie time (in ms).
 */
void libvlc_media_player_set_time (libvlc_media_player_t* p_mi, libvlc_time_t i_time);

/**
 * Get movie position as percentage between 0.0 and 1.0.
 *
 * \param p_mi the Media Player
 * \return movie position, or -1. in case of error
 */
float libvlc_media_player_get_position (libvlc_media_player_t* p_mi);

/**
 * Set movie position as percentage between 0.0 and 1.0.
 * This has no effect if playback is not enabled.
 * This might not work depending on the underlying input format and protocol.
 *
 * \param p_mi the Media Player
 * \param f_pos the position
 */
void libvlc_media_player_set_position (libvlc_media_player_t* p_mi, float f_pos);

/**
 * Set movie chapter (if applicable).
 *
 * \param p_mi the Media Player
 * \param i_chapter chapter number to play
 */
void libvlc_media_player_set_chapter (libvlc_media_player_t* p_mi, int i_chapter);

/**
 * Get movie chapter.
 *
 * \param p_mi the Media Player
 * \return chapter number currently playing, or -1 if there is no media.
 */
int libvlc_media_player_get_chapter (libvlc_media_player_t* p_mi);

/**
 * Get movie chapter count
 *
 * \param p_mi the Media Player
 * \return number of chapters in movie, or -1.
 */
int libvlc_media_player_get_chapter_count (libvlc_media_player_t* p_mi);

/**
 * Is the player able to play
 *
 * \param p_mi the Media Player
 * \return boolean
 *
 * \libvlc_return_bool
 */
int libvlc_media_player_will_play (libvlc_media_player_t* p_mi);

/**
 * Get title chapter count
 *
 * \param p_mi the Media Player
 * \param i_title title
 * \return number of chapters in title, or -1
 */
int libvlc_media_player_get_chapter_count_for_title (
    libvlc_media_player_t* p_mi,
    int i_title);

/**
 * Set movie title
 *
 * \param p_mi the Media Player
 * \param i_title title number to play
 */
void libvlc_media_player_set_title (libvlc_media_player_t* p_mi, int i_title);

/**
 * Get movie title
 *
 * \param p_mi the Media Player
 * \return title number currently playing, or -1
 */
int libvlc_media_player_get_title (libvlc_media_player_t* p_mi);

/**
 * Get movie title count
 *
 * \param p_mi the Media Player
 * \return title number count, or -1
 */
int libvlc_media_player_get_title_count (libvlc_media_player_t* p_mi);

/**
 * Set previous chapter (if applicable)
 *
 * \param p_mi the Media Player
 */
void libvlc_media_player_previous_chapter (libvlc_media_player_t* p_mi);

/**
 * Set next chapter (if applicable)
 *
 * \param p_mi the Media Player
 */
void libvlc_media_player_next_chapter (libvlc_media_player_t* p_mi);

/**
 * Get the requested movie play rate.
 * @warning Depending on the underlying media, the requested rate may be
 * different from the real playback rate.
 *
 * \param p_mi the Media Player
 * \return movie play rate
 */
float libvlc_media_player_get_rate (libvlc_media_player_t* p_mi);

/**
 * Set movie play rate
 *
 * \param p_mi the Media Player
 * \param rate movie play rate to set
 * \return -1 if an error was detected, 0 otherwise (but even then, it might
 * not actually work depending on the underlying media protocol)
 */
int libvlc_media_player_set_rate (libvlc_media_player_t* p_mi, float rate);

/**
 * Get current movie state
 *
 * \param p_mi the Media Player
 * \return the current state of the media player (playing, paused, ...) \see libvlc_state_t
 */
libvlc_state_t libvlc_media_player_get_state (libvlc_media_player_t* p_mi);

/**
 * How many video outputs does this media player have?
 *
 * \param p_mi the media player
 * \return the number of video outputs
 */
uint libvlc_media_player_has_vout (libvlc_media_player_t* p_mi);

/**
 * Is this media player seekable?
 *
 * \param p_mi the media player
 * \return true if the media player can seek
 *
 * \libvlc_return_bool
 */
int libvlc_media_player_is_seekable (libvlc_media_player_t* p_mi);

/**
 * Can this media player be paused?
 *
 * \param p_mi the media player
 * \return true if the media player can pause
 *
 * \libvlc_return_bool
 */
int libvlc_media_player_can_pause (libvlc_media_player_t* p_mi);

/**
 * Check if the current program is scrambled
 *
 * \param p_mi the media player
 * \return true if the current program is scrambled
 *
 * \libvlc_return_bool
 * \version LibVLC 2.2.0 or later
 */
int libvlc_media_player_program_scrambled (libvlc_media_player_t* p_mi);

/**
 * Display the next frame (if supported)
 *
 * \param p_mi the media player
 */
void libvlc_media_player_next_frame (libvlc_media_player_t* p_mi);

/**
 * Navigate through DVD Menu
 *
 * \param p_mi the Media Player
 * \param navigate the Navigation mode
 * \version libVLC 2.0.0 or later
 */
void libvlc_media_player_navigate (libvlc_media_player_t* p_mi, uint navigate);

/**
 * Set if, and how, the video title will be shown when media is played.
 *
 * \param p_mi the media player
 * \param position position at which to display the title, or libvlc_position_disable to prevent the title from being displayed
 * \param timeout title display timeout in milliseconds (ignored if libvlc_position_disable)
 * \version libVLC 2.1.0 or later
 */
void libvlc_media_player_set_video_title_display (libvlc_media_player_t* p_mi, libvlc_position_t position, uint timeout);

/**
 * Add a slave to the current media player.
 *
 * \note If the player is playing, the slave will be added directly. This call
 * will also update the slave list of the attached libvlc_media_t.
 *
 * \version LibVLC 3.0.0 and later.
 *
 * \see libvlc_media_slaves_add
 *
 * \param p_mi the media player
 * \param i_type subtitle or audio
 * \param psz_uri Uri of the slave (should contain a valid scheme).
 * \param b_select True if this slave should be selected when it's loaded
 *
 * \return 0 on success, -1 on error.
 */
int libvlc_media_player_add_slave (
    libvlc_media_player_t* p_mi,
    libvlc_media_slave_type_t i_type,
    const(char)* psz_uri,
    bool b_select);

/**
 * Release (free) libvlc_track_description_t
 *
 * \param p_track_description the structure to release
 */
void libvlc_track_description_list_release (libvlc_track_description_t* p_track_description);

/** \defgroup libvlc_video LibVLC video controls
 * @{
 */

/**
 * Toggle fullscreen status on non-embedded video outputs.
 *
 * @warning The same limitations applies to this function
 * as to libvlc_set_fullscreen().
 *
 * \param p_mi the media player
 */
void libvlc_toggle_fullscreen (libvlc_media_player_t* p_mi);

/**
 * Enable or disable fullscreen.
 *
 * @warning With most window managers, only a top-level windows can be in
 * full-screen mode. Hence, this function will not operate properly if
 * libvlc_media_player_set_xwindow() was used to embed the video in a
 * non-top-level window. In that case, the embedding window must be reparented
 * to the root window <b>before</b> fullscreen mode is enabled. You will want
 * to reparent it back to its normal parent when disabling fullscreen.
 *
 * \param p_mi the media player
 * \param b_fullscreen boolean for fullscreen status
 */
void libvlc_set_fullscreen (libvlc_media_player_t* p_mi, int b_fullscreen);

/**
 * Get current fullscreen status.
 *
 * \param p_mi the media player
 * \return the fullscreen status (boolean)
 *
 * \libvlc_return_bool
 */
int libvlc_get_fullscreen (libvlc_media_player_t* p_mi);

/**
 * Enable or disable key press events handling, according to the LibVLC hotkeys
 * configuration. By default and for historical reasons, keyboard events are
 * handled by the LibVLC video widget.
 *
 * \note On X11, there can be only one subscriber for key press and mouse
 * click events per window. If your application has subscribed to those events
 * for the X window ID of the video widget, then LibVLC will not be able to
 * handle key presses and mouse clicks in any case.
 *
 * \warning This function is only implemented for X11 and Win32 at the moment.
 *
 * \param p_mi the media player
 * \param on true to handle key press events, false to ignore them.
 */
void libvlc_video_set_key_input (libvlc_media_player_t* p_mi, uint on);

/**
 * Enable or disable mouse click events handling. By default, those events are
 * handled. This is needed for DVD menus to work, as well as a few video
 * filters such as "puzzle".
 *
 * \see libvlc_video_set_key_input().
 *
 * \warning This function is only implemented for X11 and Win32 at the moment.
 *
 * \param p_mi the media player
 * \param on true to handle mouse click events, false to ignore them.
 */
void libvlc_video_set_mouse_input (libvlc_media_player_t* p_mi, uint on);

/**
 * Get the pixel dimensions of a video.
 *
 * \param p_mi media player
 * \param num number of the video (starting from, and most commonly 0)
 * \param px pointer to get the pixel width [OUT]
 * \param py pointer to get the pixel height [OUT]
 * \return 0 on success, -1 if the specified video does not exist
 */
int libvlc_video_get_size (
    libvlc_media_player_t* p_mi,
    uint num,
    uint* px,
    uint* py);

/**
 * Get the mouse pointer coordinates over a video.
 * Coordinates are expressed in terms of the decoded video resolution,
 * <b>not</b> in terms of pixels on the screen/viewport (to get the latter,
 * you can query your windowing system directly).
 *
 * Either of the coordinates may be negative or larger than the corresponding
 * dimension of the video, if the cursor is outside the rendering area.
 *
 * @warning The coordinates may be out-of-date if the pointer is not located
 * on the video rendering area. LibVLC does not track the pointer if it is
 * outside of the video widget.
 *
 * @note LibVLC does not support multiple pointers (it does of course support
 * multiple input devices sharing the same pointer) at the moment.
 *
 * \param p_mi media player
 * \param num number of the video (starting from, and most commonly 0)
 * \param px pointer to get the abscissa [OUT]
 * \param py pointer to get the ordinate [OUT]
 * \return 0 on success, -1 if the specified video does not exist
 */
int libvlc_video_get_cursor (
    libvlc_media_player_t* p_mi,
    uint num,
    int* px,
    int* py);

/**
 * Get the current video scaling factor.
 * See also libvlc_video_set_scale().
 *
 * \param p_mi the media player
 * \return the currently configured zoom factor, or 0. if the video is set
 * to fit to the output window/drawable automatically.
 */
float libvlc_video_get_scale (libvlc_media_player_t* p_mi);

/**
 * Set the video scaling factor. That is the ratio of the number of pixels on
 * screen to the number of pixels in the original decoded video in each
 * dimension. Zero is a special value; it will adjust the video to the output
 * window/drawable (in windowed mode) or the entire screen.
 *
 * Note that not all video outputs support scaling.
 *
 * \param p_mi the media player
 * \param f_factor the scaling factor, or zero
 */
void libvlc_video_set_scale (libvlc_media_player_t* p_mi, float f_factor);

/**
 * Get current video aspect ratio.
 *
 * \param p_mi the media player
 * \return the video aspect ratio or NULL if unspecified
 * (the result must be released with free() or libvlc_free()).
 */
char* libvlc_video_get_aspect_ratio (libvlc_media_player_t* p_mi);

/**
 * Set new video aspect ratio.
 *
 * \param p_mi the media player
 * \param psz_aspect new video aspect-ratio or NULL to reset to default
 * \note Invalid aspect ratios are ignored.
 */
void libvlc_video_set_aspect_ratio (libvlc_media_player_t* p_mi, const(char)* psz_aspect);

/**
 * Create a video viewpoint structure.
 *
 * \version LibVLC 3.0.0 and later
 *
 * \return video viewpoint or NULL
 *         (the result must be released with free() or libvlc_free()).
 */
libvlc_video_viewpoint_t* libvlc_video_new_viewpoint ();

/**
 * Update the video viewpoint information.
 *
 * \note It is safe to call this function before the media player is started.
 *
 * \version LibVLC 3.0.0 and later
 *
 * \param p_mi the media player
 * \param p_viewpoint video viewpoint allocated via libvlc_video_new_viewpoint()
 * \param b_absolute if true replace the old viewpoint with the new one. If
 * false, increase/decrease it.
 * \return -1 in case of error, 0 otherwise
 *
 * \note the values are set asynchronously, it will be used by the next frame displayed.
 */
int libvlc_video_update_viewpoint (
    libvlc_media_player_t* p_mi,
    const(libvlc_video_viewpoint_t)* p_viewpoint,
    bool b_absolute);

/**
 * Get current video subtitle.
 *
 * \param p_mi the media player
 * \return the video subtitle selected, or -1 if none
 */
int libvlc_video_get_spu (libvlc_media_player_t* p_mi);

/**
 * Get the number of available video subtitles.
 *
 * \param p_mi the media player
 * \return the number of available video subtitles
 */
int libvlc_video_get_spu_count (libvlc_media_player_t* p_mi);

/**
 * Get the description of available video subtitles.
 *
 * \param p_mi the media player
 * \return list containing description of available video subtitles.
 * It must be freed with libvlc_track_description_list_release()
 */
libvlc_track_description_t* libvlc_video_get_spu_description (
    libvlc_media_player_t* p_mi);

/**
 * Set new video subtitle.
 *
 * \param p_mi the media player
 * \param i_spu video subtitle track to select (i_id from track description)
 * \return 0 on success, -1 if out of range
 */
int libvlc_video_set_spu (libvlc_media_player_t* p_mi, int i_spu);

/**
 * Get the current subtitle delay. Positive values means subtitles are being
 * displayed later, negative values earlier.
 *
 * \param p_mi media player
 * \return time (in microseconds) the display of subtitles is being delayed
 * \version LibVLC 2.0.0 or later
 */
long libvlc_video_get_spu_delay (libvlc_media_player_t* p_mi);

/**
 * Set the subtitle delay. This affects the timing of when the subtitle will
 * be displayed. Positive values result in subtitles being displayed later,
 * while negative values will result in subtitles being displayed earlier.
 *
 * The subtitle delay will be reset to zero each time the media changes.
 *
 * \param p_mi media player
 * \param i_delay time (in microseconds) the display of subtitles should be delayed
 * \return 0 on success, -1 on error
 * \version LibVLC 2.0.0 or later
 */
int libvlc_video_set_spu_delay (libvlc_media_player_t* p_mi, long i_delay);

/**
 * Get the full description of available titles
 *
 * \version LibVLC 3.0.0 and later.
 *
 * \param p_mi the media player
 * \param titles address to store an allocated array of title descriptions
 *        descriptions (must be freed with libvlc_title_descriptions_release()
 *        by the caller) [OUT]
 *
 * \return the number of titles (-1 on error)
 */
int libvlc_media_player_get_full_title_descriptions (
    libvlc_media_player_t* p_mi,
    libvlc_title_description_t*** titles);

/**
 * Release a title description
 *
 * \version LibVLC 3.0.0 and later
 *
 * \param p_titles title description array to release
 * \param i_count number of title descriptions to release
 */
void libvlc_title_descriptions_release (
    libvlc_title_description_t** p_titles,
    uint i_count);

/**
 * Get the full description of available chapters
 *
 * \version LibVLC 3.0.0 and later.
 *
 * \param p_mi the media player
 * \param i_chapters_of_title index of the title to query for chapters (uses current title if set to -1)
 * \param pp_chapters address to store an allocated array of chapter descriptions
 *        descriptions (must be freed with libvlc_chapter_descriptions_release()
 *        by the caller) [OUT]
 *
 * \return the number of chapters (-1 on error)
 */
int libvlc_media_player_get_full_chapter_descriptions (
    libvlc_media_player_t* p_mi,
    int i_chapters_of_title,
    libvlc_chapter_description_t*** pp_chapters);

/**
 * Release a chapter description
 *
 * \version LibVLC 3.0.0 and later
 *
 * \param p_chapters chapter description array to release
 * \param i_count number of chapter descriptions to release
 */
void libvlc_chapter_descriptions_release (
    libvlc_chapter_description_t** p_chapters,
    uint i_count);

/**
 * Get current crop filter geometry.
 *
 * \param p_mi the media player
 * \return the crop filter geometry or NULL if unset
 */
char* libvlc_video_get_crop_geometry (libvlc_media_player_t* p_mi);

/**
 * Set new crop filter geometry.
 *
 * \param p_mi the media player
 * \param psz_geometry new crop filter geometry (NULL to unset)
 */
void libvlc_video_set_crop_geometry (
    libvlc_media_player_t* p_mi,
    const(char)* psz_geometry);

/**
 * Get current teletext page requested or 0 if it's disabled.
 *
 * Teletext is disabled by default, call libvlc_video_set_teletext() to enable
 * it.
 *
 * \param p_mi the media player
 * \return the current teletext page requested.
 */
int libvlc_video_get_teletext (libvlc_media_player_t* p_mi);

/**
 * Set new teletext page to retrieve.
 *
 * This function can also be used to send a teletext key.
 *
 * \param p_mi the media player
 * \param i_page teletex page number requested. This value can be 0 to disable
 * teletext, a number in the range ]0;1000[ to show the requested page, or a
 * \ref libvlc_teletext_key_t. 100 is the default teletext page.
 */
void libvlc_video_set_teletext (libvlc_media_player_t* p_mi, int i_page);

/**
 * Get number of available video tracks.
 *
 * \param p_mi media player
 * \return the number of available video tracks (int)
 */
int libvlc_video_get_track_count (libvlc_media_player_t* p_mi);

/**
 * Get the description of available video tracks.
 *
 * \param p_mi media player
 * \return list with description of available video tracks, or NULL on error.
 * It must be freed with libvlc_track_description_list_release()
 */
libvlc_track_description_t* libvlc_video_get_track_description (
    libvlc_media_player_t* p_mi);

/**
 * Get current video track.
 *
 * \param p_mi media player
 * \return the video track ID (int) or -1 if no active input
 */
int libvlc_video_get_track (libvlc_media_player_t* p_mi);

/**
 * Set video track.
 *
 * \param p_mi media player
 * \param i_track the track ID (i_id field from track description)
 * \return 0 on success, -1 if out of range
 */
int libvlc_video_set_track (libvlc_media_player_t* p_mi, int i_track);

/**
 * Take a snapshot of the current video window.
 *
 * If i_width AND i_height is 0, original size is used.
 * If i_width XOR i_height is 0, original aspect-ratio is preserved.
 *
 * \param p_mi media player instance
 * \param num number of video output (typically 0 for the first/only one)
 * \param psz_filepath the path of a file or a folder to save the screenshot into
 * \param i_width the snapshot's width
 * \param i_height the snapshot's height
 * \return 0 on success, -1 if the video was not found
 */
int libvlc_video_take_snapshot (
    libvlc_media_player_t* p_mi,
    uint num,
    const(char)* psz_filepath,
    uint i_width,
    uint i_height);

/**
 * Enable or disable deinterlace filter
 *
 * \param p_mi libvlc media player
 * \param psz_mode type of deinterlace filter, NULL to disable
 */
void libvlc_video_set_deinterlace (
    libvlc_media_player_t* p_mi,
    const(char)* psz_mode);

/**
 * Get an integer marquee option value
 *
 * \param p_mi libvlc media player
 * \param option marq option to get \see libvlc_video_marquee_int_option_t
 */
int libvlc_video_get_marquee_int (libvlc_media_player_t* p_mi, uint option);

/**
 * Get a string marquee option value
 *
 * \param p_mi libvlc media player
 * \param option marq option to get \see libvlc_video_marquee_string_option_t
 */
char* libvlc_video_get_marquee_string (
    libvlc_media_player_t* p_mi,
    uint option);

/**
 * Enable, disable or set an integer marquee option
 *
 * Setting libvlc_marquee_Enable has the side effect of enabling (arg !0)
 * or disabling (arg 0) the marq filter.
 *
 * \param p_mi libvlc media player
 * \param option marq option to set \see libvlc_video_marquee_int_option_t
 * \param i_val marq option value
 */
void libvlc_video_set_marquee_int (
    libvlc_media_player_t* p_mi,
    uint option,
    int i_val);

/**
 * Set a marquee string option
 *
 * \param p_mi libvlc media player
 * \param option marq option to set \see libvlc_video_marquee_string_option_t
 * \param psz_text marq option value
 */
void libvlc_video_set_marquee_string (
    libvlc_media_player_t* p_mi,
    uint option,
    const(char)* psz_text);

/** option values for libvlc_video_{get,set}_logo_{int,string} */
enum libvlc_video_logo_option_t
{
    libvlc_logo_enable = 0,
    libvlc_logo_file = 1, /**< string argument, "file,d,t;file,d,t;..." */
    libvlc_logo_x = 2,
    libvlc_logo_y = 3,
    libvlc_logo_delay = 4,
    libvlc_logo_repeat = 5,
    libvlc_logo_opacity = 6,
    libvlc_logo_position = 7
}

/**
 * Get integer logo option.
 *
 * \param p_mi libvlc media player instance
 * \param option logo option to get, values of libvlc_video_logo_option_t
 */
int libvlc_video_get_logo_int (libvlc_media_player_t* p_mi, uint option);

/**
 * Set logo option as integer. Options that take a different type value
 * are ignored.
 * Passing libvlc_logo_enable as option value has the side effect of
 * starting (arg !0) or stopping (arg 0) the logo filter.
 *
 * \param p_mi libvlc media player instance
 * \param option logo option to set, values of libvlc_video_logo_option_t
 * \param value logo option value
 */
void libvlc_video_set_logo_int (
    libvlc_media_player_t* p_mi,
    uint option,
    int value);

/**
 * Set logo option as string. Options that take a different type value
 * are ignored.
 *
 * \param p_mi libvlc media player instance
 * \param option logo option to set, values of libvlc_video_logo_option_t
 * \param psz_value logo option value
 */
void libvlc_video_set_logo_string (
    libvlc_media_player_t* p_mi,
    uint option,
    const(char)* psz_value);

/** option values for libvlc_video_{get,set}_adjust_{int,float,bool} */
enum libvlc_video_adjust_option_t
{
    libvlc_adjust_Enable = 0,
    libvlc_adjust_Contrast = 1,
    libvlc_adjust_Brightness = 2,
    libvlc_adjust_Hue = 3,
    libvlc_adjust_Saturation = 4,
    libvlc_adjust_Gamma = 5
}

/**
 * Get integer adjust option.
 *
 * \param p_mi libvlc media player instance
 * \param option adjust option to get, values of libvlc_video_adjust_option_t
 * \version LibVLC 1.1.1 and later.
 */
int libvlc_video_get_adjust_int (libvlc_media_player_t* p_mi, uint option);

/**
 * Set adjust option as integer. Options that take a different type value
 * are ignored.
 * Passing libvlc_adjust_enable as option value has the side effect of
 * starting (arg !0) or stopping (arg 0) the adjust filter.
 *
 * \param p_mi libvlc media player instance
 * \param option adust option to set, values of libvlc_video_adjust_option_t
 * \param value adjust option value
 * \version LibVLC 1.1.1 and later.
 */
void libvlc_video_set_adjust_int (
    libvlc_media_player_t* p_mi,
    uint option,
    int value);

/**
 * Get float adjust option.
 *
 * \param p_mi libvlc media player instance
 * \param option adjust option to get, values of libvlc_video_adjust_option_t
 * \version LibVLC 1.1.1 and later.
 */
float libvlc_video_get_adjust_float (libvlc_media_player_t* p_mi, uint option);

/**
 * Set adjust option as float. Options that take a different type value
 * are ignored.
 *
 * \param p_mi libvlc media player instance
 * \param option adust option to set, values of libvlc_video_adjust_option_t
 * \param value adjust option value
 * \version LibVLC 1.1.1 and later.
 */
void libvlc_video_set_adjust_float (
    libvlc_media_player_t* p_mi,
    uint option,
    float value);

/** @} video */

/** \defgroup libvlc_audio LibVLC audio controls
 * @{
 */

/**
 * Audio device types
 */
enum libvlc_audio_output_device_types_t
{
    libvlc_AudioOutputDevice_Error = -1,
    libvlc_AudioOutputDevice_Mono = 1,
    libvlc_AudioOutputDevice_Stereo = 2,
    libvlc_AudioOutputDevice_2F2R = 4,
    libvlc_AudioOutputDevice_3F2R = 5,
    libvlc_AudioOutputDevice_5_1 = 6,
    libvlc_AudioOutputDevice_6_1 = 7,
    libvlc_AudioOutputDevice_7_1 = 8,
    libvlc_AudioOutputDevice_SPDIF = 10
}

/**
 * Audio channels
 */
enum libvlc_audio_output_channel_t
{
    libvlc_AudioChannel_Error = -1,
    libvlc_AudioChannel_Stereo = 1,
    libvlc_AudioChannel_RStereo = 2,
    libvlc_AudioChannel_Left = 3,
    libvlc_AudioChannel_Right = 4,
    libvlc_AudioChannel_Dolbys = 5
}

/**
 * Gets the list of available audio output modules.
 *
 * \param p_instance libvlc instance
 * \return list of available audio outputs. It must be freed with
*          \see libvlc_audio_output_list_release \see libvlc_audio_output_t .
 *         In case of error, NULL is returned.
 */
libvlc_audio_output_t* libvlc_audio_output_list_get (
    libvlc_instance_t* p_instance);

/**
 * Frees the list of available audio output modules.
 *
 * \param p_list list with audio outputs for release
 */
void libvlc_audio_output_list_release (libvlc_audio_output_t* p_list);

/**
 * Selects an audio output module.
 * \note Any change will take be effect only after playback is stopped and
 * restarted. Audio output cannot be changed while playing.
 *
 * \param p_mi media player
 * \param psz_name name of audio output,
 *               use psz_name of \see libvlc_audio_output_t
 * \return 0 if function succeeded, -1 on error
 */
int libvlc_audio_output_set (
    libvlc_media_player_t* p_mi,
    const(char)* psz_name);

/**
 * Gets a list of potential audio output devices,
 * \see libvlc_audio_output_device_set().
 *
 * \note Not all audio outputs support enumerating devices.
 * The audio output may be functional even if the list is empty (NULL).
 *
 * \note The list may not be exhaustive.
 *
 * \warning Some audio output devices in the list might not actually work in
 * some circumstances. By default, it is recommended to not specify any
 * explicit audio device.
 *
 * \param mp media player
 * \return A NULL-terminated linked list of potential audio output devices.
 * It must be freed with libvlc_audio_output_device_list_release()
 * \version LibVLC 2.2.0 or later.
 */
libvlc_audio_output_device_t* libvlc_audio_output_device_enum (
    libvlc_media_player_t* mp);

/**
 * Gets a list of audio output devices for a given audio output module,
 * \see libvlc_audio_output_device_set().
 *
 * \note Not all audio outputs support this. In particular, an empty (NULL)
 * list of devices does <b>not</b> imply that the specified audio output does
 * not work.
 *
 * \note The list might not be exhaustive.
 *
 * \warning Some audio output devices in the list might not actually work in
 * some circumstances. By default, it is recommended to not specify any
 * explicit audio device.
 *
 * \param p_instance libvlc instance
 * \param aout audio output name
 *                 (as returned by libvlc_audio_output_list_get())
 * \return A NULL-terminated linked list of potential audio output devices.
 * It must be freed with libvlc_audio_output_device_list_release()
 * \version LibVLC 2.1.0 or later.
 */
libvlc_audio_output_device_t* libvlc_audio_output_device_list_get (
    libvlc_instance_t* p_instance,
    const(char)* aout);

/**
 * Frees a list of available audio output devices.
 *
 * \param p_list list with audio outputs for release
 * \version LibVLC 2.1.0 or later.
 */
void libvlc_audio_output_device_list_release (
    libvlc_audio_output_device_t* p_list);

/**
 * Configures an explicit audio output device.
 *
 * If the module paramater is NULL, audio output will be moved to the device
 * specified by the device identifier string immediately. This is the
 * recommended usage.
 *
 * A list of adequate potential device strings can be obtained with
 * libvlc_audio_output_device_enum().
 *
 * However passing NULL is supported in LibVLC version 2.2.0 and later only;
 * in earlier versions, this function would have no effects when the module
 * parameter was NULL.
 *
 * If the module parameter is not NULL, the device parameter of the
 * corresponding audio output, if it exists, will be set to the specified
 * string. Note that some audio output modules do not have such a parameter
 * (notably MMDevice and PulseAudio).
 *
 * A list of adequate potential device strings can be obtained with
 * libvlc_audio_output_device_list_get().
 *
 * \note This function does not select the specified audio output plugin.
 * libvlc_audio_output_set() is used for that purpose.
 *
 * \warning The syntax for the device parameter depends on the audio output.
 *
 * Some audio output modules require further parameters (e.g. a channels map
 * in the case of ALSA).
 *
 * \param mp media player
 * \param module If NULL, current audio output module.
 *               if non-NULL, name of audio output module
                 (\see libvlc_audio_output_t)
 * \param device_id device identifier string
 * \return Nothing. Errors are ignored (this is a design bug).
 */
void libvlc_audio_output_device_set (
    libvlc_media_player_t* mp,
    const(char)* module_,
    const(char)* device_id);

/**
 * Get the current audio output device identifier.
 *
 * This complements libvlc_audio_output_device_set().
 *
 * \warning The initial value for the current audio output device identifier
 * may not be set or may be some unknown value. A LibVLC application should
 * compare this value against the known device identifiers (e.g. those that
 * were previously retrieved by a call to libvlc_audio_output_device_enum or
 * libvlc_audio_output_device_list_get) to find the current audio output device.
 *
 * It is possible that the selected audio output device changes (an external
 * change) without a call to libvlc_audio_output_device_set. That may make this
 * method unsuitable to use if a LibVLC application is attempting to track
 * dynamic audio device changes as they happen.
 *
 * \param mp media player
 * \return the current audio output device identifier
 *         NULL if no device is selected or in case of error
 *         (the result must be released with free() or libvlc_free()).
 * \version LibVLC 3.0.0 or later.
 */
char* libvlc_audio_output_device_get (libvlc_media_player_t* mp);

/**
 * Toggle mute status.
 *
 * \param p_mi media player
 * \warning Toggling mute atomically is not always possible: On some platforms,
 * other processes can mute the VLC audio playback stream asynchronously. Thus,
 * there is a small race condition where toggling will not work.
 * See also the limitations of libvlc_audio_set_mute().
 */
void libvlc_audio_toggle_mute (libvlc_media_player_t* p_mi);

/**
 * Get current mute status.
 *
 * \param p_mi media player
 * \return the mute status (boolean) if defined, -1 if undefined/unapplicable
 */
int libvlc_audio_get_mute (libvlc_media_player_t* p_mi);

/**
 * Set mute status.
 *
 * \param p_mi media player
 * \param status If status is true then mute, otherwise unmute
 * \warning This function does not always work. If there are no active audio
 * playback stream, the mute status might not be available. If digital
 * pass-through (S/PDIF, HDMI...) is in use, muting may be unapplicable. Also
 * some audio output plugins do not support muting at all.
 * \note To force silent playback, disable all audio tracks. This is more
 * efficient and reliable than mute.
 */
void libvlc_audio_set_mute (libvlc_media_player_t* p_mi, int status);

/**
 * Get current software audio volume.
 *
 * \param p_mi media player
 * \return the software volume in percents
 * (0 = mute, 100 = nominal / 0dB)
 */
int libvlc_audio_get_volume (libvlc_media_player_t* p_mi);

/**
 * Set current software audio volume.
 *
 * \param p_mi media player
 * \param i_volume the volume in percents (0 = mute, 100 = 0dB)
 * \return 0 if the volume was set, -1 if it was out of range
 */
int libvlc_audio_set_volume (libvlc_media_player_t* p_mi, int i_volume);

/**
 * Get number of available audio tracks.
 *
 * \param p_mi media player
 * \return the number of available audio tracks (int), or -1 if unavailable
 */
int libvlc_audio_get_track_count (libvlc_media_player_t* p_mi);

/**
 * Get the description of available audio tracks.
 *
 * \param p_mi media player
 * \return list with description of available audio tracks, or NULL.
 * It must be freed with libvlc_track_description_list_release()
 */
libvlc_track_description_t* libvlc_audio_get_track_description (
    libvlc_media_player_t* p_mi);

/**
 * Get current audio track.
 *
 * \param p_mi media player
 * \return the audio track ID or -1 if no active input.
 */
int libvlc_audio_get_track (libvlc_media_player_t* p_mi);

/**
 * Set current audio track.
 *
 * \param p_mi media player
 * \param i_track the track ID (i_id field from track description)
 * \return 0 on success, -1 on error
 */
int libvlc_audio_set_track (libvlc_media_player_t* p_mi, int i_track);

/**
 * Get current audio channel.
 *
 * \param p_mi media player
 * \return the audio channel \see libvlc_audio_output_channel_t
 */
int libvlc_audio_get_channel (libvlc_media_player_t* p_mi);

/**
 * Set current audio channel.
 *
 * \param p_mi media player
 * \param channel the audio channel, \see libvlc_audio_output_channel_t
 * \return 0 on success, -1 on error
 */
int libvlc_audio_set_channel (libvlc_media_player_t* p_mi, int channel);

/**
 * Get current audio delay.
 *
 * \param p_mi media player
 * \return the audio delay (microseconds)
 * \version LibVLC 1.1.1 or later
 */
long libvlc_audio_get_delay (libvlc_media_player_t* p_mi);

/**
 * Set current audio delay. The audio delay will be reset to zero each time the media changes.
 *
 * \param p_mi media player
 * \param i_delay the audio delay (microseconds)
 * \return 0 on success, -1 on error
 * \version LibVLC 1.1.1 or later
 */
int libvlc_audio_set_delay (libvlc_media_player_t* p_mi, long i_delay);

/**
 * Get the number of equalizer presets.
 *
 * \return number of presets
 * \version LibVLC 2.2.0 or later
 */
uint libvlc_audio_equalizer_get_preset_count ();

/**
 * Get the name of a particular equalizer preset.
 *
 * This name can be used, for example, to prepare a preset label or menu in a user
 * interface.
 *
 * \param u_index index of the preset, counting from zero
 * \return preset name, or NULL if there is no such preset
 * \version LibVLC 2.2.0 or later
 */
const(char)* libvlc_audio_equalizer_get_preset_name (uint u_index);

/**
 * Get the number of distinct frequency bands for an equalizer.
 *
 * \return number of frequency bands
 * \version LibVLC 2.2.0 or later
 */
uint libvlc_audio_equalizer_get_band_count ();

/**
 * Get a particular equalizer band frequency.
 *
 * This value can be used, for example, to create a label for an equalizer band control
 * in a user interface.
 *
 * \param u_index index of the band, counting from zero
 * \return equalizer band frequency (Hz), or -1 if there is no such band
 * \version LibVLC 2.2.0 or later
 */
float libvlc_audio_equalizer_get_band_frequency (uint u_index);

/**
 * Create a new default equalizer, with all frequency values zeroed.
 *
 * The new equalizer can subsequently be applied to a media player by invoking
 * libvlc_media_player_set_equalizer().
 *
 * The returned handle should be freed via libvlc_audio_equalizer_release() when
 * it is no longer needed.
 *
 * \return opaque equalizer handle, or NULL on error
 * \version LibVLC 2.2.0 or later
 */
libvlc_equalizer_t* libvlc_audio_equalizer_new ();

/**
 * Create a new equalizer, with initial frequency values copied from an existing
 * preset.
 *
 * The new equalizer can subsequently be applied to a media player by invoking
 * libvlc_media_player_set_equalizer().
 *
 * The returned handle should be freed via libvlc_audio_equalizer_release() when
 * it is no longer needed.
 *
 * \param u_index index of the preset, counting from zero
 * \return opaque equalizer handle, or NULL on error
 * \version LibVLC 2.2.0 or later
 */
libvlc_equalizer_t* libvlc_audio_equalizer_new_from_preset (uint u_index);

/**
 * Release a previously created equalizer instance.
 *
 * The equalizer was previously created by using libvlc_audio_equalizer_new() or
 * libvlc_audio_equalizer_new_from_preset().
 *
 * It is safe to invoke this method with a NULL p_equalizer parameter for no effect.
 *
 * \param p_equalizer opaque equalizer handle, or NULL
 * \version LibVLC 2.2.0 or later
 */
void libvlc_audio_equalizer_release (libvlc_equalizer_t* p_equalizer);

/**
 * Set a new pre-amplification value for an equalizer.
 *
 * The new equalizer settings are subsequently applied to a media player by invoking
 * libvlc_media_player_set_equalizer().
 *
 * The supplied amplification value will be clamped to the -20.0 to +20.0 range.
 *
 * \param p_equalizer valid equalizer handle, must not be NULL
 * \param f_preamp preamp value (-20.0 to 20.0 Hz)
 * \return zero on success, -1 on error
 * \version LibVLC 2.2.0 or later
 */
int libvlc_audio_equalizer_set_preamp (libvlc_equalizer_t* p_equalizer, float f_preamp);

/**
 * Get the current pre-amplification value from an equalizer.
 *
 * \param p_equalizer valid equalizer handle, must not be NULL
 * \return preamp value (Hz)
 * \version LibVLC 2.2.0 or later
 */
float libvlc_audio_equalizer_get_preamp (libvlc_equalizer_t* p_equalizer);

/**
 * Set a new amplification value for a particular equalizer frequency band.
 *
 * The new equalizer settings are subsequently applied to a media player by invoking
 * libvlc_media_player_set_equalizer().
 *
 * The supplied amplification value will be clamped to the -20.0 to +20.0 range.
 *
 * \param p_equalizer valid equalizer handle, must not be NULL
 * \param f_amp amplification value (-20.0 to 20.0 Hz)
 * \param u_band index, counting from zero, of the frequency band to set
 * \return zero on success, -1 on error
 * \version LibVLC 2.2.0 or later
 */
int libvlc_audio_equalizer_set_amp_at_index (libvlc_equalizer_t* p_equalizer, float f_amp, uint u_band);

/**
 * Get the amplification value for a particular equalizer frequency band.
 *
 * \param p_equalizer valid equalizer handle, must not be NULL
 * \param u_band index, counting from zero, of the frequency band to get
 * \return amplification value (Hz); NaN if there is no such frequency band
 * \version LibVLC 2.2.0 or later
 */
float libvlc_audio_equalizer_get_amp_at_index (libvlc_equalizer_t* p_equalizer, uint u_band);

/**
 * Apply new equalizer settings to a media player.
 *
 * The equalizer is first created by invoking libvlc_audio_equalizer_new() or
 * libvlc_audio_equalizer_new_from_preset().
 *
 * It is possible to apply new equalizer settings to a media player whether the media
 * player is currently playing media or not.
 *
 * Invoking this method will immediately apply the new equalizer settings to the audio
 * output of the currently playing media if there is any.
 *
 * If there is no currently playing media, the new equalizer settings will be applied
 * later if and when new media is played.
 *
 * Equalizer settings will automatically be applied to subsequently played media.
 *
 * To disable the equalizer for a media player invoke this method passing NULL for the
 * p_equalizer parameter.
 *
 * The media player does not keep a reference to the supplied equalizer so it is safe
 * for an application to release the equalizer reference any time after this method
 * returns.
 *
 * \param p_mi opaque media player handle
 * \param p_equalizer opaque equalizer handle, or NULL to disable the equalizer for this media player
 * \return zero on success, -1 on error
 * \version LibVLC 2.2.0 or later
 */
int libvlc_media_player_set_equalizer (libvlc_media_player_t* p_mi, libvlc_equalizer_t* p_equalizer);

/**
 * Media player roles.
 *
 * \version LibVLC 3.0.0 and later.
 *
 * See \ref libvlc_media_player_set_role()
 */
enum libvlc_media_player_role
{
    libvlc_role_None = 0, /**< Don't use a media player role */
    libvlc_role_Music = 1, /**< Music (or radio) playback */
    libvlc_role_Video = 2, /**< Video playback */
    libvlc_role_Communication = 3, /**< Speech, real-time communication */
    libvlc_role_Game = 4, /**< Video game */
    libvlc_role_Notification = 5, /**< User interaction feedback */
    libvlc_role_Animation = 6, /**< Embedded animation (e.g. in web page) */
    libvlc_role_Production = 7, /**< Audio editting/production */
    libvlc_role_Accessibility = 8, /**< Accessibility */
    libvlc_role_Test = 9 /** Testing */
}

enum libvlc_role_Last = libvlc_media_player_role.libvlc_role_Test;
alias libvlc_media_player_role_t = libvlc_media_player_role;

/**
 * Gets the media role.
 *
 * \version LibVLC 3.0.0 and later.
 *
 * \param p_mi media player
 * \return the media player role (\ref libvlc_media_player_role_t)
 */
int libvlc_media_player_get_role (libvlc_media_player_t* p_mi);

/**
 * Sets the media role.
 *
 * \param p_mi media player
 * \param role the media player role (\ref libvlc_media_player_role_t)
 * \return 0 on success, -1 on error
 */
int libvlc_media_player_set_role (libvlc_media_player_t* p_mi, uint role);

/** @} audio */

/** @} media_player */

/* VLC_LIBVLC_MEDIA_PLAYER_H */
/*****************************************************************************
 * libvlc_media_list.h:  libvlc_media_list API
 *****************************************************************************
 * Copyright (C) 1998-2008 VLC authors and VideoLAN
 * $Id: fa3b90932be8c3a9cce27925d4867aeddde748d7 $
 *
 * Authors: Pierre d'Herbemont
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

enum LIBVLC_MEDIA_LIST_H = 1;

/** \defgroup libvlc_media_list LibVLC media list
 * \ingroup libvlc
 * A LibVLC media list holds multiple @ref libvlc_media_t media descriptors.
 * @{
 * \file
 * LibVLC media list (playlist) external API
 */

/**
 * Create an empty media list.
 *
 * \param p_instance libvlc instance
 * \return empty media list, or NULL on error
 */
libvlc_media_list_t* libvlc_media_list_new (libvlc_instance_t* p_instance);

/**
 * Release media list created with libvlc_media_list_new().
 *
 * \param p_ml a media list created with libvlc_media_list_new()
 */
void libvlc_media_list_release (libvlc_media_list_t* p_ml);

/**
 * Retain reference to a media list
 *
 * \param p_ml a media list created with libvlc_media_list_new()
 */
void libvlc_media_list_retain (libvlc_media_list_t* p_ml);

/**
 * Associate media instance with this media list instance.
 * If another media instance was present it will be released.
 * The libvlc_media_list_lock should NOT be held upon entering this function.
 *
 * \param p_ml a media list instance
 * \param p_md media instance to add
 */
void libvlc_media_list_set_media (
    libvlc_media_list_t* p_ml,
    libvlc_media_t* p_md);

/**
 * Get media instance from this media list instance. This action will increase
 * the refcount on the media instance.
 * The libvlc_media_list_lock should NOT be held upon entering this function.
 *
 * \param p_ml a media list instance
 * \return media instance
 */
libvlc_media_t* libvlc_media_list_media (libvlc_media_list_t* p_ml);

/**
 * Add media instance to media list
 * The libvlc_media_list_lock should be held upon entering this function.
 *
 * \param p_ml a media list instance
 * \param p_md a media instance
 * \return 0 on success, -1 if the media list is read-only
 */
int libvlc_media_list_add_media (
    libvlc_media_list_t* p_ml,
    libvlc_media_t* p_md);

/**
 * Insert media instance in media list on a position
 * The libvlc_media_list_lock should be held upon entering this function.
 *
 * \param p_ml a media list instance
 * \param p_md a media instance
 * \param i_pos position in array where to insert
 * \return 0 on success, -1 if the media list is read-only
 */
int libvlc_media_list_insert_media (
    libvlc_media_list_t* p_ml,
    libvlc_media_t* p_md,
    int i_pos);

/**
 * Remove media instance from media list on a position
 * The libvlc_media_list_lock should be held upon entering this function.
 *
 * \param p_ml a media list instance
 * \param i_pos position in array where to insert
 * \return 0 on success, -1 if the list is read-only or the item was not found
 */
int libvlc_media_list_remove_index (libvlc_media_list_t* p_ml, int i_pos);

/**
 * Get count on media list items
 * The libvlc_media_list_lock should be held upon entering this function.
 *
 * \param p_ml a media list instance
 * \return number of items in media list
 */
int libvlc_media_list_count (libvlc_media_list_t* p_ml);

/**
 * List media instance in media list at a position
 * The libvlc_media_list_lock should be held upon entering this function.
 *
 * \param p_ml a media list instance
 * \param i_pos position in array where to insert
 * \return media instance at position i_pos, or NULL if not found.
 * In case of success, libvlc_media_retain() is called to increase the refcount
 * on the media.
 */
libvlc_media_t* libvlc_media_list_item_at_index (
    libvlc_media_list_t* p_ml,
    int i_pos);
/**
 * Find index position of List media instance in media list.
 * Warning: the function will return the first matched position.
 * The libvlc_media_list_lock should be held upon entering this function.
 *
 * \param p_ml a media list instance
 * \param p_md media instance
 * \return position of media instance or -1 if media not found
 */
int libvlc_media_list_index_of_item (
    libvlc_media_list_t* p_ml,
    libvlc_media_t* p_md);

/**
 * This indicates if this media list is read-only from a user point of view
 *
 * \param p_ml media list instance
 * \return 1 on readonly, 0 on readwrite
 *
 * \libvlc_return_bool
 */
int libvlc_media_list_is_readonly (libvlc_media_list_t* p_ml);

/**
 * Get lock on media list items
 *
 * \param p_ml a media list instance
 */
void libvlc_media_list_lock (libvlc_media_list_t* p_ml);

/**
 * Release lock on media list items
 * The libvlc_media_list_lock should be held upon entering this function.
 *
 * \param p_ml a media list instance
 */
void libvlc_media_list_unlock (libvlc_media_list_t* p_ml);

/**
 * Get libvlc_event_manager from this media list instance.
 * The p_event_manager is immutable, so you don't have to hold the lock
 *
 * \param p_ml a media list instance
 * \return libvlc_event_manager
 */
libvlc_event_manager_t* libvlc_media_list_event_manager (
    libvlc_media_list_t* p_ml);

/** @} media_list */

/* _LIBVLC_MEDIA_LIST_H */
/*****************************************************************************
 * libvlc_media_list_player.h:  libvlc_media_list API
 *****************************************************************************
 * Copyright (C) 1998-2008 VLC authors and VideoLAN
 * $Id: 04f7d9b9f0d47e1b8304b51ca20fd2b1045a0ff2 $
 *
 * Authors: Pierre d'Herbemont
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

enum LIBVLC_MEDIA_LIST_PLAYER_H = 1;

/** \defgroup libvlc_media_list_player LibVLC media list player
 * \ingroup libvlc
 * The LibVLC media list player plays a @ref libvlc_media_list_t list of media,
 * in a certain order.
 * This is required to especially support playlist files.
 * The normal @ref libvlc_media_player_t LibVLC media player can only play a
 * single media, and does not handle playlist files properly.
 * @{
 * \file
 * LibVLC media list player external API
 */

struct libvlc_media_list_player_t;

/**
 *  Defines playback modes for playlist.
 */
enum libvlc_playback_mode_t
{
    libvlc_playback_mode_default = 0,
    libvlc_playback_mode_loop = 1,
    libvlc_playback_mode_repeat = 2
}

/**
 * Create new media_list_player.
 *
 * \param p_instance libvlc instance
 * \return media list player instance or NULL on error
 */
libvlc_media_list_player_t* libvlc_media_list_player_new (
    libvlc_instance_t* p_instance);

/**
 * Release a media_list_player after use
 * Decrement the reference count of a media player object. If the
 * reference count is 0, then libvlc_media_list_player_release() will
 * release the media player object. If the media player object
 * has been released, then it should not be used again.
 *
 * \param p_mlp media list player instance
 */
void libvlc_media_list_player_release (libvlc_media_list_player_t* p_mlp);

/**
 * Retain a reference to a media player list object. Use
 * libvlc_media_list_player_release() to decrement reference count.
 *
 * \param p_mlp media player list object
 */
void libvlc_media_list_player_retain (libvlc_media_list_player_t* p_mlp);

/**
 * Return the event manager of this media_list_player.
 *
 * \param p_mlp media list player instance
 * \return the event manager
 */
libvlc_event_manager_t* libvlc_media_list_player_event_manager (
    libvlc_media_list_player_t* p_mlp);

/**
 * Replace media player in media_list_player with this instance.
 *
 * \param p_mlp media list player instance
 * \param p_mi media player instance
 */
void libvlc_media_list_player_set_media_player (
    libvlc_media_list_player_t* p_mlp,
    libvlc_media_player_t* p_mi);

/**
 * Get media player of the media_list_player instance.
 *
 * \param p_mlp media list player instance
 * \return media player instance
 * \note the caller is responsible for releasing the returned instance
 */
libvlc_media_player_t* libvlc_media_list_player_get_media_player (
    libvlc_media_list_player_t* p_mlp);

/**
 * Set the media list associated with the player
 *
 * \param p_mlp media list player instance
 * \param p_mlist list of media
 */
void libvlc_media_list_player_set_media_list (
    libvlc_media_list_player_t* p_mlp,
    libvlc_media_list_t* p_mlist);

/**
 * Play media list
 *
 * \param p_mlp media list player instance
 */
void libvlc_media_list_player_play (libvlc_media_list_player_t* p_mlp);

/**
 * Toggle pause (or resume) media list
 *
 * \param p_mlp media list player instance
 */
void libvlc_media_list_player_pause (libvlc_media_list_player_t* p_mlp);

/**
 * Pause or resume media list
 *
 * \param p_mlp media list player instance
 * \param do_pause play/resume if zero, pause if non-zero
 * \version LibVLC 3.0.0 or later
 */
void libvlc_media_list_player_set_pause (
    libvlc_media_list_player_t* p_mlp,
    int do_pause);

/**
 * Is media list playing?
 *
 * \param p_mlp media list player instance
 * \return true for playing and false for not playing
 *
 * \libvlc_return_bool
 */
int libvlc_media_list_player_is_playing (libvlc_media_list_player_t* p_mlp);

/**
 * Get current libvlc_state of media list player
 *
 * \param p_mlp media list player instance
 * \return libvlc_state_t for media list player
 */
libvlc_state_t libvlc_media_list_player_get_state (
    libvlc_media_list_player_t* p_mlp);

/**
 * Play media list item at position index
 *
 * \param p_mlp media list player instance
 * \param i_index index in media list to play
 * \return 0 upon success -1 if the item wasn't found
 */
int libvlc_media_list_player_play_item_at_index (
    libvlc_media_list_player_t* p_mlp,
    int i_index);

/**
 * Play the given media item
 *
 * \param p_mlp media list player instance
 * \param p_md the media instance
 * \return 0 upon success, -1 if the media is not part of the media list
 */
int libvlc_media_list_player_play_item (
    libvlc_media_list_player_t* p_mlp,
    libvlc_media_t* p_md);

/**
 * Stop playing media list
 *
 * \param p_mlp media list player instance
 */
void libvlc_media_list_player_stop (libvlc_media_list_player_t* p_mlp);

/**
 * Play next item from media list
 *
 * \param p_mlp media list player instance
 * \return 0 upon success -1 if there is no next item
 */
int libvlc_media_list_player_next (libvlc_media_list_player_t* p_mlp);

/**
 * Play previous item from media list
 *
 * \param p_mlp media list player instance
 * \return 0 upon success -1 if there is no previous item
 */
int libvlc_media_list_player_previous (libvlc_media_list_player_t* p_mlp);

/**
 * Sets the playback mode for the playlist
 *
 * \param p_mlp media list player instance
 * \param e_mode playback mode specification
 */
void libvlc_media_list_player_set_playback_mode (
    libvlc_media_list_player_t* p_mlp,
    libvlc_playback_mode_t e_mode);

/** @} media_list_player */

/* LIBVLC_MEDIA_LIST_PLAYER_H */
/*****************************************************************************
 * libvlc_media_library.h:  libvlc external API
 *****************************************************************************
 * Copyright (C) 1998-2009 VLC authors and VideoLAN
 * $Id: facbf813aa16140461c6e72f166d2985c52b1d6f $
 *
 * Authors: Clément Stenac <zorglub@videolan.org>
 *          Jean-Paul Saman <jpsaman@videolan.org>
 *          Pierre d'Herbemont <pdherbemont@videolan.org>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

enum VLC_LIBVLC_MEDIA_LIBRARY_H = 1;

/** \defgroup libvlc_media_library LibVLC media library
 * \ingroup libvlc
 * @{
 * \file
 * LibVLC media library external API
 */

struct libvlc_media_library_t;

/**
 * Create an new Media Library object
 *
 * \param p_instance the libvlc instance
 * \return a new object or NULL on error
 */
libvlc_media_library_t* libvlc_media_library_new (
    libvlc_instance_t* p_instance);

/**
 * Release media library object. This functions decrements the
 * reference count of the media library object. If it reaches 0,
 * then the object will be released.
 *
 * \param p_mlib media library object
 */
void libvlc_media_library_release (libvlc_media_library_t* p_mlib);

/**
 * Retain a reference to a media library object. This function will
 * increment the reference counting for this object. Use
 * libvlc_media_library_release() to decrement the reference count.
 *
 * \param p_mlib media library object
 */
void libvlc_media_library_retain (libvlc_media_library_t* p_mlib);

/**
 * Load media library.
 *
 * \param p_mlib media library object
 * \return 0 on success, -1 on error
 */
int libvlc_media_library_load (libvlc_media_library_t* p_mlib);

/**
 * Get media library subitems.
 *
 * \param p_mlib media library object
 * \return media list subitems
 */
libvlc_media_list_t* libvlc_media_library_media_list (
    libvlc_media_library_t* p_mlib);

/** @} */

/* VLC_LIBVLC_MEDIA_LIBRARY_H */
/*****************************************************************************
 * libvlc_media_discoverer.h:  libvlc external API
 *****************************************************************************
 * Copyright (C) 1998-2009 VLC authors and VideoLAN
 * $Id: 96c0515ffec98f439867814d68525288b2702b0f $
 *
 * Authors: Clément Stenac <zorglub@videolan.org>
 *          Jean-Paul Saman <jpsaman@videolan.org>
 *          Pierre d'Herbemont <pdherbemont@videolan.org>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

enum VLC_LIBVLC_MEDIA_DISCOVERER_H = 1;

/**
 * Category of a media discoverer
 * \see libvlc_media_discoverer_list_get()
 */
enum libvlc_media_discoverer_category_t
{
    /** devices, like portable music player */
    libvlc_media_discoverer_devices = 0,
    /** LAN/WAN services, like Upnp, SMB, or SAP */
    libvlc_media_discoverer_lan = 1,
    /** Podcasts */
    libvlc_media_discoverer_podcasts = 2,
    /** Local directories, like Video, Music or Pictures directories */
    libvlc_media_discoverer_localdirs = 3
}

/**
 * Media discoverer description
 * \see libvlc_media_discoverer_list_get()
 */
struct libvlc_media_discoverer_description_t
{
    char* psz_name;
    char* psz_longname;
    libvlc_media_discoverer_category_t i_cat;
}

/** \defgroup libvlc_media_discoverer LibVLC media discovery
 * \ingroup libvlc
 * LibVLC media discovery finds available media via various means.
 * This corresponds to the service discovery functionality in VLC media player.
 * Different plugins find potential medias locally (e.g. user media directory),
 * from peripherals (e.g. video capture device), on the local network
 * (e.g. SAP) or on the Internet (e.g. Internet radios).
 * @{
 * \file
 * LibVLC media discovery external API
 */

struct libvlc_media_discoverer_t;

/**
 * Create a media discoverer object by name.
 *
 * After this object is created, you should attach to media_list events in
 * order to be notified of new items discovered.
 *
 * You need to call libvlc_media_discoverer_start() in order to start the
 * discovery.
 *
 * \see libvlc_media_discoverer_media_list
 * \see libvlc_media_discoverer_event_manager
 * \see libvlc_media_discoverer_start
 *
 * \param p_inst libvlc instance
 * \param psz_name service name; use libvlc_media_discoverer_list_get() to get
 * a list of the discoverer names available in this libVLC instance
 * \return media discover object or NULL in case of error
 * \version LibVLC 3.0.0 or later
 */
libvlc_media_discoverer_t* libvlc_media_discoverer_new (
    libvlc_instance_t* p_inst,
    const(char)* psz_name);

/**
 * Start media discovery.
 *
 * To stop it, call libvlc_media_discoverer_stop() or
 * libvlc_media_discoverer_list_release() directly.
 *
 * \see libvlc_media_discoverer_stop
 *
 * \param p_mdis media discover object
 * \return -1 in case of error, 0 otherwise
 * \version LibVLC 3.0.0 or later
 */
int libvlc_media_discoverer_start (libvlc_media_discoverer_t* p_mdis);

/**
 * Stop media discovery.
 *
 * \see libvlc_media_discoverer_start
 *
 * \param p_mdis media discover object
 * \version LibVLC 3.0.0 or later
 */
void libvlc_media_discoverer_stop (libvlc_media_discoverer_t* p_mdis);

/**
 * Release media discover object. If the reference count reaches 0, then
 * the object will be released.
 *
 * \param p_mdis media service discover object
 */
void libvlc_media_discoverer_release (libvlc_media_discoverer_t* p_mdis);

/**
 * Get media service discover media list.
 *
 * \param p_mdis media service discover object
 * \return list of media items
 */
libvlc_media_list_t* libvlc_media_discoverer_media_list (
    libvlc_media_discoverer_t* p_mdis);

/**
 * Query if media service discover object is running.
 *
 * \param p_mdis media service discover object
 * \return true if running, false if not
 *
 * \libvlc_return_bool
 */
int libvlc_media_discoverer_is_running (libvlc_media_discoverer_t* p_mdis);

/**
 * Get media discoverer services by category
 *
 * \version LibVLC 3.0.0 and later.
 *
 * \param p_inst libvlc instance
 * \param i_cat category of services to fetch
 * \param ppp_services address to store an allocated array of media discoverer
 * services (must be freed with libvlc_media_discoverer_list_release() by
 * the caller) [OUT]
 *
 * \return the number of media discoverer services (0 on error)
 */
size_t libvlc_media_discoverer_list_get (
    libvlc_instance_t* p_inst,
    libvlc_media_discoverer_category_t i_cat,
    libvlc_media_discoverer_description_t*** ppp_services);

/**
 * Release an array of media discoverer services
 *
 * \version LibVLC 3.0.0 and later.
 *
 * \see libvlc_media_discoverer_list_get()
 *
 * \param pp_services array to release
 * \param i_count number of elements in the array
 */
void libvlc_media_discoverer_list_release (
    libvlc_media_discoverer_description_t** pp_services,
    size_t i_count);

/**@} */

/* <vlc/libvlc.h> */
/*****************************************************************************
 * libvlc_events.h:  libvlc_events external API structure
 *****************************************************************************
 * Copyright (C) 1998-2010 VLC authors and VideoLAN
 * $Id $
 *
 * Authors: Filippo Carone <littlejohn@videolan.org>
 *          Pierre d'Herbemont <pdherbemont@videolan.org>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

enum LIBVLC_EVENTS_H = 1;

/**
 * \file
 * This file defines libvlc_event external API
 */

/**
 * \ingroup libvlc_event
 * @{
 */

/**
 * Event types
 */
enum libvlc_event_e
{
    /* Append new event types at the end of a category.
     * Do not remove, insert or re-order any entry.
     * Keep this in sync with lib/event.c:libvlc_event_type_name(). */
    libvlc_MediaMetaChanged = 0,
    libvlc_MediaSubItemAdded = 1,
    libvlc_MediaDurationChanged = 2,
    libvlc_MediaParsedChanged = 3,
    libvlc_MediaFreed = 4,
    libvlc_MediaStateChanged = 5,
    libvlc_MediaSubItemTreeAdded = 6,

    libvlc_MediaPlayerMediaChanged = 256,
    libvlc_MediaPlayerNothingSpecial = 257,
    libvlc_MediaPlayerOpening = 258,
    libvlc_MediaPlayerBuffering = 259,
    libvlc_MediaPlayerPlaying = 260,
    libvlc_MediaPlayerPaused = 261,
    libvlc_MediaPlayerStopped = 262,
    libvlc_MediaPlayerForward = 263,
    libvlc_MediaPlayerBackward = 264,
    libvlc_MediaPlayerEndReached = 265,
    libvlc_MediaPlayerEncounteredError = 266,
    libvlc_MediaPlayerTimeChanged = 267,
    libvlc_MediaPlayerPositionChanged = 268,
    libvlc_MediaPlayerSeekableChanged = 269,
    libvlc_MediaPlayerPausableChanged = 270,
    libvlc_MediaPlayerTitleChanged = 271,
    libvlc_MediaPlayerSnapshotTaken = 272,
    libvlc_MediaPlayerLengthChanged = 273,
    libvlc_MediaPlayerVout = 274,
    libvlc_MediaPlayerScrambledChanged = 275,
    libvlc_MediaPlayerESAdded = 276,
    libvlc_MediaPlayerESDeleted = 277,
    libvlc_MediaPlayerESSelected = 278,
    libvlc_MediaPlayerCorked = 279,
    libvlc_MediaPlayerUncorked = 280,
    libvlc_MediaPlayerMuted = 281,
    libvlc_MediaPlayerUnmuted = 282,
    libvlc_MediaPlayerAudioVolume = 283,
    libvlc_MediaPlayerAudioDevice = 284,
    libvlc_MediaPlayerChapterChanged = 285,

    libvlc_MediaListItemAdded = 512,
    libvlc_MediaListWillAddItem = 513,
    libvlc_MediaListItemDeleted = 514,
    libvlc_MediaListWillDeleteItem = 515,
    libvlc_MediaListEndReached = 516,

    libvlc_MediaListViewItemAdded = 768,
    libvlc_MediaListViewWillAddItem = 769,
    libvlc_MediaListViewItemDeleted = 770,
    libvlc_MediaListViewWillDeleteItem = 771,

    libvlc_MediaListPlayerPlayed = 1024,
    libvlc_MediaListPlayerNextItemSet = 1025,
    libvlc_MediaListPlayerStopped = 1026,

    /**
     * \deprecated Useless event, it will be triggered only when calling
     * libvlc_media_discoverer_start()
     */
    libvlc_MediaDiscovererStarted = 1280,
    /**
     * \deprecated Useless event, it will be triggered only when calling
     * libvlc_media_discoverer_stop()
     */
    libvlc_MediaDiscovererEnded = 1281,

    libvlc_RendererDiscovererItemAdded = 1282,
    libvlc_RendererDiscovererItemDeleted = 1283,

    libvlc_VlmMediaAdded = 1536,
    libvlc_VlmMediaRemoved = 1537,
    libvlc_VlmMediaChanged = 1538,
    libvlc_VlmMediaInstanceStarted = 1539,
    libvlc_VlmMediaInstanceStopped = 1540,
    libvlc_VlmMediaInstanceStatusInit = 1541,
    libvlc_VlmMediaInstanceStatusOpening = 1542,
    libvlc_VlmMediaInstanceStatusPlaying = 1543,
    libvlc_VlmMediaInstanceStatusPause = 1544,
    libvlc_VlmMediaInstanceStatusEnd = 1545,
    libvlc_VlmMediaInstanceStatusError = 1546
}

/**
 * A LibVLC event
 */
struct libvlc_event_t
{
    int type; /**< Event type (see @ref libvlc_event_e) */
    void* p_obj; /**< Object emitting the event */

    /* media descriptor */

    /**< see @ref libvlc_media_parsed_status_t */

    /**< see @ref libvlc_state_t */

    /* media instance */

    /* media list */

    /* media list player */

    /* snapshot taken */

    /* Length changed */

    /* VLM media */

    /* Extra MediaPlayer */
    union _Anonymous_3
    {
        struct _Anonymous_4
        {
            libvlc_meta_t meta_type;
        }

        _Anonymous_4 media_meta_changed;

        struct _Anonymous_5
        {
            libvlc_media_t* new_child;
        }

        _Anonymous_5 media_subitem_added;

        struct _Anonymous_6
        {
            long new_duration;
        }

        _Anonymous_6 media_duration_changed;

        struct _Anonymous_7
        {
            int new_status;
        }

        _Anonymous_7 media_parsed_changed;

        struct _Anonymous_8
        {
            libvlc_media_t* md;
        }

        _Anonymous_8 media_freed;

        struct _Anonymous_9
        {
            int new_state;
        }

        _Anonymous_9 media_state_changed;

        struct _Anonymous_10
        {
            libvlc_media_t* item;
        }

        _Anonymous_10 media_subitemtree_added;

        struct _Anonymous_11
        {
            float new_cache;
        }

        _Anonymous_11 media_player_buffering;

        struct _Anonymous_12
        {
            int new_chapter;
        }

        _Anonymous_12 media_player_chapter_changed;

        struct _Anonymous_13
        {
            float new_position;
        }

        _Anonymous_13 media_player_position_changed;

        struct _Anonymous_14
        {
            libvlc_time_t new_time;
        }

        _Anonymous_14 media_player_time_changed;

        struct _Anonymous_15
        {
            int new_title;
        }

        _Anonymous_15 media_player_title_changed;

        struct _Anonymous_16
        {
            int new_seekable;
        }

        _Anonymous_16 media_player_seekable_changed;

        struct _Anonymous_17
        {
            int new_pausable;
        }

        _Anonymous_17 media_player_pausable_changed;

        struct _Anonymous_18
        {
            int new_scrambled;
        }

        _Anonymous_18 media_player_scrambled_changed;

        struct _Anonymous_19
        {
            int new_count;
        }

        _Anonymous_19 media_player_vout;

        struct _Anonymous_20
        {
            libvlc_media_t* item;
            int index;
        }

        _Anonymous_20 media_list_item_added;

        struct _Anonymous_21
        {
            libvlc_media_t* item;
            int index;
        }

        _Anonymous_21 media_list_will_add_item;

        struct _Anonymous_22
        {
            libvlc_media_t* item;
            int index;
        }

        _Anonymous_22 media_list_item_deleted;

        struct _Anonymous_23
        {
            libvlc_media_t* item;
            int index;
        }

        _Anonymous_23 media_list_will_delete_item;

        struct _Anonymous_24
        {
            libvlc_media_t* item;
        }

        _Anonymous_24 media_list_player_next_item_set;

        struct _Anonymous_25
        {
            char* psz_filename;
        }

        _Anonymous_25 media_player_snapshot_taken;

        struct _Anonymous_26
        {
            libvlc_time_t new_length;
        }

        _Anonymous_26 media_player_length_changed;

        struct _Anonymous_27
        {
            const(char)* psz_media_name;
            const(char)* psz_instance_name;
        }

        _Anonymous_27 vlm_media_event;

        struct _Anonymous_28
        {
            libvlc_media_t* new_media;
        }

        _Anonymous_28 media_player_media_changed;

        struct _Anonymous_29
        {
            libvlc_track_type_t i_type;
            int i_id;
        }

        _Anonymous_29 media_player_es_changed;

        struct _Anonymous_30
        {
            float volume;
        }

        _Anonymous_30 media_player_audio_volume;

        struct _Anonymous_31
        {
            const(char)* device;
        }

        _Anonymous_31 media_player_audio_device;

        struct _Anonymous_32
        {
            libvlc_renderer_item_t* item;
        }

        _Anonymous_32 renderer_discoverer_item_added;

        struct _Anonymous_33
        {
            libvlc_renderer_item_t* item;
        }

        _Anonymous_33 renderer_discoverer_item_deleted;
    }

    _Anonymous_3 u; /**< Type-dependent event description */
}

/**@} */

/* _LIBVLC_EVENTS_H */
/*****************************************************************************
 * libvlc_dialog.h:  libvlc dialog API
 *****************************************************************************
 * Copyright © 2016 VLC authors and VideoLAN
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

enum LIBVLC_DIALOG_H = 1;

struct libvlc_dialog_id;

/**
 * @defgroup libvlc_dialog LibVLC dialog
 * @ingroup libvlc
 * @{
 * @file
 * LibVLC dialog external API
 */

enum libvlc_dialog_question_type
{
    LIBVLC_DIALOG_QUESTION_NORMAL = 0,
    LIBVLC_DIALOG_QUESTION_WARNING = 1,
    LIBVLC_DIALOG_QUESTION_CRITICAL = 2
}

/**
 * Dialog callbacks to be implemented
 */
struct libvlc_dialog_cbs
{
    /**
     * Called when an error message needs to be displayed
     *
     * @param p_data opaque pointer for the callback
     * @param psz_title title of the dialog
     * @param psz_text text of the dialog
     */
    void function (
        void* p_data,
        const(char)* psz_title,
        const(char)* psz_text) pf_display_error;

    /**
     * Called when a login dialog needs to be displayed
     *
     * You can interact with this dialog by calling libvlc_dialog_post_login()
     * to post an answer or libvlc_dialog_dismiss() to cancel this dialog.
     *
     * @note to receive this callback, libvlc_dialog_cbs.pf_cancel should not be
     * NULL.
     *
     * @param p_data opaque pointer for the callback
     * @param p_id id used to interact with the dialog
     * @param psz_title title of the dialog
     * @param psz_text text of the dialog
     * @param psz_default_username user name that should be set on the user form
     * @param b_ask_store if true, ask the user if he wants to save the
     * credentials
     */
    void function (
        void* p_data,
        libvlc_dialog_id* p_id,
        const(char)* psz_title,
        const(char)* psz_text,
        const(char)* psz_default_username,
        bool b_ask_store) pf_display_login;

    /**
     * Called when a question dialog needs to be displayed
     *
     * You can interact with this dialog by calling libvlc_dialog_post_action()
     * to post an answer or libvlc_dialog_dismiss() to cancel this dialog.
     *
     * @note to receive this callback, libvlc_dialog_cbs.pf_cancel should not be
     * NULL.
     *
     * @param p_data opaque pointer for the callback
     * @param p_id id used to interact with the dialog
     * @param psz_title title of the dialog
     * @param psz_text text of the dialog
     * @param i_type question type (or severity) of the dialog
     * @param psz_cancel text of the cancel button
     * @param psz_action1 text of the first button, if NULL, don't display this
     * button
     * @param psz_action2 text of the second button, if NULL, don't display
     * this button
     */
    void function (
        void* p_data,
        libvlc_dialog_id* p_id,
        const(char)* psz_title,
        const(char)* psz_text,
        libvlc_dialog_question_type i_type,
        const(char)* psz_cancel,
        const(char)* psz_action1,
        const(char)* psz_action2) pf_display_question;

    /**
     * Called when a progress dialog needs to be displayed
     *
     * If cancellable (psz_cancel != NULL), you can cancel this dialog by
     * calling libvlc_dialog_dismiss()
     *
     * @note to receive this callback, libvlc_dialog_cbs.pf_cancel and
     * libvlc_dialog_cbs.pf_update_progress should not be NULL.
     *
     * @param p_data opaque pointer for the callback
     * @param p_id id used to interact with the dialog
     * @param psz_title title of the dialog
     * @param psz_text text of the dialog
     * @param b_indeterminate true if the progress dialog is indeterminate
     * @param f_position initial position of the progress bar (between 0.0 and
     * 1.0)
     * @param psz_cancel text of the cancel button, if NULL the dialog is not
     * cancellable
     */
    void function (
        void* p_data,
        libvlc_dialog_id* p_id,
        const(char)* psz_title,
        const(char)* psz_text,
        bool b_indeterminate,
        float f_position,
        const(char)* psz_cancel) pf_display_progress;

    /**
     * Called when a displayed dialog needs to be cancelled
     *
     * The implementation must call libvlc_dialog_dismiss() to really release
     * the dialog.
     *
     * @param p_data opaque pointer for the callback
     * @param p_id id of the dialog
     */
    void function (void* p_data, libvlc_dialog_id* p_id) pf_cancel;

    /**
     * Called when a progress dialog needs to be updated
     *
     * @param p_data opaque pointer for the callback
     * @param p_id id of the dialog
     * @param f_position osition of the progress bar (between 0.0 and 1.0)
     * @param psz_text new text of the progress dialog
     */
    void function (
        void* p_data,
        libvlc_dialog_id* p_id,
        float f_position,
        const(char)* psz_text) pf_update_progress;
}

/**
 * Register callbacks in order to handle VLC dialogs
 *
 * @version LibVLC 3.0.0 and later.
 *
 * @param p_cbs a pointer to callbacks, or NULL to unregister callbacks.
 * @param p_data opaque pointer for the callback
 */
void libvlc_dialog_set_callbacks (
    libvlc_instance_t* p_instance,
    const(libvlc_dialog_cbs)* p_cbs,
    void* p_data);

/**
 * Associate an opaque pointer with the dialog id
 *
 * @version LibVLC 3.0.0 and later.
 */
void libvlc_dialog_set_context (libvlc_dialog_id* p_id, void* p_context);

/**
 * Return the opaque pointer associated with the dialog id
 *
 * @version LibVLC 3.0.0 and later.
 */
void* libvlc_dialog_get_context (libvlc_dialog_id* p_id);

/**
 * Post a login answer
 *
 * After this call, p_id won't be valid anymore
 *
 * @see libvlc_dialog_cbs.pf_display_login
 *
 * @version LibVLC 3.0.0 and later.
 *
 * @param p_id id of the dialog
 * @param psz_username valid and non empty string
 * @param psz_password valid string (can be empty)
 * @param b_store if true, store the credentials
 * @return 0 on success, or -1 on error
 */
int libvlc_dialog_post_login (
    libvlc_dialog_id* p_id,
    const(char)* psz_username,
    const(char)* psz_password,
    bool b_store);

/**
 * Post a question answer
 *
 * After this call, p_id won't be valid anymore
 *
 * @see libvlc_dialog_cbs.pf_display_question
 *
 * @version LibVLC 3.0.0 and later.
 *
 * @param p_id id of the dialog
 * @param i_action 1 for action1, 2 for action2
 * @return 0 on success, or -1 on error
 */
int libvlc_dialog_post_action (libvlc_dialog_id* p_id, int i_action);

/**
 * Dismiss a dialog
 *
 * After this call, p_id won't be valid anymore
 *
 * @see libvlc_dialog_cbs.pf_cancel
 *
 * @version LibVLC 3.0.0 and later.
 *
 * @param p_id id of the dialog
 * @return 0 on success, or -1 on error
 */
int libvlc_dialog_dismiss (libvlc_dialog_id* p_id);

/** @} */

/* LIBVLC_DIALOG_H */
/*****************************************************************************
 * libvlc_vlm.h:  libvlc_* new external API
 *****************************************************************************
 * Copyright (C) 1998-2008 VLC authors and VideoLAN
 * $Id: cfa2d956463056b287cdb0a4faeb46442040a010 $
 *
 * Authors: Clément Stenac <zorglub@videolan.org>
 *          Jean-Paul Saman <jpsaman _at_ m2x _dot_ nl>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

enum LIBVLC_VLM_H = 1;

/** \defgroup libvlc_vlm LibVLC VLM
 * \ingroup libvlc
 * @{
 * \file
 * LibVLC stream output manager external API
 */

/**
 * Release the vlm instance related to the given libvlc_instance_t
 *
 * \param p_instance the instance
 */
void libvlc_vlm_release (libvlc_instance_t* p_instance);

/**
 * Add a broadcast, with one input.
 *
 * \param p_instance the instance
 * \param psz_name the name of the new broadcast
 * \param psz_input the input MRL
 * \param psz_output the output MRL (the parameter to the "sout" variable)
 * \param i_options number of additional options
 * \param ppsz_options additional options
 * \param b_enabled boolean for enabling the new broadcast
 * \param b_loop Should this broadcast be played in loop ?
 * \return 0 on success, -1 on error
 */
int libvlc_vlm_add_broadcast (
    libvlc_instance_t* p_instance,
    const(char)* psz_name,
    const(char)* psz_input,
    const(char)* psz_output,
    int i_options,
    const(char*)* ppsz_options,
    int b_enabled,
    int b_loop);

/**
 * Add a vod, with one input.
 *
 * \param p_instance the instance
 * \param psz_name the name of the new vod media
 * \param psz_input the input MRL
 * \param i_options number of additional options
 * \param ppsz_options additional options
 * \param b_enabled boolean for enabling the new vod
 * \param psz_mux the muxer of the vod media
 * \return 0 on success, -1 on error
 */
int libvlc_vlm_add_vod (
    libvlc_instance_t* p_instance,
    const(char)* psz_name,
    const(char)* psz_input,
    int i_options,
    const(char*)* ppsz_options,
    int b_enabled,
    const(char)* psz_mux);

/**
 * Delete a media (VOD or broadcast).
 *
 * \param p_instance the instance
 * \param psz_name the media to delete
 * \return 0 on success, -1 on error
 */
int libvlc_vlm_del_media (libvlc_instance_t* p_instance, const(char)* psz_name);

/**
 * Enable or disable a media (VOD or broadcast).
 *
 * \param p_instance the instance
 * \param psz_name the media to work on
 * \param b_enabled the new status
 * \return 0 on success, -1 on error
 */
int libvlc_vlm_set_enabled (
    libvlc_instance_t* p_instance,
    const(char)* psz_name,
    int b_enabled);

/**
 * Set the output for a media.
 *
 * \param p_instance the instance
 * \param psz_name the media to work on
 * \param psz_output the output MRL (the parameter to the "sout" variable)
 * \return 0 on success, -1 on error
 */
int libvlc_vlm_set_output (
    libvlc_instance_t* p_instance,
    const(char)* psz_name,
    const(char)* psz_output);

/**
 * Set a media's input MRL. This will delete all existing inputs and
 * add the specified one.
 *
 * \param p_instance the instance
 * \param psz_name the media to work on
 * \param psz_input the input MRL
 * \return 0 on success, -1 on error
 */
int libvlc_vlm_set_input (
    libvlc_instance_t* p_instance,
    const(char)* psz_name,
    const(char)* psz_input);

/**
 * Add a media's input MRL. This will add the specified one.
 *
 * \param p_instance the instance
 * \param psz_name the media to work on
 * \param psz_input the input MRL
 * \return 0 on success, -1 on error
 */
int libvlc_vlm_add_input (
    libvlc_instance_t* p_instance,
    const(char)* psz_name,
    const(char)* psz_input);

/**
 * Set a media's loop status.
 *
 * \param p_instance the instance
 * \param psz_name the media to work on
 * \param b_loop the new status
 * \return 0 on success, -1 on error
 */
int libvlc_vlm_set_loop (
    libvlc_instance_t* p_instance,
    const(char)* psz_name,
    int b_loop);

/**
 * Set a media's vod muxer.
 *
 * \param p_instance the instance
 * \param psz_name the media to work on
 * \param psz_mux the new muxer
 * \return 0 on success, -1 on error
 */
int libvlc_vlm_set_mux (
    libvlc_instance_t* p_instance,
    const(char)* psz_name,
    const(char)* psz_mux);

/**
 * Edit the parameters of a media. This will delete all existing inputs and
 * add the specified one.
 *
 * \param p_instance the instance
 * \param psz_name the name of the new broadcast
 * \param psz_input the input MRL
 * \param psz_output the output MRL (the parameter to the "sout" variable)
 * \param i_options number of additional options
 * \param ppsz_options additional options
 * \param b_enabled boolean for enabling the new broadcast
 * \param b_loop Should this broadcast be played in loop ?
 * \return 0 on success, -1 on error
 */
int libvlc_vlm_change_media (
    libvlc_instance_t* p_instance,
    const(char)* psz_name,
    const(char)* psz_input,
    const(char)* psz_output,
    int i_options,
    const(char*)* ppsz_options,
    int b_enabled,
    int b_loop);

/**
 * Play the named broadcast.
 *
 * \param p_instance the instance
 * \param psz_name the name of the broadcast
 * \return 0 on success, -1 on error
 */
int libvlc_vlm_play_media (
    libvlc_instance_t* p_instance,
    const(char)* psz_name);

/**
 * Stop the named broadcast.
 *
 * \param p_instance the instance
 * \param psz_name the name of the broadcast
 * \return 0 on success, -1 on error
 */
int libvlc_vlm_stop_media (
    libvlc_instance_t* p_instance,
    const(char)* psz_name);

/**
 * Pause the named broadcast.
 *
 * \param p_instance the instance
 * \param psz_name the name of the broadcast
 * \return 0 on success, -1 on error
 */
int libvlc_vlm_pause_media (
    libvlc_instance_t* p_instance,
    const(char)* psz_name);

/**
 * Seek in the named broadcast.
 *
 * \param p_instance the instance
 * \param psz_name the name of the broadcast
 * \param f_percentage the percentage to seek to
 * \return 0 on success, -1 on error
 */
int libvlc_vlm_seek_media (
    libvlc_instance_t* p_instance,
    const(char)* psz_name,
    float f_percentage);

/**
 * Return information about the named media as a JSON
 * string representation.
 *
 * This function is mainly intended for debugging use,
 * if you want programmatic access to the state of
 * a vlm_media_instance_t, please use the corresponding
 * libvlc_vlm_get_media_instance_xxx -functions.
 * Currently there are no such functions available for
 * vlm_media_t though.
 *
 * \param p_instance the instance
 * \param psz_name the name of the media,
 *      if the name is an empty string, all media is described
 * \return string with information about named media, or NULL on error
 */
const(char)* libvlc_vlm_show_media (
    libvlc_instance_t* p_instance,
    const(char)* psz_name);

/**
 * Get vlm_media instance position by name or instance id
 *
 * \param p_instance a libvlc instance
 * \param psz_name name of vlm media instance
 * \param i_instance instance id
 * \return position as float or -1. on error
 */
float libvlc_vlm_get_media_instance_position (
    libvlc_instance_t* p_instance,
    const(char)* psz_name,
    int i_instance);

/**
 * Get vlm_media instance time by name or instance id
 *
 * \param p_instance a libvlc instance
 * \param psz_name name of vlm media instance
 * \param i_instance instance id
 * \return time as integer or -1 on error
 */
int libvlc_vlm_get_media_instance_time (
    libvlc_instance_t* p_instance,
    const(char)* psz_name,
    int i_instance);

/**
 * Get vlm_media instance length by name or instance id
 *
 * \param p_instance a libvlc instance
 * \param psz_name name of vlm media instance
 * \param i_instance instance id
 * \return length of media item or -1 on error
 */
int libvlc_vlm_get_media_instance_length (
    libvlc_instance_t* p_instance,
    const(char)* psz_name,
    int i_instance);

/**
 * Get vlm_media instance playback rate by name or instance id
 *
 * \param p_instance a libvlc instance
 * \param psz_name name of vlm media instance
 * \param i_instance instance id
 * \return playback rate or -1 on error
 */
int libvlc_vlm_get_media_instance_rate (
    libvlc_instance_t* p_instance,
    const(char)* psz_name,
    int i_instance);

/**
 * Get vlm_media instance title number by name or instance id
 * \bug will always return 0
 * \param p_instance a libvlc instance
 * \param psz_name name of vlm media instance
 * \param i_instance instance id
 * \return title as number or -1 on error
 */

/**
 * Get vlm_media instance chapter number by name or instance id
 * \bug will always return 0
 * \param p_instance a libvlc instance
 * \param psz_name name of vlm media instance
 * \param i_instance instance id
 * \return chapter as number or -1 on error
 */

/**
 * Is libvlc instance seekable ?
 * \bug will always return 0
 * \param p_instance a libvlc instance
 * \param psz_name name of vlm media instance
 * \param i_instance instance id
 * \return 1 if seekable, 0 if not, -1 if media does not exist
 */

/**
 * Get libvlc_event_manager from a vlm media.
 * The p_event_manager is immutable, so you don't have to hold the lock
 *
 * \param p_instance a libvlc instance
 * \return libvlc_event_manager
 */
libvlc_event_manager_t* libvlc_vlm_get_event_manager (
    libvlc_instance_t* p_instance);

/** @} */

/* <vlc/libvlc_vlm.h> */
/*****************************************************************************
 * deprecated.h:  libvlc deprecated API
 *****************************************************************************
 * Copyright (C) 1998-2008 VLC authors and VideoLAN
 * $Id: 27323a434498604ca281900c3e4087a42d22a5d8 $
 *
 * Authors: Clément Stenac <zorglub@videolan.org>
 *          Jean-Paul Saman <jpsaman@videolan.org>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

enum LIBVLC_DEPRECATED_H = 1;

/**
 * \ingroup libvlc libvlc_media_player
 * @{
 */

/**
 * Get movie fps rate
 *
 * This function is provided for backward compatibility. It cannot deal with
 * multiple video tracks. In LibVLC versions prior to 3.0, it would also fail
 * if the file format did not convey the frame rate explicitly.
 *
 * \deprecated Consider using libvlc_media_tracks_get() instead.
 *
 * \param p_mi the Media Player
 * \return frames per second (fps) for this playing movie, or 0 if unspecified
 */
float libvlc_media_player_get_fps (libvlc_media_player_t* p_mi);

/** end bug */

/**
 * \deprecated Use libvlc_media_player_set_nsobject() instead
 */
void libvlc_media_player_set_agl (libvlc_media_player_t* p_mi, uint drawable);

/**
 * \deprecated Use libvlc_media_player_get_nsobject() instead
 */
uint libvlc_media_player_get_agl (libvlc_media_player_t* p_mi);

/**
 * \deprecated Use libvlc_track_description_list_release() instead
 */
void libvlc_track_description_release (
    libvlc_track_description_t* p_track_description);

/** @}*/

/**
 * \ingroup libvlc libvlc_video
 * @{
 */

/**
 * Get current video height.
 * \deprecated Use libvlc_video_get_size() instead.
 *
 * \param p_mi the media player
 * \return the video pixel height or 0 if not applicable
 */
int libvlc_video_get_height (libvlc_media_player_t* p_mi);

/**
 * Get current video width.
 * \deprecated Use libvlc_video_get_size() instead.
 *
 * \param p_mi the media player
 * \return the video pixel width or 0 if not applicable
 */
int libvlc_video_get_width (libvlc_media_player_t* p_mi);

/**
 * Get the description of available titles.
 *
 * \param p_mi the media player
 * \return list containing description of available titles.
 * It must be freed with libvlc_track_description_list_release()
 */
libvlc_track_description_t* libvlc_video_get_title_description (
    libvlc_media_player_t* p_mi);

/**
 * Get the description of available chapters for specific title.
 *
 * \param p_mi the media player
 * \param i_title selected title
 * \return list containing description of available chapter for title i_title.
 * It must be freed with libvlc_track_description_list_release()
 */
libvlc_track_description_t* libvlc_video_get_chapter_description (
    libvlc_media_player_t* p_mi,
    int i_title);

/**
 * Set new video subtitle file.
 * \deprecated Use libvlc_media_player_add_slave() instead.
 *
 * \param p_mi the media player
 * \param psz_subtitle new video subtitle file
 * \return the success status (boolean)
 */
int libvlc_video_set_subtitle_file (
    libvlc_media_player_t* p_mi,
    const(char)* psz_subtitle);

/**
 * Toggle teletext transparent status on video output.
 * \deprecated use libvlc_video_set_teletext() instead.
 *
 * \param p_mi the media player
 */
void libvlc_toggle_teletext (libvlc_media_player_t* p_mi);

/** @}*/

/**
 * \ingroup libvlc libvlc_audio
 * @{
 */

/**
 * Backward compatibility stub. Do not use in new code.
 * \deprecated Use libvlc_audio_output_device_list_get() instead.
 * \return always 0.
 */
int libvlc_audio_output_device_count (
    libvlc_instance_t* p_instance,
    const(char)* psz_audio_output);

/**
 * Backward compatibility stub. Do not use in new code.
 * \deprecated Use libvlc_audio_output_device_list_get() instead.
 * \return always NULL.
 */
char* libvlc_audio_output_device_longname (
    libvlc_instance_t* p_instance,
    const(char)* psz_output,
    int i_device);

/**
 * Backward compatibility stub. Do not use in new code.
 * \deprecated Use libvlc_audio_output_device_list_get() instead.
 * \return always NULL.
 */
char* libvlc_audio_output_device_id (
    libvlc_instance_t* p_instance,
    const(char)* psz_audio_output,
    int i_device);

/**
 * Stub for backward compatibility.
 * \return always -1.
 */
int libvlc_audio_output_get_device_type (libvlc_media_player_t* p_mi);

/**
 * Stub for backward compatibility.
 */
void libvlc_audio_output_set_device_type (
    libvlc_media_player_t* p_mp,
    int device_type);

/** @}*/

/**
 * \ingroup libvlc libvlc_media
 * @{
 */

/**
 * Parse a media.
 *
 * This fetches (local) art, meta data and tracks information.
 * The method is synchronous.
 *
 * \deprecated This function could block indefinitely.
 *             Use libvlc_media_parse_with_options() instead
 *
 * \see libvlc_media_parse_with_options
 * \see libvlc_media_get_meta
 * \see libvlc_media_get_tracks_info
 *
 * \param p_md media descriptor object
 */
void libvlc_media_parse (libvlc_media_t* p_md);

/**
 * Parse a media.
 *
 * This fetches (local) art, meta data and tracks information.
 * The method is the asynchronous of libvlc_media_parse().
 *
 * To track when this is over you can listen to libvlc_MediaParsedChanged
 * event. However if the media was already parsed you will not receive this
 * event.
 *
 * \deprecated You can't be sure to receive the libvlc_MediaParsedChanged
 *             event (you can wait indefinitely for this event).
 *             Use libvlc_media_parse_with_options() instead
 *
 * \see libvlc_media_parse
 * \see libvlc_MediaParsedChanged
 * \see libvlc_media_get_meta
 * \see libvlc_media_get_tracks_info
 *
 * \param p_md media descriptor object
 */
void libvlc_media_parse_async (libvlc_media_t* p_md);

/**
 * Return true is the media descriptor object is parsed
 *
 * \deprecated This can return true in case of failure.
 *             Use libvlc_media_get_parsed_status() instead
 *
 * \see libvlc_MediaParsedChanged
 *
 * \param p_md media descriptor object
 * \return true if media object has been parsed otherwise it returns false
 *
 * \libvlc_return_bool
 */
int libvlc_media_is_parsed (libvlc_media_t* p_md);

/**
 * Get media descriptor's elementary streams description
 *
 * Note, you need to call libvlc_media_parse() or play the media at least once
 * before calling this function.
 * Not doing this will result in an empty array.
 *
 * \deprecated Use libvlc_media_tracks_get() instead
 *
 * \param p_md media descriptor object
 * \param tracks address to store an allocated array of Elementary Streams
 *        descriptions (must be freed by the caller) [OUT]
 *
 * \return the number of Elementary Streams
 */
int libvlc_media_get_tracks_info (
    libvlc_media_t* p_md,
    libvlc_media_track_info_t** tracks);

/** @}*/

/**
 * \ingroup libvlc libvlc_media_list
 * @{
 */

int libvlc_media_list_add_file_content (
    libvlc_media_list_t* p_ml,
    const(char)* psz_uri);

/** @}*/

/**
 * \ingroup libvlc libvlc_media_discoverer
 * @{
 */

/**
 * \deprecated Use libvlc_media_discoverer_new() and libvlc_media_discoverer_start().
 */
libvlc_media_discoverer_t* libvlc_media_discoverer_new_from_name (
    libvlc_instance_t* p_inst,
    const(char)* psz_name);

/**
 * Get media service discover object its localized name.
 *
 * \deprecated Useless, use libvlc_media_discoverer_list_get() to get the
 * longname of the service discovery.
 *
 * \param p_mdis media discover object
 * \return localized name or NULL if the media_discoverer is not started
 */
char* libvlc_media_discoverer_localized_name (
    libvlc_media_discoverer_t* p_mdis);

/**
 * Get event manager from media service discover object.
 *
 * \deprecated Useless, media_discoverer events are only triggered when calling
 * libvlc_media_discoverer_start() and libvlc_media_discoverer_stop().
 *
 * \param p_mdis media service discover object
 * \return event manager object.
 */
libvlc_event_manager_t* libvlc_media_discoverer_event_manager (
    libvlc_media_discoverer_t* p_mdis);

/** @}*/

/**
 * \ingroup libvlc libvlc_core
 * @{
 */

/**
 * Waits until an interface causes the instance to exit.
 * You should start at least one interface first, using libvlc_add_intf().
 *
 * \param p_instance the instance
 * \warning This function wastes one thread doing basically nothing.
 * libvlc_set_exit_handler() should be used instead.
 */
void libvlc_wait (libvlc_instance_t* p_instance);

/** @}*/

/**
 * \ingroup libvlc_core
 * \defgroup libvlc_log_deprecated LibVLC logging (legacy)
 * @{
 */

/** This structure is opaque. It represents a libvlc log iterator */
struct libvlc_log_iterator_t;

struct libvlc_log_message_t
{
    int i_severity; /* 0=INFO, 1=ERR, 2=WARN, 3=DBG */
    const(char)* psz_type; /* module type */
    const(char)* psz_name; /* module name */
    const(char)* psz_header; /* optional header */
    const(char)* psz_message; /* message */
}

/**
 * Always returns minus one.
 * This function is only provided for backward compatibility.
 *
 * \param p_instance ignored
 * \return always -1
 */
uint libvlc_get_log_verbosity (const(libvlc_instance_t)* p_instance);

/**
 * This function does nothing.
 * It is only provided for backward compatibility.
 *
 * \param p_instance ignored
 * \param level ignored
 */
void libvlc_set_log_verbosity (libvlc_instance_t* p_instance, uint level);

/**
 * This function does nothing useful.
 * It is only provided for backward compatibility.
 *
 * \param p_instance libvlc instance
 * \return an unique pointer or NULL on error
 */
libvlc_log_t* libvlc_log_open (libvlc_instance_t* p_instance);

/**
 * Frees memory allocated by libvlc_log_open().
 *
 * \param p_log libvlc log instance or NULL
 */
void libvlc_log_close (libvlc_log_t* p_log);

/**
 * Always returns zero.
 * This function is only provided for backward compatibility.
 *
 * \param p_log ignored
 * \return always zero
 */
uint libvlc_log_count (const(libvlc_log_t)* p_log);

/**
 * This function does nothing.
 * It is only provided for backward compatibility.
 *
 * \param p_log ignored
 */
void libvlc_log_clear (libvlc_log_t* p_log);

/**
 * This function does nothing useful.
 * It is only provided for backward compatibility.
 *
 * \param p_log ignored
 * \return an unique pointer or NULL on error or if the parameter was NULL
 */
libvlc_log_iterator_t* libvlc_log_get_iterator (const(libvlc_log_t)* p_log);

/**
 * Frees memory allocated by libvlc_log_get_iterator().
 *
 * \param p_iter libvlc log iterator or NULL
 */
void libvlc_log_iterator_free (libvlc_log_iterator_t* p_iter);

/**
 * Always returns zero.
 * This function is only provided for backward compatibility.
 *
 * \param p_iter ignored
 * \return always zero
 */
int libvlc_log_iterator_has_next (const(libvlc_log_iterator_t)* p_iter);

/**
 * Always returns NULL.
 * This function is only provided for backward compatibility.
 *
 * \param p_iter libvlc log iterator or NULL
 * \param p_buf ignored
 * \return always NULL
 */
libvlc_log_message_t* libvlc_log_iterator_next (
    libvlc_log_iterator_t* p_iter,
    libvlc_log_message_t* p_buf);

/** @}*/

/**
 * \ingroup libvlc
 * \defgroup libvlc_playlist LibVLC playlist (legacy)
 * @deprecated Use @ref libvlc_media_list instead.
 * @{
 * \file
 * LibVLC deprecated playlist API
 */

/**
 * Start playing (if there is any item in the playlist).
 *
 * Additionnal playlist item options can be specified for addition to the
 * item before it is played.
 *
 * \param p_instance the playlist instance
 * \param i_id the item to play. If this is a negative number, the next
 *        item will be selected. Otherwise, the item with the given ID will be
 *        played
 * \param i_options the number of options to add to the item
 * \param ppsz_options the options to add to the item
 */
void libvlc_playlist_play (
    libvlc_instance_t* p_instance,
    int i_id,
    int i_options,
    char** ppsz_options);

/** @}*/

/* _LIBVLC_DEPRECATED_H */
