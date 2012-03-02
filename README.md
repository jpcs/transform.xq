# library module: http://snelson.org.uk/functions/transform
  
# transform.xq  

An extensible transformation library for XQuery 3.0.
   


Author:  John Snelson  
Version:  0.9 

## Table of Contents

* Functions: [tfm:mode\#1](#func_tfm_mode_1), [tfm:extend-mode\#2](#func_tfm_extend-mode_2), [tfm:named-mode\#1](#func_tfm_named-mode_1), [tfm:named-extend-mode\#2](#func_tfm_named-extend-mode_2), [tfm:named-rules\#1](#func_tfm_named-rules_1), [tfm:rule\#2](#func_tfm_rule_2), [tfm:rule\#3](#func_tfm_rule_3), [tfm:predicate-rule\#2](#func_tfm_predicate-rule_2), [tfm:resolver\#1](#func_tfm_resolver_1), [tfm:pattern\#1](#func_tfm_pattern_1), [tfm:pattern\#2](#func_tfm_pattern_2), [tfm:param\#2](#func_tfm_param_2), [tfm:param\#3](#func_tfm_param_3), [tfm:get-param\#2](#func_tfm_get-param_2)


## Functions

### <a name="func_tfm_mode_1"/> tfm:mode\#1
```xquery
tfm:mode(
  $rules as (function(xs:string) as function(*)?)*
) as  function(node()*,function() as item()*?) as item()*
```
  Returns a mode function, which can be called to perform the transformation  specified by the rules passed in as arguments. Call tfm:rule(), or  tfm:predicate-rule() to create rules to pass into this function.   

Mode functions take the following arguments:  
    
* $nodes as node()\*: The context nodes to execute the mode on.    
* $params as function() as item()\*?: An rbtree.xq map of parameters passed to the mode,  or the empty sequence. Can be constructed by tfm:param#2 and tfm:param#3.  
   


#### Params

* $rules as  (function(xs:string) as function(\*)?)\*: The sequence of rules to use to create the mode, in increasing precedence.


#### Returns
*  function(node()\*,function() as item()\*?) as item()\*: A mode function.

### <a name="func_tfm_extend-mode_2"/> tfm:extend-mode\#2
```xquery
tfm:extend-mode(
  $mode as function(node()*,function() as item()*?) as item()*,
  $rules as (function(xs:string) as function(*)?)*
) as  function(node()*,function() as item()*?) as item()*
```
  Returns a new mode function, which extends the transformation from the  mode argument, adding the additional rules in higher precedence.  Call tfm:rule(), or tfm:predicate-rule() to create rules to pass into  this function.   

Mode functions take the following arguments:  
    
* $nodes as node()\*: The context nodes to execute the mode on.    
* $params as function() as item()\*?: An rbtree.xq map of parameters passed to the mode,  or the empty sequence. Can be constructed by tfm:param#2 and tfm:param#3.  
   


#### Params

* $mode as  function(node()\*,function() as item()\*?) as item()\*: The mode to extend.

* $rules as  (function(xs:string) as function(\*)?)\*: The sequence of rules to use to create the mode, in increasing precedence.


#### Returns
*  function(node()\*,function() as item()\*?) as item()\*: A mode function.

### <a name="func_tfm_named-mode_1"/> tfm:named-mode\#1
```xquery
tfm:named-mode(
  $name as xs:string*
) as  function(node()*,function() as item()*?) as item()*
```
  Returns a mode function constructed from the functions  annotated with the given name in the %tfm:rule() annotation.   

Mode functions take the following arguments:  
    
* $nodes as node()\*: The context nodes to execute the mode on.    
* $params as function() as item()\*?: An rbtree.xq map of parameters passed to the mode,  or the empty sequence. Can be constructed by tfm:param#2 and tfm:param#3.  
   


#### Params

* $name as  xs:string\*: The name(s) used in the %tfm:rule() annotation in the functions for the mode to construct.


#### Returns
*  function(node()\*,function() as item()\*?) as item()\*: A mode function.

#### Errors
 If reflection capabilites are not supported by your XQuery  implementation.   

### <a name="func_tfm_named-extend-mode_2"/> tfm:named-extend-mode\#2
```xquery
tfm:named-extend-mode(
  $mode as function(node()*,function() as item()*?) as item()*,
  $name as xs:string*
) as  function(node()*,function() as item()*?) as item()*
```
  Returns a new mode function, which extends the transformation from the  mode argument, adding additional rules constructed from the functions  annotated with the given name in the %tfm:rule() annotation.   

Mode functions take the following arguments:  
    
* $nodes as node()\*: The context nodes to execute the mode on.    
* $params as function() as item()\*?: An rbtree.xq map of parameters passed to the mode,  or the empty sequence. Can be constructed by tfm:param#2 and tfm:param#3.  
   


#### Params

* $mode as  function(node()\*,function() as item()\*?) as item()\*: The mode to extend.

* $name as  xs:string\*: The name(s) used in the %tfm:rule() annotation in the functions for the mode to construct.


#### Returns
*  function(node()\*,function() as item()\*?) as item()\*: A mode function.

#### Errors
 If reflection capabilites are not supported by your XQuery  implementation.   

### <a name="func_tfm_named-rules_1"/> tfm:named-rules\#1
```xquery
tfm:named-rules(
  $name as xs:string*
) as  (function(xs:string) as function(*)?)*
```
  Returns a sequence of rules constructed from the functions  annotated with the given name(s) in the %tfm:rule() annotation.   


#### Params

* $name as  xs:string\*: The name(s) used in the %tfm:rule() annotation in the functions for the mode to construct.


#### Returns
*  (function(xs:string) as function(\*)?)\*: A sequence of rules wrapped as functions, in increasing order by the priority from the %tfm:rule annotation.

#### Errors
 If reflection capabilites are not supported by your XQuery  implementation. 

### <a name="func_tfm_rule_2"/> tfm:rule\#2
```xquery
tfm:rule(
  $pattern as xs:string,
  $action as function(*)
) as  function(xs:string) as function(*)?
```
  Returns a rule constructed from the pattern and action specified.  Rules are represented as a single function.   

Action functions should take between 2 and 3 arguments. If the function takes  fewer arguments, they are the arguments at the start of this list:  
    
* $mode as function(node()\*) as item()\*:  The mode function, used to re-apply the mode on further nodes. Can alternately be specified as type  function(node()\*,function() as item()\*?) as item()\*, which accepts parameters as the second argument.    
* $context as node(): The context node that the rule is executed on.    
* $params as function() as item()\*?: An rbtree.xq map of parameters passed to the mode,  or the empty sequence. Can be constructed by tfm:param#2 and tfm:param#3.    
* $next-match as function() as item()\*: The next-mode function.  Can alternately be specified as type function(function() as item()\*?) as item()\*,  which accepts parameters as the second argument.  
   


#### Params

* $pattern as  xs:string: The pattern string that the rule must match.

* $action as  function(\*): The action function to be executed when the rule is matched.


#### Returns
*  function(xs:string) as function(\*)?: The rule wrapped as a function.

### <a name="func_tfm_rule_3"/> tfm:rule\#3
```xquery
tfm:rule(
  $pattern as xs:string,
  $action as function(*),
  $resolver as item()
) as  function(xs:string) as function(*)?
```
  Returns a rule constructed from the pattern and action specified.  Rules are represented as a single function.   

Action functions should take between 2 and 3 arguments. If the function takes  fewer arguments, they are the arguments at the start of this list:  
    
* $mode as function(node()\*) as item()\*:  The mode function, used to re-apply the mode on further nodes. Can alternately be specified as type  function(node()\*,function() as item()\*?) as item()\*, which accepts parameters as the second argument.    
* $context as node(): The context node that the rule is executed on.    
* $params as function() as item()\*?: An rbtree.xq map of parameters passed to the mode,  or the empty sequence. Can be constructed by tfm:param#2 and tfm:param#3.    
* $next-match as function() as item()\*: The next-mode function.  Can alternately be specified as type function(function() as item()\*?) as item()\*,  which accepts parameters as the second argument.  
   


#### Params

* $pattern as  xs:string: The pattern string that the rule must match.

* $action as  function(\*): The action function to be executed when the rule is matched.

* $resolver as  item(): Either an element from which to take the namespace bindings, or a function of type function(xs:string) as xs:QName.


#### Returns
*  function(xs:string) as function(\*)?: The rule wrapped as a function.

### <a name="func_tfm_predicate-rule_2"/> tfm:predicate-rule\#2
```xquery
tfm:predicate-rule(
  $predicate as function(*),
  $action as function(*)
) as  function(xs:string) as function(*)?
```
  Returns a rule constructed from the predicate function and action specified.  Rules are represented as a single function.   

The predicate function takes a node as an argument and returns true if the node matches.  Returning false or raising an error is considered a non-match. Typing the argument of the function  provided with a SequenceType of element(), attribute(), etc. will result in the predicate function  being optimized by only attempting to be matched against that type of name.
   

Action functions should take between 2 and 3 arguments. If the function takes  fewer arguments, they are the arguments at the start of this list:  
    
* $mode as function(node()\*) as item()\*:  The mode function, used to re-apply the mode on further nodes. Can alternately be specified as type  function(node()\*,function() as item()\*?) as item()\*, which accepts parameters as the second argument.    
* $context as node(): The context node that the rule is executed on.    
* $params as function() as item()\*?: An rbtree.xq map of parameters passed to the mode,  or the empty sequence. Can be constructed by tfm:param#2 and tfm:param#3.    
* $next-match as function() as item()\*: The next-mode function.  Can alternately be specified as type function(function() as item()\*?) as item()\*,  which accepts parameters as the second argument.  
   


#### Params

* $predicate as  function(\*)

* $action as  function(\*): The action function to be executed when the rule is matched.


#### Returns
*  function(xs:string) as function(\*)?: The rule wrapped as a function.

### <a name="func_tfm_resolver_1"/> tfm:resolver\#1
```xquery
tfm:resolver(
  $element as element()
) as  function(xs:string) as xs:QName
```
  Returns a prefix resolver function that resolves prefixes by looking them up in the namespace  bindings of the element.   


#### Params

* $element as  element(): The element whose namespace bindings should be used.


#### Returns
*  function(xs:string) as xs:QName: The resolver function.

### <a name="func_tfm_pattern_1"/> tfm:pattern\#1
```xquery
tfm:pattern(
  $pattern as xs:string
) as  function(*)
```
  Compiles the pattern given in the string argument to a predicate function,  which takes a node as the argument, and returns true if the node matches  the pattern. If the predicate returns false or raises an error, the node  does not match the pattern.   


#### Params

* $pattern as  xs:string: The pattern string.


#### Returns
*  function(\*): The predicate function.

### <a name="func_tfm_pattern_2"/> tfm:pattern\#2
```xquery
tfm:pattern(
  $pattern as xs:string,
  $resolver as item()
) as  function(*)
```
  Compiles the pattern given in the string argument to a predicate function,  which takes a node as the argument, and returns true if the node matches  the pattern. If the predicate returns false or raises an error, the node  does not match the pattern.   


#### Params

* $pattern as  xs:string: The pattern string.

* $resolver as  item(): Either an element from which to take the namespace bindings, or a function of type function(xs:string) as xs:QName which resolves a lexical QName to an xs:QName.


#### Returns
*  function(\*): The predicate function.

### <a name="func_tfm_param_2"/> tfm:param\#2
```xquery
tfm:param(
  $name as xs:string,
  $value as item()*
) as  function() as item()*
```
  Helper function to allow simple construction of a parameters map suitable for passing  to a mode function, given the parameter name and value.   


#### Params

* $name as  xs:string: The parameter name.

* $value as  item()\*: The parameter value.


#### Returns
*  function() as item()\*: An rbtree.xq map containing the parameter.

### <a name="func_tfm_param_3"/> tfm:param\#3
```xquery
tfm:param(
  $params as function() as item()*?,
  $name as xs:string,
  $value as item()*
) as  function() as item()*
```
  Helper function to allow simple construction of a parameters map suitable for passing  to a mode function, given an existing map, the parameter name, and value.   


#### Params

* $params as  function() as item()\*?: An existing rbtree.xq map of parameters, or the empty sequence.

* $name as  xs:string: The parameter name.

* $value as  item()\*: The parameter value.


#### Returns
*  function() as item()\*: An rbtree.xq map containing the original parameters augmeneted with the new parameter.

### <a name="func_tfm_get-param_2"/> tfm:get-param\#2
```xquery
tfm:get-param(
  $params as function() as item()*?,
  $name as xs:string
) as  item()*
```
  Helper function to retrive a parameter from a parameters map.   


#### Params

* $params as  function() as item()\*?: An existing rbtree.xq map of parameters, or the empty sequence.

* $name as  xs:string: The parameter name.


#### Returns
*  item()\*: The parameter value, or empty sequence if not found.





*Generated by [xquerydoc](https://github.com/xquery/xquerydoc)*
