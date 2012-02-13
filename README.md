# http://snelson.org.uk/functions/transform  library module

  # transform.xq  An extensible transformation library for XQuery 3.0.

   

Author:  John Snelson  

Version:  0.9 

## Variables

### $magic
    $magic as  element()



## Functions

### mode\#1
    mode(
      $rules as (function(xs:string) as function(*)?)*) as  function(node()*) as item()*

  Returns a mode function, which can be called to perform the transformation  specified by the rules passed in as arguments. Call tfm:rule(), or  tfm:predicate-rule() to create rules to pass into this function.   

#### Params
* rules as  (function(xs:string) as function(*)?)*: The sequence of rules to use to create the mode, in increasing precedence.

#### Returns
*  function(node()*) as item()*: A mode function.

### extend-mode\#2
    extend-mode(
      $mode as function(node()*) as item()*,
      $rules as (function(xs:string) as function(*)?)*) as  function(node()*) as item()*

  Returns a new mode function, which extends the transformation from the  mode argument, adding the additional rules in higher precedence.  Call tfm:rule(), or tfm:predicate-rule() to create rules to pass into  this function.   

#### Params
* mode as  function(node()*) as item()*: The mode to extend.
* rules as  (function(xs:string) as function(*)?)*: The sequence of rules to use to create the mode, in increasing precedence.

#### Returns
*  function(node()*) as item()*: A mode function.

### named-mode\#1
    named-mode(
      $name as xs:string*) as  function(node()*) as item()*

  Returns a mode function constructed from the functions  annotated with the given name in the %tfm:rule() annotation.   

 If reflection capabilites are not supported by your XQuery  implementation. #### Params
* name as  xs:string*: The name(s) used in the %tfm:rule() annotation in the functions for the mode to construct.

#### Returns
*  function(node()*) as item()*: A mode function.

### named-extend-mode\#2
    named-extend-mode(
      $mode as function(node()*) as item()*,
      $name as xs:string*) as  function(node()*) as item()*

  Returns a new mode function, which extends the transformation from the  mode argument, adding additional rules constructed from the functions  annotated with the given name in the %tfm:rule() annotation.   

 If reflection capabilites are not supported by your XQuery  implementation. #### Params
* mode as  function(node()*) as item()*: The mode to extend.
* name as  xs:string*: The name(s) used in the %tfm:rule() annotation in the functions for the mode to construct.

#### Returns
*  function(node()*) as item()*: A mode function.

### named-rules\#1
    named-rules(
      $name as xs:string*) as  (function(xs:string) as function(*)?)*

  Returns a sequence of rules constructed from the functions  annotated with the given name(s) in the %tfm:rule() annotation.   

 If reflection capabilites are not supported by your XQuery  implementation. #### Params
* name as  xs:string*: The name(s) used in the %tfm:rule() annotation in the functions for the mode to construct.

#### Returns
*  (function(xs:string) as function(*)?)*: A sequence of rules wrapped as functions, in increasing order by the priority from the %tfm:rule annotation.

### rule\#2
    rule(
      $pattern as xs:string,
      $action as function(
          function(node()*) as item()*,
          node()
        ) as item()*) as  function(xs:string) as function(*)?

#### Params
* pattern as  xs:string
* action as  function(
      function(node()*) as item()*,
      node()
    ) as item()*

#### Returns
*  function(xs:string) as function(*)?

### rule\#3
    rule(
      $pattern as xs:string,
      $action as function(
          function(node()*) as item()*,
          node()
        ) as item()*,
      $resolver as item()) as  function(xs:string) as function(*)?

#### Params
* pattern as  xs:string
* action as  function(
      function(node()*) as item()*,
      node()
    ) as item()*
* resolver as  item()

#### Returns
*  function(xs:string) as function(*)?

### predicate-rule\#2
    predicate-rule(
      $predicate as function(*),
      $action as function(
          function(node()*) as item()*,
          node()
        ) as item()*) as  function(xs:string) as function(*)?

 Returns the predicate and action wrapped as a single item 

#### Params
* predicate as  function(*)
* action as  function(
      function(node()*) as item()*,
      node()
    ) as item()*

#### Returns
*  function(xs:string) as function(*)?

### resolver\#1
    resolver(
      $element as element()) as  function(xs:string) as xs:QName

#### Params
* element as  element()

#### Returns
*  function(xs:string) as xs:QName

### pattern\#1
    pattern(
      $pattern as xs:string) as  function(*)

#### Params
* pattern as  xs:string

#### Returns
*  function(*)

### pattern\#2
    pattern(
      $pattern as xs:string,
      $resolver as item()) as  function(*)

#### Params
* pattern as  xs:string
* resolver as  item()

#### Returns
*  function(*)





generated by xquerydoc <https://github.com/xquery/xquerydoc>