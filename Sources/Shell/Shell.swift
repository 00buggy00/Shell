//
//  Shell.swift
//
//
//  Created by Myles La Verne Schultz on 4/11/21.
//

import Foundation


let EOF_Reached: Int = 0

let NO_PIPE = -1
let REDIRECT_BOTH = -2

let NO_VARIABLE = -1

/* Values that can be returned by execute_command (). */
let EXECUTION_FAILURE = 1
let EXECUTION_SUCCESS = 0

/* Usage messages by builtins result in a return status of 2. */
let EX_BADUSAGE = 2

let EX_MISCERROR = 2

/* Special exit statuses used by the shell, internally and externally. */
let EX_RETRYFAIL = 124
let EX_WEXPCOMSUB = 125
let EX_BINARY_FILE = 126
let EX_NOEXEC = 126
let EX_NOINPUT = 126
let EX_NOTFOUND = 127

/// all special error values are > this.
let EX_SHERRBASE = 256

/// shell syntax error
let EX_BADSYNTAX = 257
/// syntax error in usage
let EX_USAGE = 258
/// redirection failed
let EX_REDIRFAIL = 259
/// variable assignment error
let EX_BADASSIGN = 260
/// word expansion failed
let EX_EXPFAIL = 261
/// fall back to disk command from builtin
let EX_DISKFALLBACK = 262

/* Flag values that control parameter pattern substitution. */
let MATCH_ANY = 0x000
let MATCH_BEG = 0x001
let MATCH_END = 0x002

let MATCH_TYPEMASK = 0x003

let MATCH_GLOBREP = 0x010
let MATCH_QUOTED = 0x020
let MATCH_ASSIGNRHS = 0x040
let MATCH_STARSUB = 0x080

/* Some needed external declarations. */
//  FIXME: made optional avoid initialization
var shell_environment: UnsafeMutableBufferPointer<Int8>? = nil
//  FIXME: made optional avoid initialization
var rest_of_args: UnsafeMutablePointer<WORD_LIST>? = nil

/* Generalized global variables. */
var command_execution_string: String = ""

var debugging_mode: Int = 0
var executing: Int = 0
var login_shell: Int = 0
var interactive: Int = 0
var interactive_shell: Int = 0
var startup_state: Int = 0
var reading_shell_script: Int = 0
/*  "Non-zero means that this shell has already been run *
 *  i.e.  you should call shell_reinitialize() if you   *
 *  need to start afresh."                               */
//  FIXME: Consider making a Bool.
var shell_initialized: Int = 0
var bash_argv_initialized: Int = 0
var subshell_environment: Int = 0
var current_command_number: Int = 0
var indirection_level: Int = 0
var shell_compatibility_level: Int = 0
var running_under_emacs: Int = 0

var posixly_correct: Int = 0
var no_line_editing: Int = 0

var shell_name: String = ""
var current_host_name: String = ""

var subshell_argc: Int = 0
var subshell_argv: UnsafeMutableBufferPointer<Int8>? = nil
var subshell_envp: UnsafeMutableBufferPointer<Int8>? = nil

/* variables managed using shopt */
var hup_on_exit: Int = 0
var check_jobs_at_exit: Int = 0
var autocd: Int = 0
var check_window_size: Int = 0

/* from version.c */
var build_version:  Int = 0
var patch_level: Int = 0
var dist_version: UnsafeMutablePointer<Int8>? = nil
var release_status: UnsafeMutablePointer<Int8>? = nil

var locale_mb_cur_max: Int = 0
var locale_utf8locale: Int = 0

/** Structure to pass around that holds a bitmap of file descriptors
   to close, and the size of that structure.  Used in execute_cmd.c. */
struct fd_bitmap {
    var size: Int
    var bitmap: UnsafeMutablePointer<Int8>
}
let FD_BITMAP_SIZE: Int = 32
let CTTLESC = "\001"
//  FIXME:  No equivalent in Swift, should be removed, additional backslash used to avoid error message
let CTLNUL = "\\177"

var global_command: UnsafeMutablePointer<COMMAND>? = nil

//  FIXME: Move to `Command`
enum CommandExecutionResult {
    case success
    case failure
}

