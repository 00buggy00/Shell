//
//  Variable.swift
//  
//
//  Created by Myles La Verne Schultz on 4/18/21.
//

struct Variable {
    struct var_context {
        var name: String
        var scope: Int
        var flags: var_context_flags
        var up: UnsafeMutablePointer<var_context>
        var down: UnsafeMutablePointer<var_context>
        var table: HASH_TABLE
    }
    struct var_context_flags: OptionSet {
        let rawValue: Int8
        
        static let VC_HASLOCAL = var_context_flags(rawValue: 1 << 0)
        static let VC_HASTMPVAR = var_context_flags(rawValue: 1 << 1)
        static let VC_FUNCENV = var_context_flags(rawValue: 1 << 2)
        static let VC_BLTNENV = var_context_flags(rawValue: 1 << 3)
        static let VC_TEMPENV = var_context_flags(rawValue: 1 << 4)
        
        static let VC_TEMPFLAGS: var_context_flags = [.VC_FUNCENV, .VC_BLTNENV, .VC_TEMPENV]
        
        func vc_isfuncenv(_ context: var_context) -> Bool { context.flags.contains(.VC_FUNCENV) }
        func vc_isbltnenv(_ context: var_context) -> Bool { context.flags.contains(.VC_BLTNENV) }
        func vc_istempenv(_ context: var_context) -> Bool { context.flags.contains(.VC_TEMPFLAGS) && context.flags.contains(.VC_TEMPENV) }
        func vc_istempscrope(_ context: var_context) -> Bool { context.flags.contains([.VC_TEMPENV, .VC_BLTNENV]) }
        func vc_haslocals(_ context: var_context) -> Bool { context.flags.contains(.VC_HASLOCAL) }
        func vc_hastmpvars(_ context: var_context) -> Bool { context.flags.contains(.VC_HASTMPVAR) }
    }
    
    func sh_var_value_func_t(variable: UnsafeMutablePointer<SHELL_VAR>) -> UnsafeMutablePointer<SHELL_VAR> {}
    func sh_var_assign_func_t(variable: UnsafeMutablePointer<SHELL_VAR>, foo: String, bar: arrayind_t, baz: String) -> UnsafeMutablePointer<SHELL_VAR> {}
    
    /* "For the future" */
    //  FIXME: - What is this supposed to replace?
    enum _value {
        case string
        case integer
        case function
        case COMMAND
        case ARRAY
        case HASH_TABLE
        case double
        case longDouble
        case variable
        case opaque
    }
    
    //  SHELL_VAR == variable
    struct SHELL_VAR {
        var name: String        /* Symbol provided by the user */
        var value: _value?      /* Value that is retured */
        var exportstr: String   /* String for the environment */
        var dynamic_value: UnsafeMutablePointer<sh_var_value_func_t>
        var assign_func: UnsafeMutablePointer<sh_var_assign_func_t>
        var attributes: Attribute     /* export, readonly, array, invisible... (flags) */
        var context:
    }
    //  VARLIST == _vlist
    struct VARLIST {
        var list: LinkedList<SHELL_VAR>
        var list_size: Int
        var list_len: Int
    }
    
    /* The various attributes that a given variable can have.   *
     * Frist, the user-visible attributes                       */
    struct Attribute: OptionSet {
        let rawValue: Int32
        
        /*  User visible attributes */
        static let att_exported =   Attribute(rawValue: 1 << 0)   /* export to environment */
        static let att_readonly =   Attribute(rawValue: 1 << 1)   /* cannot change */
        static let att_array =      Attribute(rawValue: 1 << 3)   /* value is an array */
        static let att_function =   Attribute(rawValue: 1 << 4)   /* value is a function */
        static let att_integer =    Attribute(rawValue: 1 << 5)   /* internal representation is int */
        static let att_local =      Attribute(rawValue: 1 << 6)   /* variable is local to a function */
        static let att_assoc =      Attribute(rawValue: 1 << 7)   /* variable is an associative array */
        static let att_trace =      Attribute(rawValue: 1 << 8)   /* function is traced with DEBUG trap */
        static let att_uppercase =  Attribute(rawValue: 1 << 9)   /* word converted to uppercase on assignement */
        static let att_lowercase =  Attribute(rawValue: 1 << 10)  /* word converted to lowercase on assignment */
        static let att_capcase =    Attribute(rawValue: 1 << 11)  /* word capatalized on assignment */
        static let att_nameref =    Attribute(rawValue: 1 << 12)  /* word is a name reference */
        
