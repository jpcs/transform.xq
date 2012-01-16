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

import module namespace tfm = "http://snelson.org.uk/functions/transform" at "../transform.xq";

declare %tfm:mode("default") %tfm:pattern("@*")
function local:default1($mode, $node)
{
  ()
};

declare %tfm:mode("default") %tfm:pattern("para")
function local:default2($mode, $node)
{
  <p xmlns="http://www.w3.org/1999/xhtml">{ $mode($node/(@*|node())) }</p>
};

declare %tfm:mode("default") %tfm:pattern("section/title")
function local:default3($mode, $node)
{
  <h2 xmlns="http://www.w3.org/1999/xhtml">{ $mode($node/(@*|node())) }</h2>
};

declare %tfm:mode("default") %tfm:pattern("article/title")
function local:default4($mode, $node)
{
  <h1 xmlns="http://www.w3.org/1999/xhtml">{ $mode($node/(@*|node())) }</h1>
};

declare %tfm:mode("default") %tfm:pattern("section")
function local:default5($mode, $node)
{
   <div xmlns="http://www.w3.org/1999/xhtml">{ $mode($node/(@*|node())) }</div>
};

declare %tfm:mode("default") %tfm:pattern("article")
function local:default6($mode, $node)
{
  <html xmlns="http://www.w3.org/1999/xhtml">
    <head><title>{ $node/*:title/string() }</title></head>
    <body>{ $mode($node/(@*|node())) }</body>
  </html>
};

declare %tfm:mode("extend") %tfm:pattern("section/title/text()")
function local:extend1($mode, $node)
{
  "__", $node, "__"
};

declare %tfm:mode("extend") %tfm:pattern("@id")
function local:extend2($mode, $node)
{
  $node
};

declare %tfm:mode("extend") %tfm:pattern("link")
function local:extend3($mode, $node)
{
  <a xmlns="http://www.w3.org/1999/xhtml" href="#{$node/@ref}">{ $mode($node/(@*|node())) }</a>
};

let $mode := tfm:named-mode("default")
let $emode := tfm:named-extend-mode($mode,"extend")
return $emode(
  <article>
    <title>Lala</title>
    <section id="one" fred="hello">
      <title>One</title>
      <para>Once upon a <link ref="two">time</link></para>
    </section>
    <section id="two">
      <title>Two</title>
      <para>There lived...</para>
    </section>
  </article>
)
