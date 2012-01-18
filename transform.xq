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

(: Magic value to get a mode function to return its map of rules :)
declare %private variable $tfm:magic as element() := <magic/>;

(:~
 : Returns a mode function, which can be called to perform the transformation
 : specified by the rules passed in as arguments. Call tfm:rule(), or
 : tfm:predicate-rule() to create rules to pass into this function.
 :
 : @param rules: The sequence of rules to use to create the mode, in
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
 : @param mode: The mode to extend.
 : @param rules: The sequence of rules to use to create the mode, in
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
 : annotated with the given name, using the %tfm:mode() annotation.
 :
 : @param name: The name(s) used in the %tfm:mode() annotation in the
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
 : annotated with the given name, using the %tfm:mode() annotation.
 :
 : @param mode: The mode to extend.
 : @param name: The name(s) used in the %tfm:mode() annotation in the
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
 : annotated with the given name(s), using the %tfm:mode() annotation.
 :
 : @param name: The name(s) used in the %tfm:mode() annotation in the
 : functions for the mode to construct.
 : @return A sequence of rules wrapped as functions, in
 : increasing order by their %tfm:priority annotation.
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
      where $annotation($f, xs:QName("tfm:mode")) = $name
      order by number($annotation($f, xs:QName("tfm:priority"))) ascending empty least
      return
        let $predicate := $annotation($f, xs:QName("tfm:pattern"))
        return
          if(empty($predicate)) then error(xs:QName("tfm:NOPATTERN"),
            "No pattern specified on function: " || function-name($f) || "#" || function-arity($f))
          else tfm:rule($predicate, $f)
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
  let $m := tfm:_run-mode($map,?)
  for $n in $nodes
  let $rules :=
    typeswitch($n)
      case element() return map:get($map,"element")
      case attribute() return map:get($map,"attribute")
      case document-node() return map:get($map,"document")
      case comment() return map:get($map,"comment")
      case text() return map:get($map,"text")
      case processing-instruction() return map:get($map,"pi")
      default return error(xs:QName("tfm:NAMESPACENODE"),
        "Transformation of namespace nodes not currently supported")
  let $r :=
    fold-left(function($found, $r) {
        if(exists($found)) then $found
        else if(try { $r("predicate")($n) } catch * { false() }) then $r
        else ()
      }, (), $rules)
  return
    (: TBD template parameters - jpcs :)
    if(exists($r)) then $r("action")($m,$n)
    else (: default rule :)
      typeswitch($n)
        case element() | document-node() return $n/node() ! $m(.)
        case attribute() | text() return text { $n }
        default return ()
};

declare function tfm:rule(
  $pattern as xs:string,
  $action as function(
      function(node()*) as item()*,
      node()
    ) as item()*
) as function(xs:string) as function(*)?
{
  tfm:predicate-rule(tfm:pattern($pattern), $action)
};

declare function tfm:rule(
  $pattern as xs:string,
  $action as function(
      function(node()*) as item()*,
      node()
    ) as item()*,
  $resolver as item()
) as function(xs:string) as function(*)?
{
  tfm:predicate-rule(tfm:pattern($pattern,$resolver), $action)
};

(:~ Returns the predicate and action wrapped as a single item :)
declare function tfm:predicate-rule(
  $predicate as function(*),
  $action as function(
      function(node()*) as item()*,
      node()
    ) as item()*
) as function(xs:string) as function(*)?
{
  function($k as xs:string) as function(*)?
  {
    switch($k)
      case "predicate" return $predicate
      case "action" return $action
      default return ()
  }
};

declare function tfm:resolver(
  $element as element()
) as function(xs:string) as xs:QName
{
  resolve-QName(?, $element)
};

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
