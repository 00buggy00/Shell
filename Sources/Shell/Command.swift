//
//  Command.swift
//  
//
//  Created by Myles La Verne Schultz on 5/8/21.
//

import Foundation


/// Instructions describing what kind of thing to do for a redirection.
enum r_instruction {
  case r_output_direction, r_input_direction, r_inputa_direction, r_appending_to, r_reading_until, r_reading_string, r_duplicating_input, r_duplicating_output, r_deblank_reading_until, r_close_this, r_err_and_out, r_input_output, r_output_force, r_duplicating_input_word, r_duplicating_output_word, r_move_input, r_move_output, r_move_input_word, r_move_output_word, r_append_err_and_out
}
/// Command Types:
enum command_type {
    case cm_for, cm_case, cm_while, cm_if, cm_simple, cm_select, cm_connection, cm_function_def, cm_until, cm_group, cm_arith, cm_cond, cm_arith_for, cm_subshell, cm_coproc
}
/// A structure which represents a word.
struct WORD_DESC {
    /// Zero terminated string.
    var word: UnsafeMutablePointer<Int8>
    /// Flags associated with this word.
    var flags: Int
}
/// A linked list of words.
struct WORD_LIST {
    var next: UnsafeMutablePointer<WORD_LIST>
    var word: UnsafeMutablePointer<WORD_DESC>
}
/** What a redirection descriptor looks like.  If the redirection instruction
   is ri_duplicating_input or ri_duplicating_output, use DEST, otherwise
   use the file in FILENAME.  Out-of-range descriptors are identified by a
   negative DEST. */
enum REDIRECTEE {
    /// Place to redirect REDIRECTOR to, or ...
    case dest(Int)
    /// filename to redirect to.
    case filename(UnsafeMutablePointer<WORD_DESC>)
}
struct REDIRECT {
    /// Next element, or NULL.
    var next: UnsafeMutablePointer<REDIRECT>
    var redirector: REDIRECTEE
    /// Private flags for this redirection */
    var rflags: Int
    /// Flag value for `open'.
    var flags: Int
    /// What to do with the information.
    var instruction: r_instruction
    /// File descriptor or filename */
    var redirectee: REDIRECTEE
    /// The word that appeared in <<foo.
    var here_doc_eof: UnsafeMutablePointer<Int8>
}
protocol COMMAND {
    /// FOR CASE WHILE IF CONNECTION or SIMPLE.
    var type: command_type { get set }
    /// Flags controlling execution environment
    var flags: Int { get set }
    /// line number the command starts on
    var line: Int { get set }
    /// Special redirects for FOR CASE, etc.
    var redirects: REDIRECT { get set }
}
