xquery version "3.0";

(:
 : Copyright (c) 2011 John Snelson
 :
 : Licensed under the Apache License, Version 2.0 (the "License");
 : you may not use this file except in compliance with the License.
 : You may obtain a copy of the License at
 :
 :     http://www.apache.org/licenses/LICENSE-2.0
 :
 : Unless required by applicable law or agreed to in writing, software
 : distributed under the License is distributed on an "AS IS" BASIS,
 : WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 : See the License for the specific language governing permissions and
 : limitations under the License.
 :)

(:~
 : <h1>transform.xq</h1>
 : <p>An extensible transformation library for XQuery 3.0.</p>
 :
 : @author John Snelson
 : @version 0.9
 :)
module namespace tfm = "http://snelson.org.uk/functions/transform";

import module namespace pat = "http://snelson.org.uk/functions/patterns" at "lib/compile_pattern.xq";
import module namespace map = "http://snelson.org.uk/functions/map" at "lib/map.xq";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

(:~ Magic value to get a mode function to return its map of rules :)
declare %private variable $tfm:magic as element() := <magic/>;

(:~
 : Returns a mode function, which can be called to perform the transformation
 : specified by the rules passed in as arguments. Call tfm:rule(), or
 : tfm:predicate-rule() to create rules to pass into this function.
 :
 : @param $rules: The sequence of rules to use to create the mode, in
 : increasing precedence.
 : @return A mode function.
 :
 : @see rule#2, rule#3, predicate-rule#2
 :)
