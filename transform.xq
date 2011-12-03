xquery version "3.0-ml";

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

module namespace tfm = "http://snelson.org.uk/functions/transform";

import module namespace pat = "http://snelson.org.uk/functions/patterns" at "lib/compile_pattern.xq";
import module namespace map = "http://snelson.org.uk/functions/map" at "lib/map.xq"; (: TBD private annotation :)

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare variable $tfm:magic as element() := <magic/>;

(: Returns the mode function, that performs the transformation :)
declare function tfm:mode(
  $rules as (function(xs:string) as function(*)?)*
) as function(node()*) as item()*
{
  let $map := fold-left(tfm:add-rule#2, map:create(), $rules)
  return tfm:run-mode($map,?)
};

declare function tfm:extend-mode(
  $mode as function(node()*) as item()*,
  $rules as (function(xs:string) as function(*)?)*
) as function(node()*) as item()*
{
  let $map := $mode($tfm:magic)
  let $map := fold-left(tfm:add-rule#2, $map, $rules)
  return tfm:run-mode($map,?)
};

(: Returns a mode function constructed from the functions
at runtime annotated with the given name :)
declare function tfm:named-mode(
  $name as xs:string
) as function(node()*) as item()*
{
  let $functions := tfm:functions()
  let $annotation := tfm:annotation()
  return
    if(empty($functions) or empty($annotation)) then
      error(xs:QName("tfm:NOTSUPPORTED"), "Named modes are not supported on your platform")
    else tfm:mode(
      for $f in $functions()
      where $annotation($f, xs:QName("tfm:mode")) = $name
      return
        let $predicate := $annotation($f, xs:QName("tfm:pattern"))
        return
          if(empty($predicate)) then error(xs:QName("tfm:NOPATTERN"),
            "No pattern specified on function: " || function-name($f) || "#" || function-arity($f))
          else tfm:rule($predicate, $f)
    )
};

declare function tfm:functions() as function() as function(*)*?
{
  (
    function-lookup(fn:QName("http://marklogic.com/xdmp","xdmp:functions"),0)
  )[1]
};

declare function tfm:annotation() as function(function(*),xs:QName) as item()*?
{
  (
    function-lookup(fn:QName("http://marklogic.com/xdmp","xdmp:annotation"),0)
  )[1]
};

declare function tfm:add-rule($map,$rule)
{
  typeswitch($rule("predicate"))
    case function(element()) as xs:boolean
      return tfm:add($map,"element",$rule)
    case function(attribute()) as xs:boolean
      return tfm:add($map,"attribute",$rule)
    case function(document-node()) as xs:boolean
      return tfm:add($map,"document",$rule)
    case function(comment()) as xs:boolean
      return tfm:add($map,"comment",$rule)
    case function(text()) as xs:boolean
      return tfm:add($map,"text",$rule)
    case function(processing-instruction()) as xs:boolean
      return tfm:add($map,"pi",$rule)
    case $p as function(*) return
      if(function-arity($p) ne 1) then error(xs:QName("tfm:BADPREDICATE"),
        "The predicate should have arity 1")
      else (
        tfm:add($map,"element",$rule),
        tfm:add($map,"attribute",$rule),
        tfm:add($map,"document",$rule),
        tfm:add($map,"comment",$rule),
        tfm:add($map,"text",$rule),
        tfm:add($map,"pi",$rule),
        tfm:add($map,"node",$rule)
      )
    default return error(xs:QName("tfm:BADPREDICATE"),
      "The predicate should be a function")
};

declare function tfm:add($map,$key,$rule)
{
  map:put($map,$key,($rule,map:get($map,$key)))
};

declare function tfm:run-mode(
  $map as function() as item()+,
  $nodes as node()*
) as item()*
{
  if($nodes[1] is $tfm:magic) then $map
  else tfm:_run-mode($map,$nodes)
};

declare function tfm:_run-mode(
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
      default return map:get($map,"node")
  let $r :=
    fold-left(function($found, $r) {
        if(exists($found)) then $found
        else if(try { $r("predicate")($n) } catch($e) { false() }) then $r (: TBD 3.0 try/catch :)
        else ()
      }, (), $rules)
  return
    if(exists($r)) then $r("action")($m,$n)
    else (: default rule :)
      typeswitch($n)
        case document-node() return $n/node() ! $m(.) (: TBD multi-way typeswitch :)
        case element() return $n/node() ! $m(.)
        case text() return text { $n }
        case attribute() return text { $n }
        default return ()
};

declare function tfm:rule(
  $pattern as xs:string,
  $action as function(function(node()*) as item()*,node()) as item()*
) as function(xs:string) as function(*)?
{
  tfm:predicate-rule(tfm:pattern($pattern), $action)
};

declare function tfm:rule(
  $pattern as xs:string,
  $action as function(function(node()*) as item()*,node()) as item()*,
  $resolver as item()
) as function(xs:string) as function(*)?
{
  tfm:predicate-rule(tfm:pattern($pattern,$resolver), $action)
};

(: Returns the predicate and action wrapped as a single item :)
declare function tfm:predicate-rule(
  $predicate as function(*),
  $action as function(function(node()*) as item()*,node()) as item()*
) as function(xs:string) as function(*)?
{
  function($k as xs:string) as function(*)?
  {
    (: TBD switch :)
    (: switch($k) :)
    (: case "predicate" return $predicate :)
    (: case "action" return $action :)
    (: default return () :)

    if($k eq "predicate") then $predicate
    else if($k eq "action") then $action
    else ()
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