        static let user_attrs: Attribute =
            [
                .att_exported,
                .att_readonly,
                .att_integer,
                .att_local,
                .att_trace,
                .att_uppercase,
                .att_lowercase,
                .att_capcase,
                .att_nameref
            ]
        
        /* Masks for all user attributes */
        static let attmask_user =   Attribute(rawValue: 0x0000fff)
        
        /* Internal attributes for bookkeeping */
        static let att_invisible =  Attribute(rawValue: 1 << 13)  /* cannot see */
        static let att_nounset =    Attribute(rawValue: 1 << 14)  /* cannot unset */
        static let att_noassign =     Attribute(rawValue: 1 << 15)  /* assignement not allowed */
        static let att_imported =   Attribute(rawValue: 1 << 16)  /* came from environment */
        static let att_special =    Attribute(rawValue: 1 << 17)  /* requires special handling */
        static let att_nofree =     Attribute(rawValue: 1 << 18)  /* do not free value on unset */
        static let att_regenerate = Attribute(rawValue: 1 << 19)  /* regenerate when exported */
        
        /* Masks for all internal attributes */
        static let attmask_int =    Attribute(rawValue: 0x00ff000)
        
        /* Internal attributes used for variable scoping */
        static let att_tempvar =    Attribute(rawValue: 1 << 21)  /* variable came from the temp environment */
        static let att_propagate =  Attribute(rawValue: 1 << 22)  /* propagate to previous scope */
        
        /* Mask for all variable scoping */
        static let attmask_scope = Attribute(rawValue: 0x0F00000)
        
        func exported_p(_ variable: SHELL_VAR) -> Bool { variable.attributes.contains(.att_exported) }
        func readonly_p(_ variable: SHELL_VAR) -> Bool { variable.attributes.contains(.att_readonly) }
        func array_p(_ variable: SHELL_VAR) -> Bool { variable.attributes.contains(.att_array) }
        func function_p(_ variable: SHELL_VAR) -> Bool { variable.attributes.contains(.att_function) }
        func integer_p(_ variable: SHELL_VAR) -> Bool { variable.attributes.contains(.att_integer) }
        func local_p(_ variable: SHELL_VAR) -> Bool { variable.attributes.contains(.att_local) }
        func assoc_p(_ variable: SHELL_VAR) -> Bool { variable.attributes.contains(.att_assoc) }
        func trace_p(_ variable: SHELL_VAR) -> Bool { variable.attributes.contains(.att_trace) }
        func uppercase_p(_ variable: SHELL_VAR) -> Bool { variable.attributes.contains(.att_uppercase) }
        func lowercase_p(_ variable: SHELL_VAR) -> Bool { variable.attributes.contains(.att_lowercase) }
        func capcase_p(_ variable: SHELL_VAR) -> Bool { variable.attributes.contains(.att_capcase) }
        func nameref_p(_ variable: SHELL_VAR) -> Bool { variable.attributes.contains(.att_nameref) }
        
        func invisible_p(_ variable: SHELL_VAR) -> Bool { variable.attributes.contains(.att_invisible) }
        func non_unsettable_p(_ variable: SHELL_VAR) -> Bool { variable.attributes.contains(.att_nounset) }
        func noassign_p(_ variable: SHELL_VAR) -> Bool { variable.attributes.contains(.att_noassign) }
        func imported_p(_ variable: SHELL_VAR) -> Bool { variable.attributes.contains(.att_imported) }
        func specialvar_p(_ variable: SHELL_VAR) -> Bool { variable.attributes.contains(.att_special) }
        func nofree_p(_ variable: SHELL_VAR) -> Bool { variable.attributes.contains(.att_nofree) }
        func regen_p(_ variable: SHELL_VAR) -> Bool { variable.attributes.contains(.att_regenerate) }
        
