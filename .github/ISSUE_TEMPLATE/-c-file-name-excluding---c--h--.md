---
name: <C file name excluding ".c/.h">
about: Template to aid translation of C files
title: ''
labels: first pass translation
assignees: ''

---

## alias
### **Definition**
Short synopsis and important information...
### **Dependencies
    <filename>.h
### **Typedefs**
  *<implementation_name>* = **<internal_name>**: <type>
    * <e1>
    * <e2>
    * <en...>
  <input(s)...> -> **<function_name>** -> <result(s)...>
### **Macros**
#### **Header**
  **macro_constant**
  **macro_function**
#### **Implementation**
  **macro_constant**
  **macro_function**
### **Variables**
#### **Header**
##### **extern**
  **<variable_name**: <type>
#### **Implementation**
##### **Intern**
  **<variable_name**: <type>
###### **static**
  **<variable_name**: <type>
### **Functions**
#### **Header**
##### **Extern**
  <input(s)...> -> **<function_name>** -> <return(s)...>
#### **Implementation**
##### **Internal
  <input(s)...> -> **<function_name>** -> <return(s)...>
###### **static**
  <input(s)...> -> **<function_name>** -> <return(s)...>