//  FIXME: Move to `builtins`
enum BuiltInsError {
    case badusage
    case miscellaneous
}

enum ShellExitStatus {
    case retryFail
    case wExpComSub  /*  expansion or expression?  */
    case binaryFile
    case noExecution
    case noInput
    case notFound
    //  Special errors
    case sherrBase
    case badSyntax          /*  Shell syntax error  */
    case usage              /*  syntax error in usage  */
    case redirectionFailure /*  redirection failed  */
    case badAssign          /*  variable assignment error  */
    case expansionFailure   /*  word expansion failed  */
    case diskFallback       /*  fall back to disk command from builtin  */
}

struct PatternMatch: OptionSet {
    let rawValue: Int8
    
    static let any                = PatternMatch(rawValue: 1 << 0)
    static let bet                = PatternMatch(rawValue: 1 << 1)
    static let end                = PatternMatch(rawValue: 1 << 2)
    static let typeMask           = PatternMatch(rawValue: 1 << 3)
    static let globRepresentation = PatternMatch(rawValue: 1 << 4)
    static let Quoted             = PatternMatch(rawValue: 1 << 5)
    static let AssignRHS          = PatternMatch(rawValue: 1 << 6)
    static let starSubstitution   = PatternMatch(rawValue: 1 << 7)
}

struct FileDesriptorBitmap {
    var size: Int
    var bitmap: UnsafeMutableRawBufferPointer
    
    var bitmapDefaultSize: Int {
        return 32
    }
    
    //  FIXME: find appropriate replacement values
    static let CTLESC: Int8 = 0 /* defined in command.h as '\001'  */
    static let CTLNUL: Int8 = 1 /* defined in command.h as '\177'  */
}

//  Information about the use
//  Consider moving to separate User.swift file
struct user_info {
    var uid = uid_t()
    var euid = uid_t()
    var gid = gid_t()
    var egid = gid_t()
    var username = String()
    ///  Should this point to a `Shell`?
    var shell = UnsafeMutablePointer<Int8>(bitPattern: 0)
    var homeDirectory = URL(string: "")
}

var currentUser = user_info()
    
//  Store partial parsing state when using commands such as PROMPT_COMMAND
//  and bash_execute_unix_command
struct sh_parser_state_t {
    var parser_state: Int
    var token_state: UnsafeMutablePointer<Int>
    var token: String
    var token_buffer_size: Int
    
    /* input line state -- line number saved elsewhere */
    //  FIXME: Should it not be here?
    var input_line_terminator: Int
    var eof_encountered: Int
    
    var prompt_string_pointer: UnsafeMutablePointer<String>
    
    /* History state affecting or modified by the parser */
    var current_command_line_count: Int
    var remember_on_history: Int
    var history_expansion_inhibited: Int
    
    /* execution state possibly modfied by the parser */
    var last_command_exit_value: Int
    var pipestatus: [Any]   //  FIXME: `pipestatus` should be a typed value
    var last_shell_builtin: UnsafeMutablePointer<sh_builtin_func_t>
    var this_shell_builtin: UnsafeMutablePointer<sh_builtin_func_t>
    
    /* Flags state affecting the parser */
    var expand_aliases: Int
    var echo_input_at_read: Int
    var need_here_doc: Int
    var here_doc_first_line: Int
    
    /* Structures affecting the parser */
    static let HEREDOC_MAX = 16
    /// Max size is equal to `HEREDOC_MAX`
    var redir_stack: Array<REDIRECT>
}
    
struct sh_input_line_state_t {
    var input_line: String
    var input_line_index: size_t
    var input_line_size: size_t
    var input_line_len: size_t
    var input_property: String
    var input_propsize: size_t
}
    
func parser_remaining_input(parameters: Any...) {}
func sh_parser_state(state: UnsafeMutablePointer<sh_parser_state_t>) -> UnsafeMutablePointer<sh_parser_state_t> {}
func save_input_line_state(state: UnsafeMutablePointer<sh_parser_state_t>) -> UnsafeMutablePointer<sh_parser_state_t> {}
func restore_input_line_state(state: UnsafeMutablePointer<sh_input_line_state_t>) {}
