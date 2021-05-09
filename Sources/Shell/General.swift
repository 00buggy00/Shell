//
//  general.swift
//  
//
//  Created by Myles La Verne Schultz on 5/8/21.
//

import Foundation


let sh_builtin_func_t: (UnsafeMutablePointer<WORD_LIST>) -> () = {
    (list: UnsafeMutablePointer<WORD_LIST>) in
    //  FIXME:  Bogus filler
    list.deallocate()
}
