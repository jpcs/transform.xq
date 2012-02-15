# library module: http://snelson.org.uk/functions/transform
  
# transform.xq  

An extensible transformation library for XQuery 3.0.
   


Author:  John Snelson  
Version:  0.9 
## Functions

### mode\#1
    mode(
      $rules as (function(xs:string) as function(*)?)*) as  function(node()*) as item()*

  Returns a mode function, which can be called to perform the transformation  specified by the rules passed in as arguments. Call tfm:rule(), or  tfm:predicate-rule() to create rules to pass into this function.   


#### Params

* rules as  (function(xs:string) as function(\*)?)\*: The sequence of rules to use to create the mode, in increasing precedence.


#### Returns
*  function(node()\*) as item()\*: A mode function.

### extend-mode\#2
    extend-mode(
      $mode as function(node()*) as item()*,
      $rules as (function(xs:string) as function(*)?)*) as  function(node()*) as item()*

  Returns a new mode function, which extends the transformation from the  mode argument, adding the additional rules in higher precedence.  Call tfm:rule(), or tfm:predicate-rule() to create rules to pass into  this function.   


#### Params

* mode as  function(node()\*) as item()\*: The mode to extend.

* rules as  (function(xs:string) as function(\*)?)\*: The sequence of rules to use to create the mode, in increasing precedence.


#### Returns
*  function(node()\*) as item()\*: A mode function.

### named-mode\#1
    named-mode(
      $name as xs:string*) as  function(node()*) as item()*

  Returns a mode function constructed from the functions  annotated with the given name in the %tfm:rule() annotation.   

 If reflection capabilites are not supported by your XQuery  implementation. 
#### Params

* name as  xs:string\*: The name(s) used in the %tfm:rule() annotation in the functions for the mode to construct.


#### Returns
*  function(node()\*) as item()\*: A mode function.

### named-extend-mode\#2
    named-extend-mode(
      $mode as function(node()*) as item()*,
      $name as xs:string*) as  function(node()*) as item()*

  Returns a new mode function, which extends the transformation from the  mode argument, adding additional rules constructed from the functions  annotated with the given name in the %tfm:rule() annotation.   

 If reflection capabilites are not supported by your XQuery  implementation. 
#### Params

* mode as  function(node()\*) as item()\*: The mode to extend.

* name as  xs:string\*: The name(s) used in the %tfm:rule() annotation in the functions for the mode to construct.


#### Returns
*  function(node()\*) as item()\*: A mode function.

### named-rules\#1
    named-rules(
      $name as xs:string*) as  (function(xs:string) as function(*)?)*

  Returns a sequence of rules constructed from the functions  annotated with the given name(s) in the %tfm:rule() annotation.   

 If reflection capabilites are not supported by your XQuery  implementation. 
#### Params

* name as  xs:string\*: The name(s) used in the %tfm:rule() annotation in the functions for the mode to construct.


#### Returns
*  (function(xs:string) as function(\*)?)\*: A sequence of rules wrapped as functions, in increasing order by the priority from the %tfm:rule annotation.

### rule\#2
    rule(
      $pattern as xs:string,
      $action as function(*)) as  function(xs:string) as function(*)?

  Returns a rule constructed from the pattern and action specified.  Rules are represented as a single function.   

Action functions should take between 2 and 3 arguments. If the function takes  fewer arguments, they are the arguments at the start of this list:  
    
* $mode as function(node()\*) as item()\*: The mode function, used to re-apply the mode on further nodes.    
* $context as node(): The context node that the rule is executed on.    
* $next-match as function() as item()\*: The next-mode function.  
   


#### Params

* pattern as  xs:string: The pattern string that the rule must match.

* action as  function(\*): The action function to be executed when the rule is matched.


#### Returns
*  function(xs:string) as function(\*)?: The rule wrapped as a function.

### rule\#3
    rule(
      $pattern as xs:string,
      $action as function(*),
      $resolver as item()) as  function(xs:string) as function(*)?

  Returns a rule constructed from the pattern and action specified.  Rules are represented as a single function.   

Action functions should take between 2 and 3 arguments. If the function takes  fewer arguments, they are the arguments at the start of this list:  
    
* function(node()\*) as item()\*: The mode function, used to re-apply the mode on further nodes.    
* node(): The context node that the rule is executed on.    
* $next-match as function() as item()\*: The next-mode function.  
   


#### Params

* pattern as  xs:string: The pattern string that the rule must match.

* action as  function(\*): The action function to be executed when the rule is matched.

* resolver as  item(): Either an element from which to take the namespace bindings, or a function of type function(xs:string) as xs:QName.


#### Returns
*  function(xs:string) as function(\*)?: The rule wrapped as a function.

### predicate-rule\#2
    predicate-rule(
      $predicate as function(*),
      $action as function(*)) as  function(xs:string) as function(*)?

  Returns a rule constructed from the predicate function and action specified.  Rules are represented as a single function.   

The predicate function takes a node as an argument and returns true if the node matches.  Returning false or raising an error is considered a non-match. Typing the argument of the function  provided with a SequenceType of element(), attribute(), etc. will result in the predicate function  being optimized by only attempting to be matched against that type of name.
   

Action functions should take between 2 and 3 arguments. If the function takes  fewer arguments, they are the arguments at the start of this list:  
    
* function(node()\*) as item()\*: The mode function, used to re-apply the mode on further nodes.    
* node(): The context node that the rule is executed on.    
* $next-match as function() as item()\*: The next-mode function.  
   


#### Params

* predicate as  function(\*)

* action as  function(\*): The action function to be executed when the rule is matched.


#### Returns
*  function(xs:string) as function(\*)?: The rule wrapped as a function.

### resolver\#1
    resolver(
      $element as element()) as  function(xs:string) as xs:QName

  Returns a prefix resolver function that resolves prefixes by looking them up in the namespace  bindings of the element.   


#### Params

* element as  element(): The element whose namespace bindings should be used.


#### Returns
*  function(xs:string) as xs:QName: The resolver function.

### pattern\#1
    pattern(
      $pattern as xs:string) as  function(*)

  Compiles the pattern given in the string argument to a predicate function,  which takes a node as the argument, and returns true if the node matches  the pattern. If the predicate returns false or raises an error, the node  does not match the pattern.   


#### Params

* pattern as  xs:string: The pattern string.


#### Returns
*  function(\*): The predicate function.

### pattern\#2
    pattern(
      $pattern as xs:string,
      $resolver as item()) as  function(*)

  Compiles the pattern given in the string argument to a predicate function,  which takes a node as the argument, and returns true if the node matches  the pattern. If the predicate returns false or raises an error, the node  does not match the pattern.   


#### Params

* pattern as  xs:string: The pattern string.

* resolver as  item(): Either an element from which to take the namespace bindings, or a function of type function(xs:string) as xs:QName which resolves a lexical QName to an xs:QName.


#### Returns
*  function(\*): The predicate function.





*Generated by [xquerydoc](https://github.com/xquery/xquerydoc)*