declare function tfm:mode(
  $rules as (function(xs:string) as function(*)?)*
) as function(node()*) as item()*
{
  let $map := fold-left(tfm:add-rule#2, map:create(), $rules)
  return tfm:run-mode($map,?)
};

(:~
 : Returns a new mode function, which extends the transformation from the
 : mode argument, adding the additional rules in higher precedence.
 : Call tfm:rule(), or tfm:predicate-rule() to create rules to pass into
 : this function.
 :
 : @param $mode: The mode to extend.
 : @param $rules: The sequence of rules to use to create the mode, in
 : increasing precedence.
 : @return A mode function.
 :
 : @see rule#2, rule#3, predicate-rule#2
 :)
declare function tfm:extend-mode(
  $mode as function(node()*) as item()*,
  $rules as (function(xs:string) as function(*)?)*
) as function(node()*) as item()*
{
  let $map := $mode($tfm:magic)
  let $map := fold-left(tfm:add-rule#2, $map, $rules)
  return tfm:run-mode($map,?)
};

(:~
 : Returns a mode function constructed from the functions
 : annotated with the given name in the %tfm:rule() annotation.
 :
 : @param $name: The name(s) used in the %tfm:rule() annotation in the
 : functions for the mode to construct.
 : @return A mode function.
 :
 : @error If reflection capabilites are not supported by your XQuery
 : implementation.
 :)
declare function tfm:named-mode(
  $name as xs:string*
) as function(node()*) as item()*
{
  tfm:mode(tfm:named-rules($name))
};

(:~
 : Returns a new mode function, which extends the transformation from the
 : mode argument, adding additional rules constructed from the functions
 : annotated with the given name in the %tfm:rule() annotation.
 :
 : @param $mode: The mode to extend.
 : @param $name: The name(s) used in the %tfm:rule() annotation in the
 : functions for the mode to construct.
 : @return A mode function.
 :
 : @error If reflection capabilites are not supported by your XQuery
 : implementation.
 :)
declare function tfm:named-extend-mode(
  $mode as function(node()*) as item()*,
  $name as xs:string*
) as function(node()*) as item()*
{
  tfm:extend-mode($mode, tfm:named-rules($name))
};

(:~
 : Returns a sequence of rules constructed from the functions
 : annotated with the given name(s) in the %tfm:rule() annotation.
 :
 : @param $name: The name(s) used in the %tfm:rule() annotation in the
 : functions for the mode to construct.
 : @return A sequence of rules wrapped as functions, in
 : increasing order by the priority from the %tfm:rule annotation.
 :
 : @error If reflection capabilites are not supported by your XQuery
 : implementation.
 :)
declare function tfm:named-rules(
  $name as xs:string*
) as (function(xs:string) as function(*)?)*
{
  let $functions := tfm:functions()
  let $annotation := tfm:annotation()
  return
    if(empty($functions) or empty($annotation)) then
      error(xs:QName("tfm:NOTSUPPORTED"), "Named modes are not supported on your platform")
    else
      for $f in $functions()
      let $a := $annotation($f, xs:QName("tfm:rule"))
      where $a[1] = $name
      order by number($a[3]) ascending empty least
      return
        if(empty($a[2])) then error(xs:QName("tfm:NOPATTERN"),
          "No pattern specified on function: " || function-name($f) || "#" || function-arity($f))
        else tfm:rule($a[2], $f)
};

declare %private function tfm:functions() as function() as function(*)*?
{
  (
    (: Add fn:function-lookup() calls for platform specific versions of the function
       to fetch all available functions. :)
    function-lookup(fn:QName("http://marklogic.com/xdmp","xdmp:functions"),0)
  )[1]
};

declare %private function tfm:annotation() as function(function(*),xs:QName) as item()*?
{
  (
    (: Add fn:function-lookup() calls for platform specific versions of the function
       to retrieve an annotation value from a function item. :)
    function-lookup(fn:QName("http://marklogic.com/xdmp","xdmp:annotation"),2)
  )[1]
};

declare %private function tfm:add-rule($map,$rule)
{
  let $predicate := $rule("predicate")
  return
    if(not($predicate instance of function(*))) then
      error(xs:QName("tfm:BADPREDICATE"), "The predicate should be a function")
    else if(function-arity($predicate) ne 1) then
      error(xs:QName("tfm:BADPREDICATE"), "The predicate should have arity 1")
    else
      let $map := if($predicate instance of function(element()) as xs:boolean)
        then tfm:add($map,"element",$rule) else $map
      let $map := if($predicate instance of function(attribute()) as xs:boolean)
        then tfm:add($map,"attribute",$rule) else $map
      let $map := if($predicate instance of function(document-node()) as xs:boolean)
        then tfm:add($map,"document",$rule) else $map
      let $map := if($predicate instance of function(comment()) as xs:boolean)
        then tfm:add($map,"comment",$rule) else $map
      let $map := if($predicate instance of function(text()) as xs:boolean)
        then tfm:add($map,"text",$rule) else $map
      let $map := if($predicate instance of function(processing-instruction()) as xs:boolean)
        then tfm:add($map,"pi",$rule) else $map
      (: TBD namespace nodes - jpcs :)
      return $map
};

declare %private function tfm:add($map,$key,$rule)
{
  map:put($map,$key,($rule,map:get($map,$key)))
};

declare %private function tfm:run-mode(
  $map as function() as item()+,
  $nodes as node()*
) as item()*
{
  if($nodes[1] is $tfm:magic) then $map
  else tfm:_run-mode($map,$nodes)
};

declare %private function tfm:_run-mode(
  $map as function() as item()+,
  $nodes as node()*
) as item()*
{
  let $mode := tfm:_run-mode($map,?)
  for $node in $nodes
  let $rules :=
    typeswitch($node)
      case element() return map:get($map,"element")
      case attribute() return map:get($map,"attribute")
      case document-node() return map:get($map,"document")
      case comment() return map:get($map,"comment")
      case text() return map:get($map,"text")
      case processing-instruction() return map:get($map,"pi")
      default return error(xs:QName("tfm:NAMESPACENODE"),
        "Transformation of namespace nodes not currently supported")
  return
    tfm:next-match($mode,$rules,$node)
};

declare %private function tfm:next-match(
  $mode as function(node()*) as item()*,
  $rules as (function(xs:string) as function(*)?)*,
  $node as node()
) as item()*
{
  let $r :=
    fold-left(function($found, $r) {
        if(exists($found)) then ($found,$r)
        else if(try { $r("predicate")($node) } catch * { false() }) then $r
        else ()
      }, (), $rules)
  let $matched-rule := head($r)
  let $next-match := function() { tfm:next-match($mode,tail($r),$node) }
  return
    (: TBD template parameters - jpcs :)
    if(exists($matched-rule)) then
      $matched-rule("action")($mode,$node,$next-match)
    else (: default rule :)
      typeswitch($node)
        case element() | document-node() return $node/node() ! $mode(.)
        case attribute() | text() return text { $node }
        default return ()
};

(:~
 : Returns a rule constructed from the pattern and action specified.
 : Rules are represented as a single function.
 :
 : <p>Action functions should take between 2 and 3 arguments. If the function takes
 : fewer arguments, they are the arguments at the start of this list:
 : <ul>
 :   <li>$mode as function(node()*) as item()*: The mode function, used to re-apply the mode on further nodes.</li>
 :   <li>$context as node(): The context node that the rule is executed on.</li>
 :   <li>$next-match as function() as item()*: The next-mode function.</li>
 : </ul></p>
 :
 : @param $pattern: The pattern string that the rule must match.
 : @param $action: The action function to be executed when the rule is matched.
 : @return The rule wrapped as a function.
 :)
declare function tfm:rule(
  $pattern as xs:string,
  $action as function(*)
) as function(xs:string) as function(*)?
{
  tfm:predicate-rule(tfm:pattern($pattern), $action)
};

(:~
 : Returns a rule constructed from the pattern and action specified.
 : Rules are represented as a single function.
 :
 : <p>Action functions should take between 2 and 3 arguments. If the function takes
 : fewer arguments, they are the arguments at the start of this list:
 : <ul>
 :   <li>function(node()*) as item()*: The mode function, used to re-apply the mode on further nodes.</li>
 :   <li>node(): The context node that the rule is executed on.</li>
 :   <li>$next-match as function() as item()*: The next-mode function.</li>
 : </ul></p>
 :
 : @param $pattern: The pattern string that the rule must match.
 : @param $action: The action function to be executed when the rule is matched.
 : @param $resolver: Either an element from which to take the namespace bindings, or a function
 : of type function(xs:string) as xs:QName.
 : @return The rule wrapped as a function.
 :)
declare function tfm:rule(
  $pattern as xs:string,
  $action as function(*),
  $resolver as item()
) as function(xs:string) as function(*)?
{
  tfm:predicate-rule(tfm:pattern($pattern,$resolver), $action)
};

(:~
 : Returns a rule constructed from the predicate function and action specified.
 : Rules are represented as a single function.
 :
 : <p>The predicate function takes a node as an argument and returns true if the node matches.
 : Returning false or raising an error is considered a non-match. Typing the argument of the function
 : provided with a SequenceType of element(), attribute(), etc. will result in the predicate function
 : being optimized by only attempting to be matched against that type of name.</p>
 :
 : <p>Action functions should take between 2 and 3 arguments. If the function takes
 : fewer arguments, they are the arguments at the start of this list:
 : <ul>
 :   <li>function(node()*) as item()*: The mode function, used to re-apply the mode on further nodes.</li>
 :   <li>node(): The context node that the rule is executed on.</li>
 :   <li>$next-match as function() as item()*: The next-mode function.</li>
 : </ul></p>
 :
 : @param $pattern: The pattern string that the rule must match.
 : @param $action: The action function to be executed when the rule is matched.
 : @param $resolver: Either an element from which to take the namespace bindings, or a function
 : of type function(xs:string) as xs:QName which resolves a lexical QName to an xs:QName.
 : @return The rule wrapped as a function.
 :)
declare function tfm:predicate-rule(
  $predicate as function(*),
  $action as function(*)
) as function(xs:string) as function(*)?
{
  let $action := tfm:check-action($action)
  return
    function($k as xs:string) as function(*)?
    {
      switch($k)
        case "predicate" return $predicate
        case "action" return $action
        default return ()
    }
};

declare %private function tfm:check-action(
  $action as function(*)
) as function(
  function(node()*) as item()*,
  node(),
  function() as item()*
) as item()*
{
  typeswitch($action)
    case function(
          function(node()*) as item()*,
          node()
        ) as item()*
      return function(
          $mode as function(node()*) as item()*,
          $node as node(),
          $next-match as function() as item()*
        ) as item()*
        {
          $action($mode,$node)
        }
      case function(
          function(node()*) as item()*,
          node(),
          function() as item()*
        ) as item()*
      return $action
    default return error(xs:QName("tfm:BADACTION"),
      "The action function has the wrong type")
};

(:~
 : Returns a prefix resolver function that resolves prefixes by looking them up in the namespace
 : bindings of the element.
 :
 : @param $element: The element whose namespace bindings should be used.
 : @return The resolver function.
 :)
declare function tfm:resolver(
  $element as element()
) as function(xs:string) as xs:QName
{
  resolve-QName(?, $element)
};

(:~
 : Compiles the pattern given in the string argument to a predicate function,
 : which takes a node as the argument, and returns true if the node matches
 : the pattern. If the predicate returns false or raises an error, the node
 : does not match the pattern.
 :
 : @param $pattern: The pattern string.
 : @return The predicate function.
 :)
declare function tfm:pattern(
  $pattern as xs:string
) as function(*)
{
  let $ns := <ns
      xmlns:fn="http://www.w3.org/2005/xpath-functions"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
      xmlns:xs="http://www.w3.org/2001/XMLSchema"
      xmlns:xhtml="http://www.w3.org/1999/xhtml"
    />
  return tfm:pattern($pattern,$ns)
};

(:~
 : Compiles the pattern given in the string argument to a predicate function,
 : which takes a node as the argument, and returns true if the node matches
 : the pattern. If the predicate returns false or raises an error, the node
 : does not match the pattern.
 :
 : @param $pattern: The pattern string.
 : @param $resolver: Either an element from which to take the namespace bindings, or a function
 : of type function(xs:string) as xs:QName which resolves a lexical QName to an xs:QName.
 : @return The predicate function.
 :)
declare function tfm:pattern(
  $pattern as xs:string,
  $resolver as item()
) as function(*)
{
  let $r :=
    typeswitch($resolver)
      case function(xs:string) as xs:QName return $resolver
      case $e as element() return tfm:resolver($e)
      default return error(xs:QName("tfm:BADRESOLVER"),
        "The resolver should either be of type element() or function(xs:string) as xs:QName")
  return pat:compile-pattern($pattern, $r)
};