        func tempvar_p(_ variable: SHELL_VAR) -> Bool { variable.attributes.contains(.att_tempvar) }
        func propagate_p(_ variable: SHELL_VAR) -> Bool { variable.attributes.contains(.att_propagate) }
        
        /* Variable names: lvalues */
        func name_cell(_ variable: SHELL_VAR) -> String { variable.name }
        
        /* Accessing variable values: rvalues */
        func value_cell(_ variable: SHELL_VAR) -> _value? { variable.value }
        func function_cell(_ variable: SHELL_VAR) -> _value? {
            /* Cast to COMMAND * in original source     *
             * I'm not sure if _value should stay aenum */
            variable.value
        }
        func array_cell(_ variable: SHELL_VAR) -> _value? {
            /* As for function, array is cast to        *
             * ARRAY * which was orignally a union      */
            variable.value
        }
        func assoc_cell(_ variable: SHELL_VAR) -> _value? {
            /* Cast to a HASH_TABLE *                   */
            variable.value
        }
        func nameref_cell(_ variable: SHELL_VAR) -> _value? {
            variable.value
        }
        
        /* 8 levels of nameref indirection allowed */
        /* These are redundant due to use of pointers previously. *
         * I plan on not using pointers for value at this time so *
         * I will plan to simplify these later                    */
        let NAMEREF_MAX = 8
        
        func var_isset(_ variable: SHELL_VAR) -> Bool { variable.value != nil }
        func var_isunset(_ variable: SHELL_VAR) -> Bool { variable.value == nil }
        func isnull(_ variable: SHELL_VAR) -> Bool { variable.value == nil }
        
        /* Assigning variable values: lvalues */
        func var_setvalue( _ variable: inout SHELL_VAR, string: _value) { variable.value = string }
        func var_setfunc(_ variable: inout SHELL_VAR, function: _value) { variable.value = function }
        func var_setarray(_ variable: inout SHELL_VAR, array: _value) { variable.value = array }
        func var_setassoc(_ variable: inout SHELL_VAR, assoc: _value) { variable.value = assoc }
        func var_setref(_ variable: inout SHELL_VAR, string: _value) { variable.value = string }
        
        /* Make VAR be auto_exported */
        func set_auto_export(_ variable: inout SHELL_VAR) {
            variable.attributes = variable.attributes.union(.att_exported)
            array_needs_making = 1  //  FIXME:  Don't think we need this
        }
        func SETVARATTR(_ variable: inout SHELL_VAR, attr: Attribute, undo: Bool) {
            undo == false ? (variable.attributes = variable.attributes.union(attr)) : (variable.attributes = variable.attributes.intersection(attr))
        }
        func VSETATTR(_ variable: inout SHELL_VAR, attr: Attribute) { variable.attributes = variable.attributes.union(attr) }
        func VUNSETATTR(_ variable: inout SHELL_VAR, attr: Attribute) { variable.attributes = variable.attributes.subtracting(attr) }
        func VGETFLAGS(_ variable: inout SHELL_VAR) -> Attribute { variable.attributes }
        func VSETFLAGS(_ variable: inout SHELL_VAR, flags: Attribute) { variable.attributes = flags }
        func VCLRFLAGS(_ variable: inout SHELL_VAR) { variable.attributes = [] }
        
        /*  Operations on `exportstr` of SHELL_VAR  */
        func CLEAR_EXPORTSTR(_ variable: inout SHELL_VAR) { variable.exportstr = "" }
        func COPY_EXPORTSTR(_ variable: inout SHELL_VAR) { if variable.exportstr != "" { savestring(variable.exportstr) } }
        func SET_EXPORTSTR(_ variable: inout SHELL_VAR, value: String) { variable.exportstr = value }
        //  FIXME: - save exportstr does the same thing as set exportstr currently
        func SAVE_EXPORTSTR(_ variable: inout SHELL_VAR, value: String) { variable.exportstr = value }
        
    }
}
